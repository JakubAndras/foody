import SwiftUI
import WidgetKit

private enum HomeWidgetConstants {
  static let appGroupId = "group.com.jakubandras.diplomka.widgets"
  static let payloadKey = "home_widget_payload"

  static let kindNutrition = "NutritionSummaryWidget"
  static let kindScanFood = "ScanFoodShortcutWidget"
  static let kindBarcode = "BarcodeShortcutWidget"

  static let actionOpenDashboard = "open_dashboard"
  static let actionScanFood = "scan_food"
  static let actionScanBarcode = "scan_barcode"
}

private struct HomeWidgetQuickAction: Codable {
  let id: String?
  let label: String?
  let uri: String?
}

private struct HomeWidgetPayload: Codable {
  let schemaVersion: Int?
  let caloriesToday: Double?
  let caloriesGoal: Double?
  let proteinToday: Double?
  let proteinGoal: Double?
  let carbsToday: Double?
  let carbsGoal: Double?
  let fatToday: Double?
  let fatGoal: Double?
  let progress: Double?
  let lastUpdatedAtMillis: Int64?
  let quickActions: [HomeWidgetQuickAction]?

  static let empty = HomeWidgetPayload(
    schemaVersion: 1,
    caloriesToday: 0,
    caloriesGoal: 0,
    proteinToday: 0,
    proteinGoal: 0,
    carbsToday: 0,
    carbsGoal: 0,
    fatToday: 0,
    fatGoal: 0,
    progress: 0,
    lastUpdatedAtMillis: 0,
    quickActions: nil
  )
}

private struct HomeWidgetEntry: TimelineEntry {
  let date: Date
  let payload: HomeWidgetPayload
}

private struct HomeWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> HomeWidgetEntry {
    HomeWidgetEntry(date: Date(), payload: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {
    completion(HomeWidgetEntry(date: Date(), payload: loadPayload()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void) {
    let entry = HomeWidgetEntry(date: Date(), payload: loadPayload())
    let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(30 * 60)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func loadPayload() -> HomeWidgetPayload {
    guard let defaults = UserDefaults(suiteName: HomeWidgetConstants.appGroupId),
          let raw = defaults.string(forKey: HomeWidgetConstants.payloadKey),
          let data = raw.data(using: .utf8) else {
      return .empty
    }

    return (try? JSONDecoder().decode(HomeWidgetPayload.self, from: data)) ?? .empty
  }
}

private func deepLinkURL(action: String, payload: HomeWidgetPayload) -> URL? {
  if let quickActions = payload.quickActions {
    for quickAction in quickActions {
      if quickAction.id == action,
         let raw = quickAction.uri,
         let url = URL(string: raw) {
        return url
      }
    }
  }

  var components = URLComponents()
  components.scheme = "diplomka"
  components.host = "widget"
  components.path = "/\(action)"
  components.queryItems = [URLQueryItem(name: "homeWidget", value: "1")]
  return components.url
}

private func formatCalories(_ value: Double?) -> String {
  String(Int((value ?? 0).rounded()))
}

private func formatMacro(_ value: Double?) -> String {
  let resolved = value ?? 0
  let rounded = resolved.rounded()
  if abs(resolved - rounded) < 0.05 {
    return "\(Int(rounded))g"
  }
  return String(format: "%.1fg", resolved)
}

private func formatUpdatedLabel(_ millis: Int64?) -> String {
  guard let millis, millis > 0 else { return "Updated recently" }
  let updatedAt = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
  let minutes = Int(Date().timeIntervalSince(updatedAt) / 60)
  if minutes <= 0 {
    return "Updated just now"
  }
  return "Updated \(minutes)m ago"
}

private struct NutritionSummaryWidgetView: View {
  let entry: HomeWidgetEntry

  private var progressValue: Double {
    min(max(entry.payload.progress ?? 0, 0), 1)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Today")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(.secondary)

      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(formatCalories(entry.payload.caloriesToday))
          .font(.title)
          .fontWeight(.bold)
        Text("/ \(formatCalories(entry.payload.caloriesGoal)) kcal")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      ProgressView(value: progressValue)
        .accentColor(Color(red: 0.34, green: 0.51, blue: 0.96))

      HStack(spacing: 10) {
        macroBlock(title: "Protein", value: formatMacro(entry.payload.proteinToday))
        macroBlock(title: "Carbs", value: formatMacro(entry.payload.carbsToday))
        macroBlock(title: "Fat", value: formatMacro(entry.payload.fatToday))
      }

      Text(formatUpdatedLabel(entry.payload.lastUpdatedAtMillis))
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(.secondarySystemBackground))
    .widgetURL(deepLinkURL(action: HomeWidgetConstants.actionOpenDashboard, payload: entry.payload))
  }

  @ViewBuilder
  private func macroBlock(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption2)
        .foregroundColor(.secondary)
      Text(value)
        .font(.caption)
        .fontWeight(.semibold)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct ShortcutWidgetView: View {
  let title: String
  let systemImage: String
  let url: URL?

  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: systemImage)
        .font(.system(size: 26, weight: .semibold))
      Text(title)
        .font(.caption)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.secondarySystemBackground))
    .widgetURL(url)
  }
}

struct NutritionSummaryWidget: Widget {
  let kind: String = HomeWidgetConstants.kindNutrition

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HomeWidgetProvider()) { entry in
      NutritionSummaryWidgetView(entry: entry)
    }
    .configurationDisplayName("Nutrition Summary")
    .description("Shows today's calories and macros.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

struct ScanFoodShortcutWidget: Widget {
  let kind: String = HomeWidgetConstants.kindScanFood

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HomeWidgetProvider()) { entry in
      ShortcutWidgetView(
        title: "Scan Food",
        systemImage: "camera.fill",
        url: deepLinkURL(action: HomeWidgetConstants.actionScanFood, payload: entry.payload)
      )
    }
    .configurationDisplayName("Scan Food")
    .description("Quick action to open meal scan.")
    .supportedFamilies([.systemSmall])
  }
}

struct BarcodeShortcutWidget: Widget {
  let kind: String = HomeWidgetConstants.kindBarcode

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HomeWidgetProvider()) { entry in
      ShortcutWidgetView(
        title: "Barcode",
        systemImage: "barcode",
        url: deepLinkURL(action: HomeWidgetConstants.actionScanBarcode, payload: entry.payload)
      )
    }
    .configurationDisplayName("Barcode")
    .description("Quick action to open barcode scan.")
    .supportedFamilies([.systemSmall])
  }
}

@main
struct DiplomkaHomeWidgetsBundle: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    NutritionSummaryWidget()
    ScanFoodShortcutWidget()
    BarcodeShortcutWidget()
  }
}
