//
//  DogeTransaction.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation
import BigInt

public struct DogecoinTransaction {
    public let version: UInt32
    public let flag: UInt16 = 0x00001
    public var txInCount: UInt8 {
        return UInt8(inputs.count)
    }
    public var inputs: [DogecoinInput]
    public var txOutCount: UInt8 {
        return UInt8(outputs.count)
    }
    public var outputs: [DogecoinOutput]
    public let lockTime: UInt32
    
    public let zero: Data = Data(repeating: 0, count: 32)
    
    public let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)
    
    public var fee = BigUInt(0)
    
    public var value = BigUInt(0)
    /// Signature Hash Helper
    public let sighashHelper: DogecoinSignatureHashHelper
    
    public init(version: UInt32,
                inputs:[DogecoinInput] = [DogecoinInput](),
                outputs:[DogecoinOutput] = [DogecoinOutput](),
                lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
        self.sighashHelper = DogecoinSignatureHashHelper(hashType: .ALL)
    }

    public mutating func addInput(input: DogecoinInput) {
        inputs.append(input.getInput())
    }
    
    public mutating func addOutput(output:DogecoinOutput) {
        outputs.append(output)
    }
    
    public mutating func sign(with keys:[DogecoinKey]) throws {
        for (i,input) in inputs.enumerated() {
            let key = keys[i]
            guard let signedInput = input.signedInput(transaction: self, inputIndex: i, key: key) else {
                throw DogecoinError.signError
            }
            self.inputs[i] = signedInput
        }
    }
    
    public func serialized() -> Data {
        var data = Data()
        data.appendUInt32(version)
        data.appendVarInt(UInt64(inputs.count))
        inputs.forEach { input in
            data.appendData(input.serialized())
        }
        data.appendVarInt(UInt64(outputs.count))
        outputs.forEach { output in
            data.appendData(output.serialized())
        }
        data.appendUInt32(lockTime)
        return data
    }
}
