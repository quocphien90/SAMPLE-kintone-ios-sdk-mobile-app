//  Copyright © 2018 Cuc Kim. All rights reserved.

import Foundation
import CryptoSwift

public class CryptoAESCommon
{
    private static let encryptKey = KintoneConstants.ENCRYPTED_KEY
    private static let encryptVector = KintoneConstants.ENCRYPTED_VECTOR
    
    public static func encrypt(_ stringToEncrypt: String) throws -> [UInt8]
    {
        do {
            let aes = try AES(key: encryptKey, iv: encryptVector) // aes128
            let ciphertext = try aes.encrypt(stringToEncrypt.bytes)
            return ciphertext
        } catch {
            throw error
        }
    }
    
    public static func decrypt(_ bytesDecrypted: [UInt8]) throws -> String
    {
        do {
            let aes = try AES(key: encryptKey, iv: encryptVector) // aes128
            let ciphertextDecrypted = try aes.decrypt(bytesDecrypted)
            let rawValue = String(bytes: ciphertextDecrypted, encoding: String.Encoding.utf8)
            return rawValue!
        } catch {
            throw error
        }
    }
}
