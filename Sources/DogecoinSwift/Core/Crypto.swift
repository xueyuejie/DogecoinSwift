//
//  Crypto.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/24.
//

import Foundation
import CSecp256k1

public struct Crypto {

    public enum CryptoError: Error {
        case signFailed
        case notEnoughSpace
        case signatureParseFailed
        case publicKeyParseFailed
    }
    
    public static func sign(_ data: Data, privateKey: Data) throws -> Data {
        precondition(data.count > 0, "Data must be non-zero size")
        precondition(privateKey.count > 0, "PrivateKey must be non-zero size")

        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }

        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        let status = data.withUnsafeBytes { ptr in
            privateKey.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr.baseAddress!.assumingMemoryBound(to: UInt8.self), $0.baseAddress!.assumingMemoryBound(to: UInt8.self), nil, nil) }
        }
        guard status == 1 else { throw CryptoError.signFailed }

        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)

        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_der(ctx, $0.baseAddress!.assumingMemoryBound(to: UInt8.self), &length, normalizedsig) }) == 1 else { throw CryptoError.notEnoughSpace }
        der.count = length

        return der
    }

    public static func verifySignature(_ signature: Data, message: Data, publicKey: Data) throws -> Bool {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(ctx) }

        let signaturePointer = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signaturePointer.deallocate() }
        guard signature.withUnsafeBytes({ secp256k1_ecdsa_signature_parse_der(ctx, signaturePointer, $0, signature.count) }) == 1 else {
            throw CryptoError.signatureParseFailed
        }

        let pubkeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkeyPointer.deallocate() }
        guard publicKey.withUnsafeBytes({ secp256k1_ec_pubkey_parse(ctx, pubkeyPointer, $0, publicKey.count) }) == 1 else {
            throw CryptoError.publicKeyParseFailed
        }

        guard message.withUnsafeBytes ({ secp256k1_ecdsa_verify(ctx, signaturePointer, $0, pubkeyPointer) }) == 1 else {
            return false
        }

        return true
    }
}
