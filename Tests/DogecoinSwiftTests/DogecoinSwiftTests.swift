import XCTest
import Base58Swift
@testable import DogecoinSwift

final class DogecoinSwiftTests: XCTestCase {
    func testExample() throws {
        let mne = "sell athlete diagram club oppose upgrade dinner bonus away rug normal umbrella"
        let rootKey = DogecoinKey.fromMnemonics(mne)!
        do {
            let key = try rootKey.derive(path: DogecoinNetwork.mainnet.extendedPath())
            let childKey = try key.derive(index: 0).derive(index: 0)
            let address = DogecoinAddress(publicKey: childKey.publicKey, network: DogecoinNetwork.mainnet)
            debugPrint(childKey.privateKey!.bytes.base58CheckEncodedString)
            debugPrint(address.address!)
        } catch _ {
            
        }
    }
}
