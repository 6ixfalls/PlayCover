// Pattern from viatearz/PlayCover (AGPL-3.0), with uniqueness and instruction guards.
import Foundation

enum NikkeMiniGamePatch {
    enum PatchError: Error {
        case unsupportedBinary
        case ambiguousPattern
        case unexpectedInstruction
    }

    static let pattern = Data([
        0xFA, 0x03, 0x13, 0xAA, 0x59, 0x8F, 0x05, 0xF8,
        0xE0, 0x03, 0x1A, 0xAA, 0xE1, 0x03, 0x19, 0xAA
    ])
    static let originalInstruction = Data([0xE1, 0x03, 0x00, 0xAA]) // mov x1, x0
    static let patchedInstruction = Data([0x21, 0x00, 0x80, 0xD2])  // mov x1, #1

    // Return false for an already-correct binary. Unknown versions are never modified.
    static func apply(to binary: inout Data, enabled: Bool) throws -> Bool {
        guard binary.count >= 32, binary.prefix(4) == Data([0xCF, 0xFA, 0xED, 0xFE]),
              binary[4..<8] == Data([0x0C, 0x00, 0x00, 0x01]),
              let match = binary.range(of: pattern), match.lowerBound >= 16 else {
            throw PatchError.unsupportedBinary
        }
        guard binary.range(of: pattern, in: match.upperBound..<binary.endIndex) == nil else {
            throw PatchError.ambiguousPattern
        }
        let offset = match.lowerBound - 16
        let instruction = binary.subdata(in: offset..<offset + 4)
        guard instruction == originalInstruction || instruction == patchedInstruction else {
            throw PatchError.unexpectedInstruction
        }
        let desired = enabled ? patchedInstruction : originalInstruction
        guard instruction != desired else { return false }
        binary.replaceSubrange(offset..<offset + 4, with: desired)
        return true
    }
}
