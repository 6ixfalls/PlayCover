import AppKit
import Foundation

// Minimal application-service stand-ins; compile the real AppSettings.swift.
struct DiscordActivity: Codable {}
struct AppInfo { let bundleIdentifier: String }
enum PlayTools {
    static let playCoverContainer = FileManager.default.temporaryDirectory
        .appendingPathComponent("nikke-settings-tests-" + UUID().uuidString)
}
final class Log {
    static let shared = Log()
    func log(_ text: String, isError: Bool = false) {}
    func error(_ error: Error) {}
}
enum Shell { static func setMetalHUD(_ bundle: String, enabled: Bool) throws {} }

@main
struct AppSettingsTests {
    static func check(_ condition: Bool) { precondition(condition) }

    static let keys = [
        "disableINTLUtilsSwizzling", "unityEngineForceLandscape", "unityEngineDisableOrientationCheck",
        "webViewSmartTextInput", "disableBuiltinGamepad", "nikkeTTSMiniGameShowKeySettings",
        "nikkeTTSMiniGameRemapRightShift"
    ]

    static func plist(_ settings: AppSettings) throws -> [String: Any] {
        let data = try Data(contentsOf: settings.settingsUrl)
        guard let values = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            preconditionFailure("Settings must be a property-list dictionary")
        }
        return values
    }

    static func main() throws {
        defer { try? FileManager.default.removeItem(at: PlayTools.playCoverContainer) }
        let info = AppInfo(bundleIdentifier: "com.proximabeta.nikke")
        let fresh = AppSettings(info)
        for key in keys { check(try plist(fresh)[key] as? Bool == true) }

        // Migrate a pre-bundleIdentifier file; preserve unrelated settings.
        let old: [String: Any] = ["keymapping": false, "windowWidth": 1234]
        try PropertyListSerialization.data(fromPropertyList: old, format: .xml, options: 0)
            .write(to: fresh.settingsUrl)
        let migrated = AppSettings(info)
        precondition(!migrated.settings.keymapping && migrated.settings.windowWidth == 1234)
        for key in keys { check(try plist(migrated)[key] as? Bool == true) }

        migrated.settings.disableINTLUtilsSwizzling = false
        let reopened = AppSettings(info)
        precondition(!reopened.settings.disableINTLUtilsSwizzling, "Explicit false must survive migration")
        reopened.reset()
        precondition(reopened.settings.disableINTLUtilsSwizzling, "Reset must restore the NIKKE preset")

        let other = AppSettings(AppInfo(bundleIdentifier: "com.example.other"))
        for key in keys { check(try plist(other)[key] as? Bool == false) }
        print("NIKKE settings migration tests passed")
    }
}
