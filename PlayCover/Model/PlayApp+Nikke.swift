import Foundation

extension PlayApp {
    func applyNikkeMiniGameSettings() throws {
        guard info.bundleIdentifier == NikkeSettings.bundleIdentifier else { return }
        let framework = url.appendingPathComponent("Frameworks/UnityFramework.framework/UnityFramework")
        guard FileManager.default.fileExists(atPath: framework.path) else { return }
        var binary = try Data(contentsOf: framework)
        do {
            if try NikkeMiniGamePatch.apply(to: &binary,
                                           enabled: settings.settings.nikkeTTSMiniGameShowKeySettings) {
                let permissions = try FileManager.default.attributesOfItem(atPath: framework.path)[.posixPermissions]
                try binary.write(to: framework, options: .atomic)
                if let permissions = permissions {
                    try FileManager.default.setAttributes(
                        [.posixPermissions: permissions], ofItemAtPath: framework.path)
                }
                try Shell.signMacho(framework)
                sign()
            }
        } catch is NikkeMiniGamePatch.PatchError {
            Log.shared.log("NIKKE rhythm-game controls patch is unsupported for this binary; left unchanged.")
        }
    }
}
