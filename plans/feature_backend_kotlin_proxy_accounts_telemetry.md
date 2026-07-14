# Backend for Foody — AI Proxy, Telemetry & Accounts (Kotlin/Ktor)

> **Summary**: Introduce a small server-side backend for the Foody app that first and foremost hides the AI provider keys behind an authenticated proxy, then centralizes research telemetry and (later) user accounts and cloud data backup — built in Kotlin/Ktor, deployed for free on scale-to-zero infrastructure.

---

## 1. PROBLEM & SOLUTION

### 1.1 Problem Statement
Foody is currently a fully local-first Flutter app with **no server component at all**. The OpenAI and Gemini API keys are bundled inside the app package (`.env` is a Flutter asset) and are sent directly from every device to the providers, which means anyone who installs the app can extract a live, billable OpenAI key. On top of that, the valuable research telemetry the app collects (AI accuracy, acceptance, per-call cost) can only be gathered by manually exporting a CSV from each tester's phone, and there is no way to run the app on more than one device or recover data after a reinstall.

### 1.2 Solution Overview
Build a lightweight Kotlin/Ktor backend and roll it out in phases. **Phase 1** turns the backend into an authenticated proxy in front of OpenAI/Gemini so the provider key lives only on the server and per-call cost/usage is recorded centrally. **Phase 2** adds a telemetry ingest endpoint so the thesis research data (AI attempts, acceptance/edit signals) flows to the server automatically instead of via manual CSV. **Phase 3** adds real user accounts, and **Phase 4** adds opt-in cloud backup/sync of the local database. Everything is containerized and deployed to free, scale-to-zero infrastructure (Google Cloud Run + Neon Postgres) so it costs nothing while only the author uses it.

### 1.3 Scope: What This IS
- A new standalone Kotlin/Ktor backend service (separate repository/module), documented from local development through free cloud deployment.
- **Phase 1 (MVP, fully specified here):** authenticated pass-through AI proxy that holds the provider keys server-side, plus a minimal device identity and server-side usage recording.
- **Phase 2–4 (architected here, implemented later):** telemetry ingest, user accounts/auth, and opt-in encrypted cloud backup.
- The corresponding Flutter client changes needed to talk to the backend (redirect the two REST clients, remove keys from `.env`, add a device id + app token).
- A concrete, free deployment recipe with secrets handling and rotation of the currently-leaked keys.

### 1.4 Scope: What This IS NOT
- **Not** a real-time multi-user social product, no sharing between users, no push infrastructure beyond what already exists on-device.
- **Not** a full two-way conflict-resolving sync engine in Phase 1–3 (Phase 4 is deliberately backup-first, not CRDT sync).
- **Not** a rewrite of the app's AI prompt/parsing logic in Phase 1 — the initial proxy is a transparent pass-through; moving prompts server-side is an explicit later step.
- **Not** a paid/managed deployment — the whole point is a free tier that scales to zero for a single user.
- **Not** a removal of the `RESEARCH-ONLY` on-device telemetry; the backend telemetry pipeline *absorbs* it, and both are dropped together before any production release.

---

## 2. SUCCESS CRITERIA

Implementation is COMPLETE (for Phase 1) when ALL criteria are met:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | No AI provider key ships in the app anymore; `.env` contains only the backend base URL and the app token. | `unzip -p build/app/outputs/**/app-release.apk assets/.env` (or inspect the IPA) shows no `sk-proj-…` / Gemini key. |
| 2 | The app performs a full photo meal recognition, a voice meal, an exercise, an Ask AI query and a goals generation end-to-end through the backend, with identical user-visible behavior to today. | Manual device smoke test of all five flows; results parse and save correctly. |
| 3 | The backend rejects requests without a valid app token / device id with `401`. | `curl` the proxy endpoint with and without the `Authorization` header. |
| 4 | Every proxied AI call is recorded server-side in Postgres with device id, provider, model, token counts, USD cost and status. | `SELECT * FROM usage_event ORDER BY created_at DESC LIMIT 10;` on Neon after the smoke test. |
| 5 | The backend runs locally via one command and in the cloud via one deploy command, holding the provider key only in server-side secrets. | `docker compose up` locally; `gcloud run deploy` for cloud; hitting `/health` returns `200`. |
| 6 | The previously-leaked OpenAI keys are revoked in the OpenAI dashboard and a fresh key exists only in the server secret store. | OpenAI dashboard shows old keys deleted; new key present only in Cloud Run/Secret Manager, never in git. |
| 7 | Cold-start latency and cost are acceptable for single-user use (scale-to-zero, first request < ~3 s, $0 while idle). | Trigger a request after idle; observe Cloud Run cold start; billing dashboard shows $0. |
| 8 | Backend has a smoke/integration test suite that passes in CI (or locally) covering auth, proxy happy-path, and usage recording. | `./gradlew test` green. |

Phase 2–4 success criteria are listed inline in their step sections (Steps 12–15) and are not required for Phase 1 sign-off.

---

## 3. TECHNICAL DESIGN

### 3.1 Architecture

```
                    Phase 1 (MVP)                          Phase 2/3/4 (later)
┌──────────────┐                     ┌───────────────────────────────────────────┐
│ Flutter app  │                     │  Ktor backend (Cloud Run, scale-to-zero)   │
│ (dio 4)      │                     │                                            │
│              │  HTTPS              │  ┌─────────────┐   ┌────────────────────┐  │
│ OpenaiRest   │  Authorization:     │  │ Auth plugin │   │ /v1/ai/openai/chat │──┼──▶ api.openai.com
│  Client   ───┼─ Bearer <appTok> ──▶│  │ (app token  │   │ /v1/ai/gemini/gen  │──┼──▶ generativelanguage
│ GeminiRest   │  X-Device-Id: uuid  │  │  + deviceId)│   └─────────┬──────────┘  │
│  Client      │                     │  └─────────────┘             │ records     │
│              │                     │  ┌────────────────┐          ▼             │
│ (later)      │  /v1/telemetry ────▶│  │ /v1/telemetry  │   ┌──────────────┐     │
│ Telemetry  ──┼─────────────────────┼─▶│ /v1/auth/*     │   │  Postgres    │     │
│ AuthClient   │  /v1/auth/* ───────▶│  │ /v1/sync/*     │──▶│  (Neon)      │     │
│ SyncClient   │  /v1/sync/* ───────▶│  └────────────────┘   └──────────────┘     │
└──────────────┘                     └───────────────────────────────────────────┘
                                        provider keys live ONLY here (Secret Mgr)
```

**Data flow (Phase 1):** the Flutter `OpenaiRestClient` keeps building the exact same Chat Completions body it builds today, but sends it to `<BACKEND>/v1/ai/openai/chat` with the app token + device id headers instead of directly to OpenAI with the provider key. The backend authenticates the request, injects the real `Authorization: Bearer <OPENAI_KEY>` header, forwards the body to OpenAI, reads `usage` from the response, computes USD cost server-side, writes a `usage_event` row, and returns the OpenAI response body unchanged. The client parses the response exactly as before. Gemini is handled the same way at `/v1/ai/gemini/generate`.

**Why pass-through first:** it kills the key-extraction risk with a *one-file* client change and *zero behavior change*, and it gives us the server-side seam we need to record cost and, later, move prompts server-side.

### 3.2 Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Language/framework | **Kotlin + Ktor** (Netty engine, kotlinx.serialization) | User prefers Kotlin. Ktor is a thin, coroutine-native server ideal for a proxy: tiny footprint, fast cold start (matters for scale-to-zero free tiers), no heavy DI/annotation machinery. Spring Boot is heavier and slower to cold-start. |
| DB access | **Exposed** (JetBrains Kotlin SQL DSL) + **HikariCP** + **Flyway** migrations | Exposed is idiomatic Kotlin and light; Flyway gives versioned schema migrations mirroring the discipline already used in the Flutter Floor layer. |
| Database | **PostgreSQL on Neon** (free tier, serverless, scales to zero) | Free, serverless Postgres that suspends when idle — matches the single-user, cost-zero goal. Managed backups. Standard SQL the thesis analysis can query directly. **Decided.** |
| Hosting | **Render free tier now → Google Cloud Run later** (same Docker container) | Render needs no credit card and gets us live fast; accept its slower cold start (tens of seconds after ~15 min idle). Migrate the identical container to Cloud Run when a faster cold start (~1–3 s) matters. Both run at $0 for a single user. **Decided (start on Render).** |
| Proxy style (Phase 1) | **Authenticated pass-through** of the Chat Completions / generateContent body | Minimal client change, no behavior change, immediate security win. Semantic proxy (prompts server-side) is deferred to a later phase. |
| Client→backend auth (Phase 1) | **Static app token** (in `.env`, sent as `Bearer`) + **device UUID** (`X-Device-Id`) | The app token is not a true secret (it ships in the app), but it reduces the blast radius from "raw OpenAI billing key" to "a revocable, rate-limitable token that only unlocks *my* proxy". Real per-user auth arrives in Phase 3 (magic-link, **decided**). Honest tradeoff documented in §6. |
| Device identity | **UUID generated on first launch, stored in `SharedPreferences`** | No identity primitive exists today. A prefs-backed UUID is the lightest fit for the current architecture and lets telemetry be keyed per install without accounts. |
| Cost computation | **Server-side, authoritative.** Kotlin port of the price table; the on-device Dart `AiCostCalculator` is retired over time. | The server sees `usage` on every call. Making the server the single source of truth for cost avoids drift between two price tables. **Decided.** |
| Repo layout | **Separate git repository** for the backend, with its own Gradle build and deploy | Cleaner separation of concerns and lifecycle; the Flutter repo stays untouched. **Decided (separate repo).** |
| Config | **Env vars** (`BACKEND_APP_TOKEN`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `DATABASE_URL`), never committed | Standard 12-factor; keys injected via Cloud Run Secret Manager in prod, `.env`/`docker-compose` locally. |

---

## 4. IMPLEMENTATION STEPS

> Execute in order. Phase 1 (Steps 0–11) is the concrete deliverable. Steps 12–15 sketch later phases.

### Step 0: Rotate the leaked keys FIRST
**Goal**: Stop the bleeding before writing any code.
**Files**: none (OpenAI dashboard + local `.env`).

- Revoke both `sk-proj-…` keys currently in the working-copy `.env` (they have shipped in every build and must be treated as compromised).
- Create one fresh OpenAI key. Do **not** put it back into the Flutter `.env` — it will live only in the backend secret store.

**Done when**: The old keys are deleted in the OpenAI dashboard.

---

### Step 1: Scaffold the Ktor project
**Goal**: A runnable "hello" server with the chosen stack.
**Files**: `backend/build.gradle.kts`, `backend/settings.gradle.kts`, `backend/src/main/kotlin/foody/Application.kt`, `backend/gradle/…`

Use the Ktor project generator (or hand-write) with plugins: `ktor-server-netty`, `ktor-server-content-negotiation`, `ktor-serialization-kotlinx-json`, `ktor-server-call-logging`, `ktor-server-status-pages`, `ktor-client-cio` (to call providers), `exposed-core`/`exposed-jdbc`, `HikariCP`, `flyway-core`, `postgresql` driver, `logback-classic`.

```kotlin
// Application.kt
fun main() {
    embeddedServer(Netty, port = System.getenv("PORT")?.toInt() ?: 8080) {
        install(ContentNegotiation) { json() }
        install(StatusPages) { /* map exceptions → JSON error bodies */ }
        Database.init()          // Hikari + Flyway.migrate()
        routing {
            get("/health") { call.respond(mapOf("status" to "ok")) }
            aiRoutes()           // Step 4
        }
    }.start(wait = true)
}
```

**Done when**: `./gradlew run` serves `GET /health` → `200 {"status":"ok"}`.

---

### Step 2: Configuration & secrets loading
**Goal**: Read all secrets from env vars with a documented local fallback.
**Files**: `backend/src/main/kotlin/foody/Config.kt`, `backend/.env.example`, `backend/docker-compose.yml`

```kotlin
object Config {
    val appToken   = env("BACKEND_APP_TOKEN")
    val openAiKey  = env("OPENAI_API_KEY")
    val geminiKey  = envOrNull("GEMINI_API_KEY")
    val databaseUrl = env("DATABASE_URL")   // jdbc:postgresql://…
    private fun env(k: String) = System.getenv(k) ?: error("Missing env $k")
}
```

`.env.example` documents every variable (no real values). `docker-compose.yml` runs the app + a local Postgres for dev.

**Done when**: The server refuses to start with a clear error if a required env var is missing.

---

### Step 3: Database schema & migrations
**Goal**: Postgres tables for device identity and usage recording.
**Files**: `backend/src/main/resources/db/migration/V1__init.sql`, `backend/src/main/kotlin/foody/db/Tables.kt`

```sql
-- V1__init.sql
CREATE TABLE device (
    id           UUID PRIMARY KEY,          -- the client-generated device UUID
    first_seen   TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen    TIMESTAMPTZ NOT NULL DEFAULT now(),
    app_version  TEXT
);

CREATE TABLE usage_event (
    id                BIGSERIAL PRIMARY KEY,
    device_id         UUID REFERENCES device(id),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    provider          TEXT NOT NULL,          -- openai | gemini
    model             TEXT,
    endpoint          TEXT NOT NULL,          -- meal | exercise | query | query_scope | goals | injection_screen
    status            TEXT NOT NULL,          -- success | provider_error | invalid
    http_status       INT,
    prompt_tokens     INT,
    completion_tokens INT,
    cached_tokens     INT,
    cost_usd          NUMERIC(12,6),
    latency_ms        INT
);
CREATE INDEX ix_usage_device_time ON usage_event(device_id, created_at);
```

**Done when**: Flyway runs `V1` on startup against local Postgres; tables exist.

---

### Step 4: Auth plugin (app token + device id)
**Goal**: Reject requests lacking a valid `Authorization: Bearer <appToken>` and a well-formed `X-Device-Id`, and upsert the device row.
**Files**: `backend/src/main/kotlin/foody/plugins/Auth.kt`

```kotlin
// A simple route interceptor (bearer-token check is a constant-time compare).
suspend fun ApplicationCall.requireAuth(): UUID {
    val header = request.header(HttpHeaders.Authorization)?.removePrefix("Bearer ")?.trim()
    if (header == null || !MessageDigest.isEqual(header.toByteArray(), Config.appToken.toByteArray()))
        throw AuthException()   // → 401 via StatusPages
    val deviceId = runCatching { UUID.fromString(request.header("X-Device-Id")) }
        .getOrElse { throw AuthException() }
    DeviceRepo.touch(deviceId, request.header("X-App-Version"))   // upsert first_seen/last_seen
    return deviceId
}
```

**Done when**: `curl` without the header → `401`; with a valid header the device row appears/updates.

---

### Step 5: OpenAI proxy endpoint
**Goal**: Authenticated pass-through of the Chat Completions body, with server-side key injection and usage recording.
**Files**: `backend/src/main/kotlin/foody/routes/AiRoutes.kt`, `backend/src/main/kotlin/foody/ai/CostCalculator.kt`

```kotlin
fun Route.aiRoutes() {
    val http = HttpClient(CIO) { install(ClientContentNegotiation) { json() }
                                 install(HttpTimeout) { requestTimeoutMillis = 60_000 } }

    post("/v1/ai/openai/chat") {
        val deviceId = call.requireAuth()
        val endpoint = call.request.queryParameters["endpoint"] ?: "meal"   // for telemetry labelling
        val body: JsonObject = call.receive()

        // Guardrails for a shared token: allowlist models, cap image count/size if desired.
        val model = body["model"]?.jsonPrimitive?.contentOrNull
        require(model in ALLOWED_OPENAI_MODELS) { "model not allowed" }

        val started = System.currentTimeMillis()
        val resp = http.post("https://api.openai.com/v1/chat/completions") {
            header(HttpHeaders.Authorization, "Bearer ${Config.openAiKey}")
            contentType(ContentType.Application.Json); setBody(body)
        }
        val text = resp.bodyAsText()
        val json = Json.parseToJsonElement(text).jsonObject
        UsageRepo.record(deviceId, "openai", model, endpoint, resp.status,
                         usage = json["usage"], latencyMs = (System.currentTimeMillis() - started).toInt())
        call.respondText(text, ContentType.Application.Json, resp.status)
    }
    post("/v1/ai/gemini/generate") { /* same pattern, x-goog-api-key, endpoint="meal" */ }
}
```

`CostCalculator` is a direct Kotlin port of the existing Dart `AiCostCalculator` price table (`gpt-5.4` @ 2.50/0.25/15.00 per 1M, `gpt-5.4-mini`, `gpt-5.5`). `UsageRepo.record` extracts `prompt_tokens` / `completion_tokens` / `prompt_tokens_details.cached_tokens`, computes cost, and inserts a `usage_event`. All recording is wrapped so a telemetry failure never breaks the proxied response.

**Done when**: Forwarding a real Chat Completions body returns the provider response verbatim and writes a `usage_event` row with non-null cost.

---

### Step 6: Error mapping & robustness
**Goal**: Never leak the provider key or a stack trace; forward provider errors sensibly.
**Files**: `backend/src/main/kotlin/foody/plugins/StatusPages.kt`

- On provider `4xx/5xx`, forward the status and a **sanitized** error body (strip any echoed headers).
- On timeout/connection failure, return `502 {"error":"upstream_unavailable"}`.
- On auth failure, `401 {"error":"unauthorized"}`.
- Log request id + device id + endpoint + latency + status (never log the body, never log keys).

**Done when**: Killing network to OpenAI yields a clean `502`; the app surfaces its existing generic AI-failure path.

---

### Step 7: Flutter client — redirect the REST clients
**Goal**: Point the two provider clients at the backend and stop using the provider key.
**Files**: `lib/network/openai_rest_client.dart`, `lib/network/gemini_rest_client.dart`, `.env`, `lib/main.dart`

- Replace the hardcoded `https://api.openai.com/v1/chat/completions` with `${dotenv.env['BACKEND_BASE_URL']}/v1/ai/openai/chat?endpoint=<kind>`.
- Replace the `Authorization: Bearer <OPENAI_KEY>` header with `Authorization: Bearer <BACKEND_APP_TOKEN>` + `X-Device-Id: <deviceId>` + `X-App-Version:`.
- Do the same in `gemini_rest_client.dart` (backend injects the Google key; drop `x-goog-api-key`).
- `.env` now contains only `BACKEND_BASE_URL=` and `BACKEND_APP_TOKEN=` (no `sk-…`).
- The `endpoint` query param is set per public method (`meal`, `exercise`, `query`, `query_scope`, `goals`) so server-side telemetry keeps the same labelling the on-device `AiAttempt` used.

**Done when**: All six OpenAI methods and the Gemini method compile and route through the backend; `grep -R "sk-proj" lib .env` is empty.

---

### Step 8: Flutter client — device identity
**Goal**: A stable per-install UUID.
**Files**: `lib/services/…/device_identity_service.dart` (new), `lib/main.dart`, `lib/di/providers.dart`

```dart
// Reads or lazily creates a UUID in SharedPreferences on first launch.
class DeviceIdentityService {
  static const _key = 'device_id';
  final SharedPreferences _prefs;
  String get deviceId => _prefs.getString(_key) ?? _create();
  String _create() { final id = _uuidV4(); _prefs.setString(_key, id); return id; }
}
```

Expose via a `Provider`; the REST clients read `deviceId` from it. (`uuid` is a tiny pure-Dart package, or generate a v4 from `Random.secure()` to avoid a dependency.)

**Done when**: The same UUID is sent on every request across app restarts.

---

### Step 9: Dockerize
**Goal**: A reproducible container image.
**Files**: `backend/Dockerfile`, `backend/.dockerignore`

```dockerfile
# Multi-stage: build fat jar, then run on a slim JRE.
FROM gradle:8-jdk21 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle shadowJar --no-daemon

FROM eclipse-temurin:21-jre
COPY --from=build /home/gradle/src/build/libs/*-all.jar /app/app.jar
ENV PORT=8080
EXPOSE 8080
CMD ["java", "-jar", "/app/app.jar"]
```

**Done when**: `docker build` + `docker run -p 8080:8080 --env-file .env` serves `/health`.

---

### Step 10: Deploy free — Render now, Cloud Run later
**Goal**: A live HTTPS backend at $0, no credit card required to start.
**Files**: `deploy.md`, `render.yaml` (optional Blueprint)

**Decided:** start on **Render** (no card, live fast), keep the same Docker container so we can migrate to **Cloud Run** later for a faster cold start. Neon is the database in both cases.

**Now — Render:**
1. Create a free **Neon** project; copy the `DATABASE_URL` (JDBC form). No card.
2. Create a Render **Web Service** from the backend repo, "Docker" environment (uses the `Dockerfile` from Step 9). No card for the free web service.
3. Set env vars in the Render dashboard (Render encrypts them): `OPENAI_API_KEY`, `GEMINI_API_KEY`, `BACKEND_APP_TOKEN`, `DATABASE_URL`.
4. Put the resulting `https://foody-backend.onrender.com` into the Flutter `.env` as `BACKEND_BASE_URL`.

Free-tier caveat: the service sleeps after ~15 min idle; the first request after sleep cold-starts in tens of seconds. Acceptable for single-user dev. The app's existing timeout/AI-failure UI covers the rare slow first call; optionally bump the client AI timeout for the first request.

**Later — migrate to Cloud Run** (when faster cold start matters):
1. Move the four secrets into **Google Secret Manager**.
2. Deploy the same container:
   ```bash
   gcloud run deploy foody-backend \
     --source . \
     --region europe-west1 \
     --min-instances 0 --max-instances 1 \
     --set-secrets=OPENAI_API_KEY=OPENAI_API_KEY:latest,\
   GEMINI_API_KEY=GEMINI_API_KEY:latest,\
   BACKEND_APP_TOKEN=BACKEND_APP_TOKEN:latest,\
   DATABASE_URL=DATABASE_URL:latest \
     --allow-unauthenticated
   ```
   (`--min-instances 0` = $0 idle, ~1–3 s cold start. Requires a card on the billing account, not charged within free tier.)
3. Swap `BACKEND_BASE_URL` in the Flutter `.env` to the new `…run.app` URL. No code change (portable container).

**Done when**: The deployed `/health` returns `200`; a device smoke test of all AI flows works against the Render URL; the dashboard shows $0.

---

### Step 11: Tests & CI
**Goal**: Lock the Phase 1 contract.
**Files**: `backend/src/test/kotlin/foody/…`, `.github/workflows/backend.yml` (optional)

- Ktor `testApplication`: `401` without token; happy-path proxy with a **mocked** provider HTTP client returning a canned Chat Completions body incl. `usage`; assert a `usage_event` row is written with the expected cost (reuse the two golden values from the Dart cost tests: `2000/600 → 0.014`, `2000/600 cached 800 → 0.0122`).
- `flutter test` still green client-side (device identity service unit test).

**Done when**: `./gradlew test` is green and covers auth + proxy + cost recording.

---

### Step 12: (Phase 2) Telemetry ingest — *architected, later*
**Goal**: Replace manual CSV export with automatic upload of the research context the server can't see (modality, kind, confidence, `wasEditedByUser`, edit magnitude, AI-original snapshots).
**Design**: `POST /v1/telemetry` accepting a batch of records keyed by `device_id`; store in a `telemetry_event` table mirroring the `AiAttempt` + meal/ingredient `aiOriginal*`/edit fields. Client uploads opportunistically (on connectivity, fire-and-forget, retry-queued). The analyst then queries Postgres / exports instead of collecting phones. This *absorbs* the on-device `RESEARCH-ONLY` data; both are removed together before production per `.claude/RESEARCH_ONLY.md`.
**Success**: a logged meal edit appears as a `telemetry_event` row within one connectivity window.

---

### Step 13: (Phase 3) User accounts & auth — *architected, later*
**Goal**: Real per-user identity so telemetry/backup can be attributed to a person across devices, and the dormant onboarding sign-in modal (`onboarding_signin_modal_screen.dart`) becomes live.
**Design**: passwordless **email magic-link** (or email+password) issuing a signed **JWT**; `account` table; `device.account_id` FK; the app token stays as a coarse gate, JWT becomes the per-user credential. Keep it optional (guest = device-only) so the app still works without an account.
**Success**: sign-in issues a JWT; authenticated endpoints accept it; a second device signing into the same account sees the same server-side identity.

---

### Step 14: (Phase 4) Opt-in cloud backup/sync — *architected, later*
**Goal**: Survive reinstalls / move to a new phone.
**Design**: backup-first, not conflict-resolving sync. Add `updated_at` + soft-delete tombstones to the core Floor tables (they don't exist today), then a `POST /v1/backup` that uploads a client-encrypted snapshot (or per-table deltas keyed by `updated_at`) and `GET /v1/backup/latest` to restore. Photos (filesystem, not DB) are a separate opt-in blob upload to object storage. Start with whole-DB encrypted blob backup (simplest); graduate to delta sync only if needed.
**Success**: reinstall + restore reproduces the user's day records, meals, weights and templates.

---

### Step 15: (Phase 5, optional) Semantic proxy & remote config — *architected, later*
**Goal**: Move prompts, model choice, confidence thresholds and prompt-injection defense server-side; expose remote config (switch model without an app update).
**Design**: replace pass-through endpoints with semantic ones (`POST /v1/ai/meal` taking images + description + user attributes); the backend owns `prompt.dart`'s server equivalent. This tightens the shared-token guardrail (the proxy no longer forwards arbitrary bodies) and lets the injection pre-screen live server-side.
**Success**: the app sends no prompt text; changing the model is a server config change.

---

## 5. EDGE CASES & ERRORS

| Scenario | Expected Behavior | How to Handle |
|----------|-------------------|---------------|
| Request without / with wrong app token | `401 unauthorized` | Auth interceptor constant-time compare (Step 4). |
| Malformed / missing `X-Device-Id` | `401` | Reject before proxying; do not auto-mint server-side ids. |
| OpenAI returns `200` but no `usage` block | Response forwarded unchanged; `usage_event` written with null tokens/cost | `UsageRepo` tolerates missing `usage` (mirrors on-device `OpenAiUsage.fromResponse`). |
| Provider `429` / `5xx` | Forward status + sanitized body; record `status='provider_error'` | Status pages + usage recording on the error path too. |
| Provider timeout / network down | `502 upstream_unavailable`; app shows existing generic AI-failure UI | `HttpTimeout` on the Ktor client; app already has an offline/AI-failure path. |
| Client offline (Phase 1) | AI features unavailable exactly as today (they always needed connectivity) | No change; local logging still works. |
| Telemetry / DB write fails (Phase 1 recording, Phase 2 ingest) | Never affects the user-facing response | All recording wrapped in try/catch, fire-and-forget (same discipline as on-device `AiAttemptLogService`). |
| Shared app token abused as a free OpenAI relay | Blast radius limited; abuse is visible & revocable | Model allowlist + payload size cap + optional per-device rate limit; rotate `BACKEND_APP_TOKEN` to revoke. True fix = Phase 3 per-user auth. |
| Cold start after idle | First request ~1–3 s slower | Acceptable for single-user; `min-instances 0` keeps cost $0. Bump to `min-instances 1` if latency ever matters (leaves free tier). |
| Large base64 image body | Accepted up to a sane cap | Set a request size limit (e.g. 15 MB) so the token can't be used to push arbitrary huge payloads. |
| Two devices, no accounts yet (Phase 1) | Each has its own UUID; telemetry separated per device | Accounts (Phase 3) unify them later. |
| Neon suspends on idle | First DB query after idle has a small resume latency | Acceptable; Hikari retries the connection. |

---

## 6. SECURITY CONSIDERATIONS

- **The core win:** the provider key moves from *shipped-in-every-APK* to *server-side secret only*. This is the single most important outcome. Step 0 (rotate the already-leaked keys) is non-negotiable and must happen before anything else — both current `sk-proj-…` keys are compromised.
- **App token is not a true secret.** It ships in the app and can be extracted. Be honest about this in the thesis: it does **not** authenticate a user, it only gates access to *your* proxy. Its value is (a) the raw billing key is no longer exposed, (b) the token is revocable/rotatable without an app update to the key, (c) traffic is rate-limitable and monitorable per device. Real authentication is Phase 3 (per-user JWT).
- **Guardrails against relay abuse:** model allowlist, request size cap, optional per-device rate limit (e.g. N calls/min in Postgres or an in-memory bucket). Log every call with device id so abuse is visible.
- **Input validation:** validate `model` against an allowlist; reject oversized bodies; never `eval`/reflect on client input. Provider responses are forwarded as-is to the client but **sanitized** on the error path (strip echoed auth headers).
- **Sensitive data & logging:** never log request bodies (they contain food photos and free text), never log any key. Log only request id, device id, endpoint, model, token counts, cost, latency, status. Use HTTPS only (Cloud Run enforces TLS).
- **Secrets handling:** keys live in Cloud Run Secret Manager in prod and a git-ignored `.env`/compose file locally. `.env.example` documents names only. Add `backend/.env` to `.gitignore`.
- **Telemetry & GDPR (thesis-relevant):** once telemetry flows to a server (Phase 2), you are processing tester data off-device. Document the legal basis (informed consent from testers), retention, and that all research telemetry — on-device and server-side — is deleted before any production release, consistent with `.claude/RESEARCH_ONLY.md`. A device UUID is pseudonymous, not anonymous; treat it accordingly.
- **CORS:** the client is a mobile app, not a browser, so CORS is not required; do **not** enable `Access-Control-Allow-Origin: *` (would invite browser-based relay abuse).

---

## 7. ASSUMPTIONS

Inferred from incomplete input — verify these are correct:

1. **Kotlin is a preference, not a hard requirement.** The user said "asi bych ho chtel v kotlinu" and asked for alternatives, so Ktor is selected but Supabase/Node are documented alternatives (§12). If the goal were *least code*, Supabase would win; the plan assumes the user values writing the backend themselves (thesis learning value).
2. **Free + single-user is the current constraint, not a permanent one.** Scale-to-zero (Cloud Run + Neon) is chosen for $0 idle. The architecture still scales if testers are added later.
3. **The immediate priority is securing the key, not accounts.** The user listed accounts and usage-logging first, but the analysis shows the shipped key is the urgent risk, so Phase 1 leads with the proxy. Accounts are Phase 3. If the user disagrees, reorder (see §12.2).
4. **The thesis benefits from centralizing the existing research telemetry.** The app already collects rich `AiAttempt`/edit data exported by CSV; Phase 2 is framed as automating that, which is high academic value.
5. **Behavior parity is required in Phase 1.** The pass-through proxy is chosen specifically so users see no difference; prompt/logic relocation is deferred.
6. **The dormant onboarding sign-in modal is intended to become real accounts eventually.** Its presence suggests accounts were always planned; Phase 3 activates it.

> Open questions live in Section 12.

---

## 8. QUICK REFERENCE

### Files to Create (backend)
- `backend/build.gradle.kts`, `settings.gradle.kts` — Gradle Kotlin/Ktor build.
- `backend/src/main/kotlin/foody/Application.kt` — server bootstrap.
- `backend/src/main/kotlin/foody/Config.kt` — env/secrets.
- `backend/src/main/kotlin/foody/plugins/Auth.kt`, `StatusPages.kt` — auth + error mapping.
- `backend/src/main/kotlin/foody/routes/AiRoutes.kt` — proxy endpoints.
- `backend/src/main/kotlin/foody/ai/CostCalculator.kt` — Kotlin port of the Dart price table.
- `backend/src/main/kotlin/foody/db/{Tables.kt,DeviceRepo.kt,UsageRepo.kt}` — Exposed data layer.
- `backend/src/main/resources/db/migration/V1__init.sql` — Flyway schema.
- `backend/Dockerfile`, `.dockerignore`, `docker-compose.yml`, `.env.example`, `deploy.md`.
- `backend/src/test/kotlin/foody/…` — Ktor tests.

### Files to Create (Flutter)
- `lib/services/…/device_identity_service.dart` — device UUID.

### Files to Modify (Flutter)
- `lib/network/openai_rest_client.dart` — base URL → backend, headers → app token + device id, drop `sk-…`.
- `lib/network/gemini_rest_client.dart` — same.
- `.env` — remove provider keys; add `BACKEND_BASE_URL`, `BACKEND_APP_TOKEN`.
- `lib/main.dart`, `lib/di/providers.dart` — wire device identity provider.

### Dependencies (backend)
- Ktor server (`netty`, `content-negotiation`, `kotlinx-json`, `status-pages`, `call-logging`), Ktor client (`cio`), Exposed (`core`, `jdbc`), HikariCP, Flyway, PostgreSQL driver, Logback, `shadowJar` plugin.

### Commands
```bash
# Backend local
cd backend && ./gradlew run                 # or: docker compose up
curl localhost:8080/health

# Backend tests
cd backend && ./gradlew test

# Deploy (after gcloud auth + Neon + Secret Manager set up)
gcloud run deploy foody-backend --source backend/ --region europe-west1 \
  --min-instances 0 --max-instances 1 --allow-unauthenticated --set-secrets=…

# Client — verify no key ships
grep -R "sk-proj" lib .env || echo "clean"
```

---

## 10. CORRECTIONS FROM CURRENT STATE

| What | Before (Current) | After (Target, Phase 1) |
|------|------------------|-------------------------|
| Provider key location | `.env` bundled as a Flutter asset, shipped in every APK/IPA, extractable | Lives only in server-side Secret Manager; never in the app |
| AI request path | Device → `api.openai.com` / Google directly with raw provider key | Device → backend (app token + device id) → provider (server-injected key) |
| Leaked keys | Two live `sk-proj-…` keys in the working-copy `.env` | Both revoked; one fresh key server-side only |
| Cost/usage recording | On-device `AiAttempt` table, exported per-phone via CSV | Recorded server-side per call in Postgres (Phase 1); telemetry auto-uploaded (Phase 2) |
| Identity | None (single-user local DB, no id) | Per-install device UUID; per-user accounts in Phase 3 |
| Onboarding sign-in modal | Present but dormant/commented-out UI | Activated in Phase 3 with real auth |
| Data durability | Local SQLite only; lost on reinstall | Opt-in encrypted cloud backup in Phase 4 |

---

## 11. CHANGELOG

| Date | Change |
|------|--------|
| 2026-07-08 | Initial plan created |
| 2026-07-08 | Author decisions locked: proxy-first; separate backend repo; host = Render now → Cloud Run later (same container); telemetry = minimal `usage_event` now; accounts = magic-link; cost table = server-authoritative; export = keep both. Updated §3.2, Step 10, §12.2. |
| 2026-07-08 | **Backend Phase 1 IMPLEMENTED** in `~/IdeaProjects/foody-be` (Ktor, 18 tests green, clean build). Endpoints: `/health`, `/v1/whoami`, `/v1/ai/openai/chat`, `/v1/ai/gemini/generate`. Deploy files ready (Dockerfile/render.yaml/compose). Not committed to git yet; not deployed; live DB migration unverified (no Docker). |
| 2026-07-08 | **Step 0 (key rotation) DEFERRED by author** — keys left as-is for now. Tracked in `~/IdeaProjects/foody-be/SECURITY_TODO.md`. Flutter integration built with a **non-breaking fallback**: app calls providers directly until `BACKEND_BASE_URL` is set in `.env`, then flips to the proxy. |

---

## 12. OPEN QUESTIONS & ALTERNATIVE APPROACHES

### 12.1 Alternative Approaches Considered

**Backend framework:**

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **Kotlin + Ktor** | User's language preference; tiny footprint; fast cold start (key for scale-to-zero); coroutine-native, ideal for a proxy | Less "batteries included" than Spring; you wire more yourself | ✅ |
| Kotlin + Spring Boot | Industry standard; huge ecosystem; security/JPA out of the box | Heavy; slow cold start (bad for scale-to-zero free tier); overkill for a proxy | — |
| Supabase (BaaS) | Least code: managed Postgres + Auth + Storage + row-level security for free; accounts & backup almost free | Not Kotlin (Edge Functions are Deno/TS); an AI proxy still needs a server fn; less thesis learning value | — |
| Node/TS or Go | Also fine for a proxy; huge ecosystem / tiny binaries | Not the user's stated preference | — |

**Hosting (free, scale-to-zero):**

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **Google Cloud Run + Neon Postgres** | True scale-to-zero ($0 idle); generous free tier; Secret Manager; HTTPS built-in; container = portable | Cold start ~1–3 s; GCP setup has a learning curve | ✅ |
| Render free tier + Neon | Simplest UX; git-push deploy | Spins down after 15 min idle (cold starts); 750 h/mo cap; less headroom | — (documented fallback) |
| Fly.io / Koyeb | Good free-ish tiers; global | Free terms shift; Fly needs a card | — |
| Oracle Cloud Always-Free VM | Always-on ARM VM, no cold start, genuinely free | You manage the VM (OS, TLS, updates) — more ops burden | — |

**Proxy style (Phase 1):**

| Approach | Pros | Cons | Selected? |
|----------|------|------|-----------|
| **Authenticated pass-through** of the provider body | One-file client change; zero behavior change; immediate key-security win | Prompts/model still client-side; shared token can relay arbitrary bodies (mitigated by allowlist) | ✅ |
| Semantic proxy (prompts server-side) now | Tightest guardrails; prompts hidden; injection defense server-side | Much larger change; risks behavior regressions on the critical AI path | — (Phase 5) |

**Why the selected stack won:** Ktor + Cloud Run + Neon delivers the urgent security fix with a minimal client change, costs $0 for a single user, keeps the thesis learning value of writing the backend in Kotlin, and leaves a clean path to accounts, telemetry and backup without re-platforming.

### 12.2 Resolved Decisions

> All five original open questions were resolved by the author on 2026-07-08. Recorded here so they are not re-litigated.

- [x] **Phase ordering: proxy-first.** The shipped key is the urgent, quantifiable risk; accounts add little with a single user. (Confirmed.)
- [x] **Repo: a separate git repository** for the backend, own Gradle build and deploy; the Flutter repo stays untouched. (Confirmed.)
- [x] **Host: start on Render, migrate to Cloud Run later.** Render needs no credit card and gets us live fast; the identical Docker container moves to Cloud Run when the faster cold start is worth attaching a card. See Step 10.
- [x] **Telemetry scope: minimal `usage_event` now**, richer `telemetry_event` ingest deferred until just before the long-term study so the schema matches the final research questions.
- [x] **Accounts: magic-link** (no password storage, less liability). Phase 3.
- [x] **Cost table: server is authoritative.** The Kotlin price table is the single source of truth; the on-device Dart `AiCostCalculator` is retired over time.
- [x] **Export (Phase 4): keep both** on-device and server-side export for now; revisit later.

### 12.3 Suggestions & Follow-ups

- Add a tiny per-device rate limit early (even a crude Postgres counter) so a leaked app token can't run up a bill overnight.
- Consider a `GET /v1/config` remote-config endpoint in Phase 5 so you can switch AI model or toggle "research mode" without shipping an app update.
- The backend is a strong thesis chapter in its own right: "securing an AI-key from a mobile client" and "centralizing research telemetry" are both defensible engineering narratives — document the honest limitation of the shared app token vs real auth.
- When Phase 4 (backup) lands, reuse the existing CSV/PDF export logic server-side to generate research exports directly from Postgres, retiring the on-phone export step entirely.
- Keep the Kotlin `CostCalculator` price table and the Dart `AiCostCalculator` in sync (or make the server authoritative and retire the Dart one) to avoid drift.
- Note the future validation study (`thesis/testovani/budouci_prace_validacni_studie.md`) needs (photo, AI estimate, ground truth) triples — a Phase 2 telemetry schema that keeps the `aiOriginal*` snapshot server-side is exactly the substrate that study needs.
