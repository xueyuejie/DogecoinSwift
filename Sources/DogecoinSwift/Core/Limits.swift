//
//  File.swift
//  DogecoinSwift
//
//  Created by 薛跃杰 on 2025/2/25.
//

import Foundation


// P2SH BIP16 didn't become active until Apr 1 2012. All txs before this timestamp should not be verified with P2SH rule.
let DOGE_BIP16_TIMESTAMP: UInt32 = 1_333_238_400

// Scripts longer than 10000 bytes are invalid.
let DOGE_MAX_SCRIPT_SIZE: Int = 10_000

// Maximum number of bytes per "pushdata" operation
let DOGE_MAX_SCRIPT_ELEMENT_SIZE: Int = 520; // bytes
// Number of public keys allowed for OP_CHECKMULTISIG
let DOGE_MAX_KEYS_FOR_CHECKMULTISIG: Int = 20

// Maximum number of operations allowed per script (excluding pushdata operations and OP_<N>)
// Multisig op additionally increases count by a number of pubkeys.
let DOGE_MAX_OPS_PER_SCRIPT: Int = 201

// If locktime is greater than or equal to threshold it's a Unix timestamp.
// If less it's a block number.
let DOGE_LOCKTIME_THRESHOLD: UInt32 = 500_000_000
