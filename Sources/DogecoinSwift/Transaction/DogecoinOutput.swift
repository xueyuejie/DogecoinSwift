//
//  DogecoinOutput.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation

public struct DogecoinOutput {
    public let value: UInt64
    
    private let addressData: Data

    public init?(value: UInt64, address: String) {
        guard let addressData = DogecoinAddress.decodeAddress(address) else {
            return nil
        }
        self.value = value
        self.addressData = addressData
    }
    
    public init?(value: UInt64, addressData: Data) {
        self.value = value
        self.addressData = addressData
    }
    
    public func serialized() -> Data {
        var data = Data()
        data.appendUInt64(value)
        data.appendVarInt(UInt64(addressData.count))
        data.append(addressData)
        return data
    }
}
