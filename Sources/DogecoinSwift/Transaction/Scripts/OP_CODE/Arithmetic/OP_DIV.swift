import Foundation

// (x y -- x/y)
public struct OpDiv: OpCodeProtocol {
    public var value: UInt8 { return 0x96 }
    public var name: String { return "OP_DIV" }

    // (x1 x2 -- out)
//    public func mainProcess(_ context: ScriptExecutionContext) throws {
//        try context.assertStackHeightGreaterThanOrEqual(2)
//
//        let x1 = try context.number(at: -2)
//        let x2 = try context.number(at: -1)
//
//        // denominator must not be 0
//        guard x2 != 0 else {
//            throw OpCodeExecutionError.error("Division by zero error")
//        }
//
//        context.stack.removeLast()
//        context.stack.removeLast()
//        try context.pushToStack(x1 / x2)
//    }
}
