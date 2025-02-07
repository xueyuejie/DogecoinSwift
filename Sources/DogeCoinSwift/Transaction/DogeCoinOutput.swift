//
//  DogeCoinOutput.swift
//  DogeCoinSwift
//
//  Created by 薛跃杰 on 2025/2/6.
//

import Foundation

public struct DogeCoinOutput {
    public let value: UInt64
    public let address: DogeCoinAddress
    
    private let addressData: Data

    public init?(value: UInt64, address: DogeCoinAddress) {
        guard let addressData = address.addressData else {
            return nil
        }
        self.value = value
        self.address = address
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
