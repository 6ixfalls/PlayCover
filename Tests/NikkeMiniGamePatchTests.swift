import Foundation

@main
struct NikkeMiniGamePatchTests {
    static func check(_ condition: Bool) { precondition(condition) }

    static func fixture() -> Data {
        var data = Data(repeating: 0, count: 64)
        data.replaceSubrange(0..<8, with: [0xCF, 0xFA, 0xED, 0xFE, 0x0C, 0, 0, 1])
        data.append(NikkeMiniGamePatch.originalInstruction)
        data.append(Data(repeating: 0, count: 12))
        data.append(NikkeMiniGamePatch.pattern)
        return data
    }

    static func rejected(_ data: Data) {
        var candidate = data
        do {
            _ = try NikkeMiniGamePatch.apply(to: &candidate, enabled: true)
            fatalError("Unsafe or unsupported patch accepted")
        } catch {
            precondition(candidate == data, "Rejection modified the binary")
        }
    }

    static func main() throws {
        let original = fixture()
        var data = original
        check(try NikkeMiniGamePatch.apply(to: &data, enabled: true))
        precondition(data.count == original.count)
        precondition(data[64..<68] == NikkeMiniGamePatch.patchedInstruction)
        check(!(try NikkeMiniGamePatch.apply(to: &data, enabled: true)))
        check(try NikkeMiniGamePatch.apply(to: &data, enabled: false))
        precondition(data == original, "Disabling the patch must restore the original instruction")
        rejected(Data())
        var ambiguous = fixture()
        ambiguous.append(NikkeMiniGamePatch.pattern)
        rejected(ambiguous)
        var unknownInstruction = fixture()
        unknownInstruction[64] = 0
        rejected(unknownInstruction)
        var wrongArchitecture = fixture()
        wrongArchitecture[4] = 7
        rejected(wrongArchitecture)
        if CommandLine.arguments.count == 2 {
            let url = URL(fileURLWithPath: CommandLine.arguments[1])
            let actual = try Data(contentsOf: url)
            var patched = actual
            check(try NikkeMiniGamePatch.apply(to: &patched, enabled: true))
            check(try NikkeMiniGamePatch.apply(to: &patched, enabled: false))
            precondition(patched == actual, "Real IPA round trip changed other bytes")
        }
        print("NIKKE patch tests passed")
    }
}
