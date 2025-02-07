import XCTest
import Base58Swift
@testable import DogeCoinSwift

final class DogeCoinSwiftTests: XCTestCase {
    func testExample() throws {
        let mne = "sell athlete diagram club oppose upgrade dinner bonus away rug normal umbrella"
        let rootKey = DogeCoinKey.fromMnemonics(mne)!
        do {
            let key = try rootKey.derive(path: DogeCoinNetwork.mainnet.extendedPath())
            let childKey = try key.derive(index: 0).derive(index: 0)
            let address = DogeCoinAddress(publicKey: childKey.publicKey, network: DogeCoinNetwork.mainnet)
            debugPrint(childKey.privateKey!.bytes.base58CheckEncodedString)
            debugPrint(address.address!)
        } catch _ {
            
        }
    }
}
