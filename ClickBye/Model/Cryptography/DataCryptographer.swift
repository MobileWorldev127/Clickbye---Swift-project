//
//  DataCryptographer.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import CryptoSwift

final class DataCryptographer {
    static fileprivate let secretKey = "Click.By.1473"
    static fileprivate let secretKeyLength = 128
    
    static func generatedKey(from secretKey: String = secretKey,
                             keyLength: Int = secretKeyLength,
                             replacementCode: UInt8 = 113 /* q */) -> String? {
        guard let secretKeyData = secretKey.data(using: .utf8) else {
            return nil
        }
        
        let secretKeyDataCount = secretKeyData.count
        let secretKeyLength = keyLength / 8
        
        var updatedKeyData = Data()
        
        for position in 0..<secretKeyLength {
            updatedKeyData.append((position < secretKeyDataCount) ? secretKeyData[position] : replacementCode)
        }
        
        return String(data: updatedKeyData, encoding: .utf8)
    }
    
    static func encrypt(message: String,
                        secretKey: String = secretKey,
                        secretKeyLength: Int = secretKeyLength) -> Data? {
        if let messageData = message.data(using: .utf8) {
            return encrypt(messageData: messageData, secretKey: secretKey, secretKeyLength: secretKeyLength)
        }

        return nil
    }
    
    static func encrypt(messageData: Data,
                        secretKey: String = secretKey,
                        secretKeyLength: Int = secretKeyLength) -> Data? {
        guard let generatedKey = generatedKey() else {
            return nil
        }

        do {
            let encryptedData = try messageData.encrypt(cipher: AES(key: generatedKey, iv: String(), blockMode: .ECB, padding: PKCS7()))
            
            return encryptedData
        } catch {
            return nil
        }
    }
    
    static func encryptedString(message: String,
                                secretKey: String = secretKey,
                                secretKeyLength: Int = secretKeyLength) -> String? {
        return encrypt(message: message, secretKey: secretKey, secretKeyLength: secretKeyLength)?.base64EncodedString()
    }
    
    static func decrypt(message: String,
                        decryptKey: String = secretKey,
                        decryptKeyLength: Int = secretKeyLength) -> Data? {
        if let messageData = Data(base64Encoded: message) {
            return decrypt(messageData: messageData, decryptKey: decryptKey, decryptKeyLength: decryptKeyLength)
        }
        
        return nil
    }
    
    static func decrypt(messageData: Data,
                        decryptKey: String = secretKey,
                        decryptKeyLength: Int = secretKeyLength) -> Data? {
        guard let generatedKey = generatedKey() else {
            return nil
        }
        
        do {
            let decryptedData = try messageData.decrypt(cipher: AES(key: generatedKey, iv: String(), blockMode: .ECB, padding: PKCS7()))
            
            return decryptedData
        } catch {
            return nil
        }
    }
    
    static func decryptedString(message: String,
                                decryptKey: String = secretKey,
                                decryptKeyLength: Int = secretKeyLength) -> String? {
        if let decryptedData = decrypt(message: message, decryptKey: decryptKey, decryptKeyLength: decryptKeyLength) {
            return String(data: decryptedData, encoding: .utf8)
        }
        
        return nil
    }
}
