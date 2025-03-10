//
//  DogecoinOutput.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation

public struct DogecoinOutput {
    public let value: UInt64
    
    private let script: Data

    public init?(value: UInt64, address: String) {
        guard let script = Script(address: address)?.data else {
            return nil
        }
        self.value = value
        self.script = script
    }
    
    public init?(value: UInt64, script: Data) {
        self.value = value
        self.script = script
    }
    
    public func serialized() -> Data {
        var data = Data()
        data.appendUInt64(value)
        data.appendVarInt(UInt64(script.count))
        data.append(script)
        return data
    }
}
