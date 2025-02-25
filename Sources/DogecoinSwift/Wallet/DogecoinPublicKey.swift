//
//  DogecoinPublicKey.swift
//  
//
//  Created by xgblin on 2021/12/28.
//

import Foundation
import CSecp256k1

public struct DogecoinPublicKey {
    public let data: Data
    public var pubKeyHash: Data {
        return data.hash160()!
    }
    public let network: DogecoinNetwork
    public let isCompressed: Bool

    public init(bytes data: Data, network: DogecoinNetwork = .mainnet) {
        self.data = data
        self.network = network
        let header = data[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
    }
}

extension DogecoinPublicKey {
    public static func verifySigData(for tx: DogecoinTransaction, inputIndex: Int, input: DogecoinInput, sigData: Data, pubKeyData: Data) throws -> Bool {
        // Hash type is one byte tacked on to the end of the signature. So the signature shouldn't be empty.
        guard !sigData.isEmpty else {
            throw ScriptMachineError.error("SigData is empty.")
        }
        // Extract hash type from the last byte of the signature.
        let helper: DogecoinSignatureHashHelper
        if let hashType = DogeSighashType(rawValue: sigData.last!) {
            helper = DogecoinSignatureHashHelper(hashType: hashType)
        } else {
            throw ScriptMachineError.error("Unknown sig hash type")
        }
        // Strip that last byte to have a pure signature.
        let sighash: Data = helper.createSignatureHash(of: tx, for: input, inputIndex: inputIndex)
        let signature: Data = sigData.dropLast()

        return try Crypto.verifySignature(signature, message: sighash, publicKey: pubKeyData)
    }
}

//extension DogecoinPublicKey {
//    public func toAddress() -> Address {
//        return try! Address(data: pubKeyHash, hashType: .pubKeyHash, network: network)
//    }
//}

extension DogecoinPublicKey: Equatable {
    public static func == (lhs: DogecoinPublicKey, rhs: DogecoinPublicKey) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data
    }
}

extension DogecoinPublicKey: CustomStringConvertible {
    public var description: String {
        return data.toHexString()
    }
}

