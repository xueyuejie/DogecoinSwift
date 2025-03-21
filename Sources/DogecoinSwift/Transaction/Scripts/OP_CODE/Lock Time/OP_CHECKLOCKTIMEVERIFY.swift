import Foundation

// Marks transaction as invalid if the top stack item is greater than the transaction's nLockTime field, otherwise script evaluation continues as though an OP_NOP was executed. Transaction is also invalid if
// 1. the stack is empty; or
// 2. the top stack item is negative; or
// 3. the top stack item is greater than or equal to 500000000 while the transaction's nLockTime field is less than 500000000, or vice versa; or
// 4. the input's nSequence field is equal to 0xffffffff.
// The precise semantics are described in BIP 0065.
public struct OpCheckLockTimeVerify: OpCodeProtocol {
    public var value: UInt8 { return 0xb1 }
    public var name: String { return "OP_CHECKLOCKTIMEVERIFY " }

    // input : x
    // output : x / fail
    public func mainProcess(_ context: ScriptExecutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(1)

        // nLockTime should be Int5
        // reference: https://github.com/Bitcoin-ABC/bitcoin-abc/blob/73c5e7532e19b8f35fcf73255cd1d0df67607cd2/src/script/interpreter.cpp#L420
        let nLockTime = try context.number(at: -1)
        guard nLockTime >= 0 else {
            throw OpCodeExecutionError.error("NEGATIVE_LOCKTIME")
        }

        // checker.CheckLockTime(nLockTime)
        guard let tx = context.transaction, let txin = context.txinToVerify else {
            throw OpCodeExecutionError.error("OP_CHECKLOCKTIMEVERIFY must have a transaction in context.")
        }

        // There are two kinds of nLockTime: lock-by-blockheight and lock-by-blocktime, distinguished by whether nLockTime < LOCKTIME_THRESHOLD.
        //
        // We want to compare apples to apples, so fail the script unless the type of nLockTime being tested is the same as the nLockTime in the transaction.
        guard (tx.lockTime < DOGE_LOCKTIME_THRESHOLD && nLockTime < DOGE_LOCKTIME_THRESHOLD) ||
            (tx.lockTime >= DOGE_LOCKTIME_THRESHOLD && nLockTime >= DOGE_LOCKTIME_THRESHOLD) else {
            throw OpCodeExecutionError.error("tx.lockTime and nLockTime should be the same kind.")
        }

        guard nLockTime <= tx.lockTime  else {
            throw OpCodeExecutionError.error("The top stack item is greater than the transaction's nLockTime field")
        }

        // Finally the nLockTime feature can be disabled and thus
        // CHECKLOCKTIMEVERIFY bypassed if every txin has been finalized by setting
        // nSequence to maxint. The transaction would be allowed into the
        // blockchain, making the opcode ineffective.
        //
        // Testing if this vin is not final is sufficient to prevent this condition.
        // Alternatively we could test all inputs, but testing just this input
        // minimizes the data required to prove correct CHECKLOCKTIMEVERIFY
        // execution.
        let SEQUENCE_FINAL: UInt32 = 0xffffffff
        guard txin.sequence != SEQUENCE_FINAL else {
            throw OpCodeExecutionError.error("The input's nSequence field is equal to 0xffffffff.")
        }
    }
}
