//
//  AppSettings.swift
//  PlayCover
//

import AppKit
import Foundation
import UniformTypeIdentifiers

struct AppSettingsData: Codable {
    var bundleIdentifier: String = ""

    var keymapping = true
    var sensitivity: Float = 50

    var disableTimeout = false
    var displayRotation = 0
    var iosDeviceModel = "iPad13,8"
    var windowWidth = 1920
    var windowHeight = 1080
    var customScaler = 2.0
    var resolution = 1
    var aspectRatio = 1
    var notch: Bool = NSScreen.hasNotch()
    var bypass = false
    var discordActivity = DiscordActivity()
    var version = "3.0.0"
    var playChain = true
    var playChainDebugging = false
    var inverseScreenValues = false
    var metalHUD = false {
        didSet {
            do {
                try Shell.setMetalHUD(bundleIdentifier, enabled: metalHUD)
            } catch {
                Log.shared.error(error)
            }
        }
    }
    var windowFixMethod = 0
    var injectIntrospection = false
    var rootWorkDir = true
    var noKMOnInput = true
    var enableScrollWheel = true
    var hideTitleBar = false
    var floatingWindow = false
    var checkMicPermissionSync = false
    var limitMotionUpdateFrequency = false
    var disableBuiltinMouse = false
    var resizableAspectRatioType = 0
    var resizableAspectRatioWidth = 0
    var resizableAspectRatioHeight = 0
    var blockSleepSpamming = false
    var ignoreUnityKeyboardInitializationError = false

    var disableINTLUtilsSwizzling = false
    var unityEngineForceLandscape = false
    var unityEngineDisableOrientationCheck = false
    var webViewSmartTextInput = false
    var disableBuiltinGamepad = false
    var nikkeTTSMiniGameShowKeySettings = false
    var nikkeTTSMiniGameRemapRightShift = false

    init() {}

    // handle old 2.x settings where PlayChain did not exist yet
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier) ?? ""
        keymapping = try container.decodeIfPresent(Bool.self, forKey: .keymapping) ?? true
        sensitivity = try container.decodeIfPresent(Float.self, forKey: .sensitivity) ?? 50
        disableTimeout = try container.decodeIfPresent(Bool.self, forKey: .disableTimeout) ?? false
        displayRotation = try container.decodeIfPresent(Int.self, forKey: .displayRotation) ?? 0
        iosDeviceModel = try container.decodeIfPresent(String.self, forKey: .iosDeviceModel) ?? "iPad13,8"
        windowWidth = try container.decodeIfPresent(Int.self, forKey: .windowWidth) ?? 1920
        windowHeight = try container.decodeIfPresent(Int.self, forKey: .windowHeight) ?? 1080
        customScaler = try container.decodeIfPresent(Double.self, forKey: .customScaler) ?? 2.0
        resolution = try container.decodeIfPresent(Int.self, forKey: .resolution) ?? 1
        aspectRatio = try container.decodeIfPresent(Int.self, forKey: .aspectRatio) ?? 1
        notch = try container.decodeIfPresent(Bool.self, forKey: .notch) ?? NSScreen.hasNotch()
        bypass = try container.decodeIfPresent(Bool.self, forKey: .bypass) ?? false
        discordActivity = try container.decodeIfPresent(DiscordActivity.self,
                                                        forKey: .discordActivity) ?? DiscordActivity()
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? "3.0.0"
        playChain = try container.decodeIfPresent(Bool.self, forKey: .playChain) ?? true
        playChainDebugging = try container.decodeIfPresent(Bool.self, forKey: .playChainDebugging) ?? false
        inverseScreenValues = try container.decodeIfPresent(Bool.self, forKey: .inverseScreenValues) ?? false
        metalHUD = try container.decodeIfPresent(Bool.self, forKey: .metalHUD) ?? false
        windowFixMethod = try container.decodeIfPresent(Int.self, forKey: .windowFixMethod) ?? 0
        injectIntrospection = try container.decodeIfPresent(Bool.self, forKey: .injectIntrospection) ?? false
        rootWorkDir = try container.decodeIfPresent(Bool.self, forKey: .rootWorkDir) ?? true
        noKMOnInput = try container.decodeIfPresent(Bool.self, forKey: .noKMOnInput) ?? true
        enableScrollWheel = try container.decodeIfPresent(Bool.self, forKey: .enableScrollWheel) ?? true
        hideTitleBar = try container.decodeIfPresent(Bool.self, forKey: .hideTitleBar) ?? false
        floatingWindow = try container.decodeIfPresent(Bool.self, forKey: .floatingWindow) ?? false
        checkMicPermissionSync = try container.decodeIfPresent(Bool.self, forKey: .checkMicPermissionSync) ?? false
        limitMotionUpdateFrequency = try container.decodeIfPresent(Bool.self,
                                                                   forKey: .limitMotionUpdateFrequency) ?? false
        disableBuiltinMouse = try container.decodeIfPresent(Bool.self, forKey: .disableBuiltinMouse) ?? false
        resizableAspectRatioType = try container.decodeIfPresent(Int.self, forKey: .resizableAspectRatioType) ?? 0
        resizableAspectRatioWidth = try container.decodeIfPresent(Int.self, forKey: .resizableAspectRatioWidth) ?? 0
        resizableAspectRatioHeight = try container.decodeIfPresent(Int.self, forKey: .resizableAspectRatioHeight) ?? 0
        blockSleepSpamming = try container.decodeIfPresent(Bool.self, forKey: .blockSleepSpamming) ?? false
        ignoreUnityKeyboardInitializationError = try container.decodeIfPresent(
            Bool.self, forKey: .ignoreUnityKeyboardInitializationError) ?? false
        try decodeNikkeSettings(from: container)
    }

    private mutating func decodeNikkeSettings(from container: KeyedDecodingContainer<CodingKeys>) throws {
        let nikkeDefaults = NikkeSettings.defaults(bundleIdentifier: bundleIdentifier)
        disableINTLUtilsSwizzling = try container.decodeIfPresent(Bool.self, forKey: .disableINTLUtilsSwizzling)
            ?? nikkeDefaults["disableINTLUtilsSwizzling"] ?? false
        unityEngineForceLandscape = try container.decodeIfPresent(Bool.self, forKey: .unityEngineForceLandscape)
            ?? nikkeDefaults["unityEngineForceLandscape"] ?? false
        unityEngineDisableOrientationCheck = try container.decodeIfPresent(
            Bool.self, forKey: .unityEngineDisableOrientationCheck)
            ?? nikkeDefaults["unityEngineDisableOrientationCheck"] ?? false
        webViewSmartTextInput = try container.decodeIfPresent(Bool.self, forKey: .webViewSmartTextInput)
            ?? nikkeDefaults["webViewSmartTextInput"] ?? false
        disableBuiltinGamepad = try container.decodeIfPresent(Bool.self, forKey: .disableBuiltinGamepad)
            ?? nikkeDefaults["disableBuiltinGamepad"] ?? false
        nikkeTTSMiniGameShowKeySettings = try container.decodeIfPresent(
            Bool.self, forKey: .nikkeTTSMiniGameShowKeySettings)
            ?? nikkeDefaults["nikkeTTSMiniGameShowKeySettings"] ?? false
        nikkeTTSMiniGameRemapRightShift = try container.decodeIfPresent(
            Bool.self, forKey: .nikkeTTSMiniGameRemapRightShift)
            ?? nikkeDefaults["nikkeTTSMiniGameRemapRightShift"] ?? false
    }
}

class AppSettings {
    static var appSettingsDir: URL {
        let settingsFolder =
            PlayTools.playCoverContainer.appendingPathComponent("App Settings")
        if !FileManager.default.fileExists(atPath: settingsFolder.path) {
            do {
                try FileManager.default.createDirectory(at: settingsFolder,
                                                        withIntermediateDirectories: true,
                                                        attributes: [:])
            } catch {
                Log.shared.error(error)
            }
        }
        return settingsFolder
    }

    let info: AppInfo
    let settingsUrl: URL
    var openWithLLDB: Bool = false
    var openLLDBWithTerminal: Bool = true
    private var suppressPersistence = false
    var settings: AppSettingsData {
        didSet {
            if !suppressPersistence { encode() }
        }
    }

    init(_ info: AppInfo) {
        self.info = info
        settingsUrl = AppSettings.appSettingsDir.appendingPathComponent(info.bundleIdentifier)
                                                .appendingPathExtension("plist")
        var defaults = AppSettingsData()
        defaults.bundleIdentifier = info.bundleIdentifier
        defaults.applyNikkeDefaults()
        settings = defaults
        if !decode() {
            preserveUnreadableSettingsIfPresent()
            encode()
        }

        if settings.bundleIdentifier != info.bundleIdentifier {
            settings.bundleIdentifier = info.bundleIdentifier
        }
        // Persist newly introduced defaults for the injected framework as well.
        if info.bundleIdentifier == NikkeSettings.bundleIdentifier { encode() }
    }

    public func sync() {
        var updatedSettings = settings
        updatedSettings.notch = NSScreen.hasNotch()
        if updatedSettings.resolution == 1 {
            let resolution = AppSettings.autoResolution()
            updatedSettings.windowWidth = resolution.width
            updatedSettings.windowHeight = resolution.height
        }
        settings = updatedSettings
    }

    static func autoResolution() -> (width: Int, height: Int) {
        let width = Int(NSScreen.main?.frame.width ?? 1920)
        let height = Int(NSScreen.main?.frame.height ?? 1080)
        let wFloat = Float(width)
        let hFloat = Float(height)
        if NSScreen.hasNotch() && (hFloat/wFloat)*16.0 > 10.3 && (hFloat/wFloat)*16.0 < 10.4 {
            return (width, Int((wFloat / 16) * 10))
        } else {
            return (width, height)
        }
    }

    public func reset() {
        var defaults = AppSettingsData()
        defaults.bundleIdentifier = info.bundleIdentifier
        defaults.applyNikkeDefaults()
        settings = defaults
    }

    @discardableResult
    public func decode() -> Bool {
        do {
            var data = try Data(contentsOf: settingsUrl)
            // Some older settings files predate the bundleIdentifier field.
            if var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
               plist["bundleIdentifier"] == nil {
                plist["bundleIdentifier"] = info.bundleIdentifier
                data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            }
            let decoded = try PropertyListDecoder().decode(AppSettingsData.self, from: data)
            suppressPersistence = true
            settings = decoded
            suppressPersistence = false
            return true
        } catch {
            suppressPersistence = false
            if FileManager.default.fileExists(atPath: settingsUrl.path) {
                Log.shared.log(
                    "App settings decode failed for \(info.bundleIdentifier): \(error.localizedDescription)",
                    isError: true
                )
            }
            return false
        }
    }

    @discardableResult
    public func encode() -> Bool {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(settings)
            try data.write(to: settingsUrl, options: .atomic)
            return true
        } catch {
            Log.shared.log(
                "App settings write failed for \(info.bundleIdentifier): \(error.localizedDescription)",
                isError: true
            )
            return false
        }
    }

    private func preserveUnreadableSettingsIfPresent() {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: settingsUrl.path) else { return }
        let backupURL = settingsUrl.deletingPathExtension().appendingPathExtension("invalid.plist")
        do {
            try? fileManager.removeItem(at: backupURL)
            try fileManager.copyItem(at: settingsUrl, to: backupURL)
            Log.shared.log("Preserved unreadable app settings at \(backupURL.path)", isError: true)
        } catch {
            Log.shared.log(
                "Failed to preserve unreadable app settings for \(info.bundleIdentifier): " +
                    error.localizedDescription,
                isError: true
            )
        }
    }
}

extension NSScreen {
    public static func hasNotch() -> Bool {
        guard #available(macOS 12, *) else { return false }
        // check if any of the connected screens contains a notch
        return NSScreen.screens.contains { $0.safeAreaInsets.top != 0 }
    }

    private static func getMacModel() -> String? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?

        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0)
            .takeRetainedValue() as? Data {
            if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
                modelIdentifier = String(cString: modelIdentifierCString)
            }
        }
        IOObjectRelease(service)
        return modelIdentifier
    }
}

// Defaults are applied only to missing keys, so existing per-app choices survive upgrades.
enum NikkeSettings {
    static let bundleIdentifier = "com.proximabeta.nikke"

    static func defaults(bundleIdentifier: String) -> [String: Bool] {
        guard bundleIdentifier == self.bundleIdentifier,
              let url = Bundle.main.url(forResource: bundleIdentifier, withExtension: "json",
                                        subdirectory: "AppSettingsOverrides"),
              let data = try? Data(contentsOf: url),
              let defaults = try? JSONDecoder().decode([String: Bool].self, from: data) else { return [:] }
        return defaults
    }
}

extension AppSettingsData {
    mutating func applyNikkeDefaults() {
        let defaults = NikkeSettings.defaults(bundleIdentifier: bundleIdentifier)
        disableINTLUtilsSwizzling = defaults["disableINTLUtilsSwizzling"] ?? false
        unityEngineForceLandscape = defaults["unityEngineForceLandscape"] ?? false
        unityEngineDisableOrientationCheck = defaults["unityEngineDisableOrientationCheck"] ?? false
        webViewSmartTextInput = defaults["webViewSmartTextInput"] ?? false
        disableBuiltinGamepad = defaults["disableBuiltinGamepad"] ?? false
        nikkeTTSMiniGameShowKeySettings = defaults["nikkeTTSMiniGameShowKeySettings"] ?? false
        nikkeTTSMiniGameRemapRightShift = defaults["nikkeTTSMiniGameRemapRightShift"] ?? false
    }
}
