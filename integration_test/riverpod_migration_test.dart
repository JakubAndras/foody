// Integration tests verifying the GetX -> Riverpod migration. These run ON A DEVICE (not headless).
//
// Run (from the project root):
//   flutter test integration_test/riverpod_migration_test.dart -d <device-id>
//
// Run a single test (by name):
//   flutter test integration_test/riverpod_migration_test.dart -d <device-id> --name "Full onboarding walk"
//
// List devices:  flutter devices
// Tip: connect the iPhone via CABLE (repeated launches over wireless report
//   "Cannot start app on wirelessly tethered iOS device"). Alternative: an iOS simulator.
// The verdict is the last line of output: "All tests passed!" = OK.

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app.dart';
import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/migrations.dart';
import 'package:diplomka/di/providers.dart' as di;
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/onboarding/onboarding_flow_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_gender_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_workouts_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_height_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_dob_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_goal_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_desired_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_loading_plan_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_plan_ready_screen.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_diet_screen.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/state/weight_entry_notifier.dart';

/// Fake AI service — vrací deterministickou odpověď, žádné volání OpenAI.
class _FakeAiService implements AiService {
  @override
  Future<AiResponse?> generateResponse({
    List<File>? imageFiles,
    String? textPrompt,
    Map<String, dynamic>? mealUserAttributes,
  }) async {
    final values = NutritionalValues(calories: 330, proteins: 62, fats: 7.2, carbs: 0);
    return AiResponse(
      valid: true,
      answer: Answer(
        name: 'Kuřecí prsa',
        confidence: 0.95,
        amount: 1.0,
        nutritionalValues: values,
        ingredients: [
          IngredientResponse(name: 'Kuřecí prsa', confidence: 0.95, quantity: '200 g', weightGrams: 200, nutritionalValues: values),
        ],
      ),
    );
  }
}

Future<AppDatabase> _buildInMemoryDb() {
  return $FloorAppDatabase.inMemoryDatabaseBuilder().addMigrations(appMigrations).build();
}

/// Aktivní pumpání bez čekání na ustálení (onboarding/dashboard mají nekonečné animace
/// jako mesh gradient / spinner, takže `pumpAndSettle` by vypršel).
Future<void> _pumpFor(WidgetTester t, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

/// Na gated obrazovce vybere první možnost a klikne Continue.
Future<void> _selectAndContinue(WidgetTester t, Type screen) async {
  await t.tap(find.descendant(of: find.byType(screen), matching: find.byType(OnboardingOptionCard)).first);
  await _pumpFor(t, frames: 3);
  await t.tap(find.descendant(of: find.byType(screen), matching: find.byType(OnboardingPrimaryButton)));
  await _pumpFor(t);
}

/// Na obrazovce s defaultem (výška/váha, DOB, desired weight) jen klikne Continue.
Future<void> _continueOnly(WidgetTester t, Type screen) async {
  await t.tap(find.descendant(of: find.byType(screen), matching: find.byType(OnboardingPrimaryButton)));
  await _pumpFor(t);
}

List<Override> _overrides(AppDatabase db) => [
      di.databaseProvider.overrideWithValue(db),
      // Celý AI řetězec běží přes tenhle selektor → fake pokrývá foto i text.
      aiServiceProvider.overrideWithValue(_FakeAiService()),
    ];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Bez inicializace Liquid Glass házejí glass vrstvy UnsupportedError při paint()
  // (stejně jako main() volá LiquidGlassWidgets.initialize() při startu).
  setUpAll(() async {
    await LiquidGlassWidgets.initialize();
  });

  group('Riverpod provider graph (po migraci z GetX)', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = await _buildInMemoryDb();
      container = ProviderContainer(overrides: _overrides(db));
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('AI pipeline s fake službou vrátí úspěšný výsledek (analyzeMeal)', () async {
      final pipeline = container.read(aiPipelineServiceProvider);
      final result = await pipeline.analyzeMeal(description: 'kuřecí prsa 200 g', modality: 'text');

      expect(result.isSuccess, isTrue, reason: 'fake AI má vrátit success');
      expect(result.response?.answer.name, 'Kuřecí prsa');
      expect(result.response!.answer.confidence, greaterThanOrEqualTo(AiPipelineService.minMealConfidence));
    });

    test('DB vrstva přes Riverpod (sqflite na zařízení): zápis a čtení vážení', () async {
      final notifier = container.read(weightEntriesProvider.notifier);
      await notifier.saveEntry(WeightEntry(date: DateTime(2026, 7, 6), weight: 81.5, photoPath: null));

      final entries = await container.read(weightEntriesProvider.future);
      expect(entries, isNotEmpty);
      expect(entries.first.weight, 81.5);
      expect(container.read(latestWeightEntryProvider)?.weight, 81.5);
    });

    test('DayRecord repozitář se zbootuje a vrátí prázdný seznam na čisté DB', () async {
      final repo = container.read(dayRecordRepositoryProvider);
      final records = await repo.getAllDayRecords();
      expect(records, isEmpty);
    });

    test('Session provider má rozumný výchozí stav', () {
      final session = container.read(sessionProvider);
      expect(session.onboardingComplete, isFalse);
      expect(session.prefersMetric, isTrue);
    });
  });

  group('Bootstrap celé aplikace na zařízení', () {
    testWidgets('App se nabootuje a zobrazí onboarding gate bez výjimky', (tester) async {
      await EasyLocalization.ensureInitialized();
      final db = await _buildInMemoryDb();

      // App.initState spouští NotificationBootstrap, který čte di.rootContainer.
      di.rootContainer = ProviderContainer(overrides: _overrides(db));
      addTearDown(() async {
        di.rootContainer.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: di.rootContainer,
          child: EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('cs')],
            path: 'assets/translations',
            fallbackLocale: const Locale('en'),
            useFallbackTranslations: true,
            child: const App(),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
      // Výchozí session není onboarded → gate ukáže onboarding.
      expect(find.byType(OnboardingFlowScreen), findsOneWidget);
    });
  });

  group('Interaktivní UI clickthrough (na zařízení)', () {
    testWidgets('Full onboarding walk: vybrat hodnotu na každém kroku → přistát na Dashboardu', (tester) async {
      await EasyLocalization.ensureInitialized();

      // liquid_glass_widgets 0.5.0 hází při paintu uprostřed animace přechodu
      // `UnsupportedError: Infinity or NaN toInt` (transientní rendering chyba glass vrstvy).
      // Je kosmetická a netýká se logiky onboardingu — odfiltrujeme JEN ji, ať nepadá celý flow.
      final priorOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final ex = details.exception;
        if (ex is UnsupportedError && (ex.message?.contains('Infinity or NaN') ?? false)) return;
        priorOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = priorOnError);

      final db = await _buildInMemoryDb();
      di.rootContainer = ProviderContainer(overrides: _overrides(db));
      addTearDown(() async {
        di.rootContainer.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: di.rootContainer,
          child: EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('cs')],
            path: 'assets/translations',
            fallbackLocale: const Locale('en'),
            useFallbackTranslations: true,
            child: const App(),
          ),
        ),
      );
      await _pumpFor(tester, frames: 12);

      // Welcome → Get Started
      expect(find.byType(OnboardingWelcomeScreen), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(OnboardingWelcomeScreen), matching: find.byType(OnboardingPrimaryButton)));
      await _pumpFor(tester);

      // Gender → male (první možnost) → Continue
      await _selectAndContinue(tester, OnboardingGenderScreen);
      // Workouts → první možnost → Continue
      await _selectAndContinue(tester, OnboardingWorkoutsScreen);
      // Height & Weight (defaulty) → Continue
      await _continueOnly(tester, OnboardingHeightWeightScreen);
      // Date of Birth (default) → Continue
      await _continueOnly(tester, OnboardingDobScreen);
      // Goal → lose (první) → Continue → objeví se Desired Weight
      await _selectAndContinue(tester, OnboardingGoalScreen);
      // Desired Weight (doporučená hodnota) → Continue
      await _continueOnly(tester, OnboardingDesiredWeightScreen);
      // Diet → classic (první) → Continue
      await _selectAndContinue(tester, PersonalDetailsDietScreen);

      // Loading Plan — počkat na dopočítání (_isComplete) a tapnout Continue.
      await _pumpFor(tester, frames: 24);
      final loadingContinue = find.descendant(of: find.byType(OnboardingLoadingPlanScreen), matching: find.byType(OnboardingPrimaryButton));
      if (loadingContinue.evaluate().isNotEmpty) {
        await tester.tap(loadingContinue.last);
        await _pumpFor(tester);
      }

      // Plan Ready → Let's get started → dokončí onboarding
      await _continueOnly(tester, OnboardingPlanReadyScreen);
      await _pumpFor(tester, frames: 16);

      // Onboarding hotový → gate přepne na hlavní obrazovku.
      expect(find.byType(MainScreen), findsOneWidget);

      // Necháme reálně doběhnout rozpracované async DB dotazy dashboardu, aby
      // teardown nezavřel in-memory DB uprostřed dotazu (SqfliteDatabaseException).
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      });
    });
  });
}
