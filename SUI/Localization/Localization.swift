// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
//swiftlint:disable all

import Foundation

enum Localization {
  /// Plural format key: "%#@elements@"
  internal static func elements(_ p1: Int) -> String {
    let format = Bundle.main.localizedString(
      forKey: "%@ elements",
      value: nil,
      table: "Localizable"
    )
    return String(format: format, p1)
  }
  /// Plural format key: "%#@parrots@"
  internal static func parrots(_ p1: Int) -> String {
    let format = Bundle.main.localizedString(
      forKey: "%@ parrots",
      value: nil,
      table: "Localizable"
    )
    return String(format: format, p1)
  }
  /// Экран детализации
  internal static var detailsView: String {
    Bundle.main.localizedString(
      forKey: "Details View",
      value: nil,
      table: "Localizable"
    )
  }
  /// Четвертый экран
  internal static var fourthScreen: String {
    Bundle.main.localizedString(
      forKey: "Fourth screen",
      value: nil,
      table: "Localizable"
    )
  }
  /// Привет, %@
  internal static func hello(_ p1: Any) -> String {
    let format = Bundle.main.localizedString(
      forKey: "Hello, %@",
      value: nil,
      table: "Localizable"
    )
    return String(format: format, String(describing: p1))
  }
  /// Элемент %@
  internal static func item(_ p1: Any) -> String {
    let format = Bundle.main.localizedString(
      forKey: "Item %@",
      value: nil,
      table: "Localizable"
    )
    return String(format: format, String(describing: p1))
  }
  /// Модельный экран
  internal static var modalScreen: String {
    Bundle.main.localizedString(
      forKey: "Modal Screen",
      value: nil,
      table: "Localizable"
    )
  }
  /// открыть
  internal static var `open`: String {
    Bundle.main.localizedString(
      forKey: "open",
      value: nil,
      table: "Localizable"
    )
  }
  /// Открыть экран детализации
  internal static var openDetail: String {
    Bundle.main.localizedString(
      forKey: "Open detail",
      value: nil,
      table: "Localizable"
    )
  }
  /// Открыть экран детализации модельно
  internal static var openDetailsModal: String {
    Bundle.main.localizedString(
      forKey: "Open Details Modal",
      value: nil,
      table: "Localizable"
    )
  }
  /// Открыть второй экран
  internal static var openSecondScreen: String {
    Bundle.main.localizedString(
      forKey: "Open Second Screen",
      value: nil,
      table: "Localizable"
    )
  }
  /// попугаев
  internal static var parrots: String {
    Bundle.main.localizedString(
      forKey: "parrots",
      value: nil,
      table: "Localizable"
    )
  }
  /// экран %@
  internal static func screen(_ p1: Any) -> String {
    let format = Bundle.main.localizedString(
      forKey: "screen %@",
      value: nil,
      table: "Localizable"
    )
    return String(format: format, String(describing: p1))
  }
  /// Второй экран
  internal static var secondScreen: String {
    Bundle.main.localizedString(
      forKey: "Second Screen",
      value: nil,
      table: "Localizable"
    )
  }
  /// Показать в метрах
  internal static var showInMeters: String {
    Bundle.main.localizedString(
      forKey: "Show in Meters",
      value: nil,
      table: "Localizable"
    )
  }
  /// Показать в попугаях
  internal static var showInParrots: String {
    Bundle.main.localizedString(
      forKey: "Show in Parrots",
      value: nil,
      table: "Localizable"
    )
  }
  /// Третий экран
  internal static var thirdScreen: String {
    Bundle.main.localizedString(
      forKey: "Third Screen",
      value: nil,
      table: "Localizable"
    )
  }
}
