//
//  Data+Extension.swift
//  DogecoinSwift
//
//  Created by xgblin on 2025/1/7.
//

import Foundation
import CryptoSwift
import RIPEMDSwift

public extension Data {
    func hash160() -> Data? {
        return try? RIPEMD160.hash(message: self.sha256())
    }
    
    func hash256() -> Data {
        return self.sha256().sha256()
    }
}

extension Data {
    mutating func appendUInt8(_ i: UInt8) {
        self.append(i)
    }
    
    mutating func appendUInt16(_ i: UInt16) {
        var t = CFSwapInt16HostToLittle(i)
        self.append(Data(bytes: &t, count: MemoryLayout<UInt16>.size) )
    }
    
    mutating func appendUInt32(_ i: UInt32) {
        var t = CFSwapInt32HostToLittle(i)
        self.append(Data(bytes: &t, count: MemoryLayout<UInt32>.size) )
    }
    
    mutating func appendUInt64(_ i: UInt64) {
        var t = CFSwapInt64HostToLittle(i)
        self.append(Data(bytes: &t, count: MemoryLayout<UInt64>.size) )
    }
    
    mutating func appendVarInt(_ value: UInt64) {
        switch value {
          case 0..<0xfd:
            appendUInt8(UInt8(value))
          case 0xfd...0xffff:
            appendUInt8(0xfd)
            appendUInt16(UInt16(value))
          case 0x010000...0xffffffff:
            appendUInt8(0xfe)
            appendUInt32(UInt32(value))
          default:
            appendUInt8(0xff)
            appendUInt64(value)
        }
    }
        
    mutating func appendString(_ string: String) {
        self.append(string.data(using:.utf8)!)
    }
    
    mutating func appendBytes(_ bytes: [UInt8]) {
        self.append(Data(bytes))
    }
    
    mutating func appendData(_ data: Data) {
        self.append(data)
    }
}

//extension Data {
//    func readUInt8(at offset: Int) -> UInt8 {
//        return self.bytes[offset]
//    }
//    
//    func readUInt16(at offset: Int) -> UInt16 {
//        let size = MemoryLayout<UInt16>.size
//        if self.count < offset + size { return 0 }
//        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
//            return CFSwapInt16LittleToHost($0.load(as: UInt16.self))
//        }
//    }
//    
//    func readUInt32(at offset: Int) -> UInt32 {
//        let size = MemoryLayout<UInt32>.size
//        if self.count < offset + size { return 0 }
//        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
//            return CFSwapInt32LittleToHost($0.load(as: UInt32.self))
//        }
//    }
//    
//    func readUInt64(at offset: Int) -> UInt64 {
//        let size = MemoryLayout<UInt64>.size
//        if self.count < offset + size { return 0 }
//        return self.subdata(in: offset..<(offset + size)).withUnsafeBytes {
//            return CFSwapInt64LittleToHost($0.load(as: UInt64.self))
//        }
//    }
//    
//    func readVarInt(at offset: Int) -> UInt64 {
//        let uint8 = readUInt8(at: offset)
//        switch uint8 {
//        case 0..<0xfd:
//            return UInt64(uint8)
//        case 0xfd:
//            return UInt64(readUInt16(at: offset + 1))
//        case 0xfe:
//            return UInt64(readUInt32(at: offset + 1))
//        case 0xff:
//            return readUInt64(at: offset + 1)
//        default:
//            return 0
//        }
//    }
//    
//    func readString(at offset: Int, len: Int) -> String {
//        return String(data: self.subdata(in: offset..<(offset + len)), encoding: .utf8) ?? ""
//    }
//    
//    func readBytes(at offset: Int, len: Int) -> [UInt8] {
//        return self.subdata(in: offset..<(offset + len)).bytes
//    }
//    
//    func readData(at offset: Int, len: Int) -> Data {
//        return self.subdata(in: offset..<(offset + len))
//    }
//}
