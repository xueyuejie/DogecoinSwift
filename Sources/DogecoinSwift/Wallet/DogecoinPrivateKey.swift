import Foundation
import Secp256k1Swift

public struct DogecoinPrivateKey {
    public let data: Data
    public let network: DogecoinNetwork
    public let isPublicKeyCompressed: Bool

    public init(network: DogecoinNetwork = .testnet, isPublicKeyCompressed: Bool = true) {
        self.network = network
        self.isPublicKeyCompressed = isPublicKeyCompressed

        // Check if vch is greater than or equal to max value
        func check(_ vch: [UInt8]) -> Bool {
            let max: [UInt8] = [
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
                0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
                0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x40
            ]
            var fIsZero = true
            for byte in vch where byte != 0 {
                fIsZero = false
                break
            }
            if fIsZero {
                return false
            }
            for (index, byte) in vch.enumerated() {
                if byte < max[index] {
                    return true
                }
                if byte > max[index] {
                    return false
                }
            }
            return true
        }

        let count = 32
        var key = Data(count: count)
        var status: Int32 = 0
        repeat {
            status = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress.unsafelyUnwrapped) }
        } while (status != 0 || !check([UInt8](key)))

        self.data = key
    }

    public init(data: Data, network: DogecoinNetwork = .testnet, isPublicKeyCompressed: Bool = true) {
        self.data = data
        self.network = network
        self.isPublicKeyCompressed = isPublicKeyCompressed
    }

    private func computePublicKeyData() -> Data? {
        guard let pubKey = SECP256K1.privateToPublic(privateKey: data, compressed: true) else {return nil}
        if pubKey[0] != 0x02 && pubKey[0] != 0x03 {return nil}
        return pubKey
    }

    // TODO: check what is this needed for
    // public func publicKeyPoint() throws -> PointOnCurve {
    //     let xAndY: Data = _SwiftKey.computePublicKey(fromPrivateKey: data, compression: false)
    //     let expectedLengthOfScalar = Scalar32Bytes.expectedByteCount
    //     let expectedLengthOfKey = expectedLengthOfScalar * 2
    //     guard xAndY.count == expectedLengthOfKey else {
    //         fatalError("expected length of key is \(expectedLengthOfKey) bytes, but got: \(xAndY.count)")
    //     }
    //     let x = xAndY.prefix(expectedLengthOfScalar)
    //     let y = xAndY.suffix(expectedLengthOfScalar)
    //     return try PointOnCurve(x: x, y: y)
    // }

    public func publicKey() -> DogecoinPublicKey? {
        guard let data = computePublicKeyData() else {
            return nil
        }
        return DogecoinPublicKey(bytes: data, network: network)
    }
}

extension DogecoinPrivateKey: Equatable {
    public static func == (lhs: DogecoinPrivateKey, rhs: DogecoinPrivateKey) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data
    }
}


public enum PrivateKeyError: Error {
    case invalidFormat
}
