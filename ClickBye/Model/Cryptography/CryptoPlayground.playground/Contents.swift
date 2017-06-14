//: Playground - noun: a place where people can play

import UIKit
import CryptoSwift

var str = "Hello, playground"
//
//var secretKey = "Click.By.1473"
//var secretKeyData = secretKey.data(using: .utf8)!
//var secretKeyDataCount = secretKeyData.count
//
//let secretKeyLength = 128 / 8
//let replacementCode: UInt8 = 113
//
//var updatedKeyData = Data()
//
//for position in 0..<secretKeyLength {
//    if position < secretKeyDataCount {
//        updatedKeyData.append(secretKeyData[position])
//    } else {
//        updatedKeyData.append(replacementCode)
//    }
//}
//
//String(data: updatedKeyData, encoding: .utf8)!
//
//
//
//var secretKey = "Click.By.1473"
//let secretKeyData = source.data(using: .utf8)!
//secretKeyData.count
//
//var secretKeyCharactersCount = secretKey.characters.count
//var secretKeyLength = 128
//var replacementCode = 113
//
//let charactersCount = secretKeyLength / 8
//var data = Data()
//
//for position in 0..<charactersCount {
//    secretKeyData[0]
//}

extension String {
    func base64String() -> String? {
        let data = self.data(using: .utf8)
        
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

class Cryptographer {
    
    static func encrypt(message: String,
                        key: String) -> Data? {
        if let base64String = message.base64String(),
            let messageData = Data(base64Encoded: base64String) {
            return encrypt(messageData: messageData, key: key)
        }
        
        return nil
    }
    
    
    static func encrypt(messageData: Data,
                        key: String) -> Data? {
        do {
            let encryptedData = try messageData.encrypt(cipher: AES(key: generatedKey(from: key, keyLength: 128), iv: String(), blockMode: .ECB, padding: PKCS7()))
            
            return encryptedData
        } catch {
            return nil
        }
    }
    
    static func decrypt(messageData: Data,
                        key: String) -> Data? {
        do {
            let decryptedData = try messageData.decrypt(cipher: AES(key: generatedKey(from: key, keyLength: 128), iv: String(), blockMode: .ECB, padding: PKCS7()))
            
            return decryptedData
        } catch {
            return nil
        }
    }
    
    static func generatedKey(from secretKey: String,
                             keyLength: Int) -> String {
        var secretKeyLength = secretKey.characters.count
        var generatedSecretKey = secretKey
        
        while (secretKeyLength * 8) < keyLength {
            generatedSecretKey += " "
            secretKeyLength = generatedSecretKey.characters.count
        }
        
        return generatedSecretKey
    }
}

//AES_CRYPT_IMPL: --- === ENCODE MODE === ---
//AES_CRYPT_IMPL:      src: login
//AES_CRYPT_IMPL: password: Click.By.1473
//AES_CRYPT_IMPL:         srcBytes: (5 byte) (40 bit) 108 111 103 105 110
//AES_CRYPT_IMPL:        passBytes: (13 byte) (104 bit) 67 108 105 99 107 46 66 121 46 49 52 55 51
//AES_CRYPT_IMPL: resizedPassBytes: (16 byte) (128 bit) 67 108 105 99 107 46 66 121 46 49 52 55 51 113 113 113
//AES_CRYPT_IMPL: resultBytes: (16 byte) (128 bit) 108 -120 -120 42 -76 -9 -56 -23 -13 37 -19 11 29 8 105 -96
//AES_CRYPT_IMPL: convert to Base64
//AES_CRYPT_IMPL: result: bIiIKrT3yOnzJe0LHQhpoA==
//AES_CRYPT_IMPL: --- === ENCODE END === ---

let source = "andrew.kochulab@gmail.com"
let key = "Click.By.1473"

let sourceData = source.data(using: .utf8)!

print("src:")
for b in sourceData {
    print(b, terminator: " ")
}

var keyData = key.data(using: .utf8)!

print("\n\npass:")
for b in keyData {
    print(b, terminator: " ")
}

var value = 113
//let buffer = UnsafeBufferPointer(start: &value, count: 1)
keyData.append(113)
keyData.append(113)
keyData.append(113)

print("\n\npass:")
for b in keyData {
    print(b, terminator: " ")
}

let updatedKey = String(data: keyData, encoding: .utf8)!
let encryptedData = Cryptographer.encrypt(messageData: sourceData, key: updatedKey)!

print("\n\nresult bytes:")
for b in encryptedData {
    print(b, terminator: " ")
}

let base64 = encryptedData.base64EncodedString()
print("\n\nbase64:\n\(base64)")




//bIiIKrT3yOnzJe0LHQhpoA==
//AES_CRYPT_IMPL: --- === DECODE MODE === ---
//AES_CRYPT_IMPL:      src: bIiIKrT3yOnzJe0LHQhpoA==
//AES_CRYPT_IMPL: password: Click.By.1473
//AES_CRYPT_IMPL: convert from Base64
//AES_CRYPT_IMPL:         srcBytes: (16 byte) (128 bit) 108 -120 -120 42 -76 -9 -56 -23 -13 37 -19 11 29 8 105 -96
//AES_CRYPT_IMPL:        passBytes: (13 byte) (104 bit) 67 108 105 99 107 46 66 121 46 49 52 55 51
//AES_CRYPT_IMPL: resizedPassBytes: (16 byte) (128 bit) 67 108 105 99 107 46 66 121 46 49 52 55 51 113 113 113
//AES_CRYPT_IMPL: resultBytes: (5 byte) (40 bit) 108 111 103 105 110
//AES_CRYPT_IMPL: result: login
//AES_CRYPT_IMPL: --- === DECODE END === ---

let decryptedData = Cryptographer.decrypt(messageData: encryptedData, key: updatedKey)!
String.init(data: decryptedData, encoding: .utf8)

"Click.By.1473".characters.count
"Click.By.1473".characters.count * 8



public protocol DataConvertible {
    static func + (lhs: Data, rhs: Self) -> Data
    static func += (lhs: inout Data, rhs: Self)
}

extension DataConvertible {
    public static func + (lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }
    
    public static func += (lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8 : DataConvertible { }
extension UInt16 : DataConvertible { }
extension UInt32 : DataConvertible { }

extension Int : DataConvertible { }
extension Float : DataConvertible { }
extension Double : DataConvertible { }

extension String : DataConvertible {
    public static func + (lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .utf8) else { return lhs}
        return lhs + data
    }
}

extension Data : DataConvertible {
    public static func + (lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        
        return data
    }
}
