//
//  DogecoinSignatureHashHelper.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/24.
//

import Foundation
import CryptoSwift
let ZeroData256 = Data(hex: "0000000000000000000000000000000000000000000000000000000000000000")

public struct DogecoinSignatureHashHelper {
    public let zero: Data = Data(repeating: 0, count: 32)
    public let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

    public let hashType: SighashType
    public init(hashType: SighashType.Doge) {
        self.hashType = hashType
    }

    /// Create the signature hash of the BTC transaction
    ///
    /// - Parameters:
    ///   - tx: Transaction to be signed
    ///   - utxoOutput: TransactionOutput to be signed
    ///   - inputIndex: The index of the transaction output to be signed
    /// - Returns: The signature hash for the transaction to be signed.
    public func createSignatureHash(of tx: DogecoinTransaction, for input: DogecoinInput, inputIndex: Int) -> Data {
        // If inputIndex is out of bounds, DogecoinABC is returning a 256-bit little-endian 0x01 instead of failing with error.
        guard inputIndex < tx.inputs.count else {
            //  tx.inputs[inputIndex] out of range
            return one
        }

        var data: Data
        let rawTransaction = DogecoinTransaction(version: tx.version,
                              inputs: createInputs(of: tx, for: input, inputIndex: inputIndex),
                              outputs: createOutputs(of: tx, inputIndex: inputIndex),
                              lockTime: tx.lockTime)
       data  = rawTransaction.serialized()
        // Modified Raw Transaction to be serialized
        data.appendUInt32(hashType.uint32)
        let hash = data.hash256()
        return hash
    }
    
    /// Create the transaction input to be signed
    public func createSigningInput(of txin: DogecoinInput, from input: DogecoinInput) -> DogecoinInput {
        let subScript = Script(data: input.signatureScript)!
        try! subScript.deleteOccurrences(of: .OP_CODESEPARATOR)
        return DogecoinInput(address:txin.address, prev_hash: txin.prev_hash, index: txin.index,value: txin.value, signatureScript: subScript.data)
    }

    /// Create a blank transaction input
    public func createBlankInput(of txin: DogecoinInput) -> DogecoinInput {
        let sequence: UInt32
        if hashType.isNone || hashType.isSingle {
            sequence = 0
        } else {
            sequence = txin.sequence
        }
        return DogecoinInput(address:txin.address, prev_hash: txin.prev_hash, index: txin.index,value: txin.value, signatureScript: Data(),sequence: sequence)
    }
    
    /// Create the transaction inputs
    public func createInputs(of tx: DogecoinTransaction, for input: DogecoinInput, inputIndex: Int) -> [DogecoinInput] {
        // If SIGHASH_ANYONECANPAY flag is set, only the input being signed is serialized
        if hashType.isAnyoneCanPay {
            return [createSigningInput(of: tx.inputs[inputIndex], from: input)]
        }

        // Otherwise, all inputs are serialized
        var inputs: [DogecoinInput] = []
        for i in 0..<tx.inputs.count {
            let txin = tx.inputs[i]
            if i == inputIndex {
                inputs.append(createSigningInput(of: txin, from: input))
            } else {
                inputs.append(createBlankInput(of: txin))
            }
        }
        return inputs
    }

    /// Create the transaction outputs
    public func createOutputs(of tx: DogecoinTransaction, inputIndex: Int) -> [DogecoinOutput] {
        if hashType.isNone {
            // Wildcard payee - we can pay anywhere.
            return []
        } else if hashType.isSingle {
            // Single mode assumes we sign an output at the same index as an input.
            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = tx.outputs[inputIndex]
            return Array(repeating: DogecoinOutput(value: 0, addressData: Data())!, count: inputIndex) + [myOutput]
        } else {
            return tx.outputs
        }
    }
}
