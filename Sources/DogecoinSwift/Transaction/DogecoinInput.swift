//
//  DogecoinInput.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation

public struct DogecoinInput {
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
