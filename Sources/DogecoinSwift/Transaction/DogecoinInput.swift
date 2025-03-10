//
//  DogecoinInput.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation

public class DogecoinInput {
    public var pub: String
    public var path: String
    public let address: String
    public let prev_hash: Data
    public let index: UInt32
    public let value: UInt64
    public let sequence: UInt32
    public var signatureScript: Data
    
    public init(address: String,
         prev_hash: Data,
         index: UInt32,
         value: UInt64,
         signatureScript: Data,
         sequence: UInt32 = 0xffffffff,
         pub: String = "",
         path: String = "") {
        self.address = address
        self.prev_hash = prev_hash
        self.index = index
        self.value = value
        self.signatureScript = signatureScript
        self.sequence = sequence
        self.pub = pub
        self.path = path
    }
    
    func getInput() -> DogecoinInput {
        return DogecoinInput(
            address: self.address,
            prev_hash: Data(self.prev_hash.reversed()),
            index: self.index,
            value: self.value,
            signatureScript: self.signatureScript,
            sequence: self.sequence,
            pub: self.pub,
            path: self.path
        )
    }
    
    func signedInput(transaction: DogecoinTransaction, inputIndex: Int, key: DogecoinKey) -> DogecoinInput?{
        let sighash: Data = transaction.sighashHelper.createSignatureHash(of: transaction, for: self, inputIndex: inputIndex)
        var signature: Data
        do {
            signature = try Crypto.sign(sighash, privateKey: key.privateKey!)
        } catch {
            return nil
        }
        signature.appendUInt8(0x01)
        // Create Signature Script
        var unlockingScript: Script
        do {
            unlockingScript = try Script()
                .appendData(signature)
                .appendData(key.publicKey)
        } catch {
            return nil
        }
        self.signatureScript = unlockingScript.data
        return self
    }
    
    func serialized() -> Data {
        var data = Data()
        data.append(prev_hash)
        data.appendUInt32(index)
        data.appendVarInt(UInt64(signatureScript.count))
        data.append(signatureScript)
        data.appendUInt32(sequence)
        return data
    }
}
