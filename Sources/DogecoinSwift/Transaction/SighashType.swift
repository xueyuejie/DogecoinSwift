//
//  SighashType.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/24.
//

import Foundation
public let SIGHASH_ALL: UInt8 = 0x01 // 00000001
public let SIGHASH_NONE: UInt8 = 0x02 // 00000010
public let SIGHASH_SINGLE: UInt8 = 0x03 // 00000011
public let SIGHASH_FORK_ID: UInt8 = 0x40 // 01000000
public let SIGHASH_ANYONECANPAY: UInt8 = 0x80 // 10000000

public let SIGHASH_OUTPUT_MASK: UInt8 = 0x1f // 00011111

public protocol SighashType {
    var rawValue: UInt8 { get }
}

public extension SighashType {
    var uint8: UInt8 { return rawValue }
    var uint32: UInt32 { return UInt32(rawValue) }

    private var outputType: UInt8 {
        return self.uint8 & SIGHASH_OUTPUT_MASK
    }
    var isAll: Bool {
        return outputType == SIGHASH_ALL
    }
    var isSingle: Bool {
        return outputType == SIGHASH_SINGLE
    }
    var isNone: Bool {
        return outputType == SIGHASH_NONE
    }

    var hasForkId: Bool {
        return (self.uint8 & SIGHASH_FORK_ID) != 0
    }
    var isAnyoneCanPay: Bool {
        return (self.uint8 & SIGHASH_ANYONECANPAY) != 0
    }
}

extension SighashType {
    public typealias Doge = DogeSighashType
}

// MARK: Doge SighashType
public enum DogeSighashType: SighashType {
    case ALL, NONE, SINGLE, ALL_ANYONECANPAY, NONE_ANYONECANPAY, SINGLE_ANYONECANPAY
    public init?(rawValue: UInt8) {
        switch rawValue {
        case DogeSighashType.ALL.rawValue: self = .ALL
        case DogeSighashType.NONE.rawValue: self = .NONE
        case DogeSighashType.SINGLE.rawValue: self = .SINGLE
        case DogeSighashType.ALL_ANYONECANPAY.rawValue: self = .ALL_ANYONECANPAY
        case DogeSighashType.NONE_ANYONECANPAY.rawValue: self = .NONE_ANYONECANPAY
        case DogeSighashType.SINGLE_ANYONECANPAY.rawValue: self = .SINGLE_ANYONECANPAY
        default: return nil
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .ALL: return SIGHASH_ALL // 00000001
        case .NONE: return SIGHASH_NONE // 00000010
        case .SINGLE: return SIGHASH_FORK_ID + SIGHASH_SINGLE // 00000011
        case .ALL_ANYONECANPAY: return SIGHASH_ALL + SIGHASH_ANYONECANPAY // 10000001
        case .NONE_ANYONECANPAY: return SIGHASH_NONE + SIGHASH_ANYONECANPAY // 10000010
        case .SINGLE_ANYONECANPAY: return SIGHASH_SINGLE + SIGHASH_ANYONECANPAY // 10000011
        }
    }
}
