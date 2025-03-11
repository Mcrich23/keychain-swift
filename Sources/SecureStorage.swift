//
//  Keychain Property Wrapper.swift
//  Due Tomorrow
//
//  Created by Morris Richman on 3/9/25.
//

import Foundation
import KeychainSwift
import SwiftUI

/// Update the values to change the defaults for SecureStorage
public class SecureStorageDefaults {
    /// The `KeychainSwift` being saved with
    public static var keychain = KeychainSwift()
    /// Access controls for keychain
    public static var access: KeychainSwiftAccessOptions? = nil
}

/// A property wrapper to easily and securely save data in Keychain
@propertyWrapper
public struct SecureStorage<T: ExpressibleByNilLiteral> {
    /// The key for the value in keychain
    let key: String
    /// The `KeychainSwift` being saved with
    var keychain: KeychainSwift
    /// Access controls for keychain
    var access: KeychainSwiftAccessOptions?
    
    /// The underlying get function for wrappedValue
    /// - Returns: `T`
    let _get: () -> T
    /// The underlying set function for wrappedValue
    /// - Parameters:
    ///   - `T`: The new value being set
    let _set: (T) -> Void
    
    public var wrappedValue: T {
        get {
            _get()
        }
        set {
            _set(newValue)
        }
    }
    
    /// The Initializer for `SecureStorage`
    /// - Parameters:
    ///   - key: The key for the value in keychain
    ///   - keychain: The `KeychainSwift` being saved with
    ///   - access: Access controls for keychain
    public init(
        _ key: String,
        keychain: KeychainSwift = SecureStorageDefaults.keychain,
        withAccess access: KeychainSwiftAccessOptions? = SecureStorageDefaults.access
    ) {
        self.key = key
        self.keychain = keychain
        self.access = access
        
        self._get = { nil }
        self._set = { _ in fatalError("Unsupported Type") }
    }
}

// MARK: Support String
extension SecureStorage where T == String? {
    /// The Initializer for `SecureStorage`
    /// - Parameters:
    ///   - key: The key for the value in keychain
    ///   - keychain: The `KeychainSwift` being saved with
    ///   - access: Access controls for keychain
    public init(
        _ key: String,
        keychain: KeychainSwift = SecureStorageDefaults.keychain,
        withAccess access: KeychainSwiftAccessOptions? = SecureStorageDefaults.access
    ) {
        self.key = key
        self.keychain = keychain
        self.access = access
        
        self._get = {
            keychain.get(key)
        }
        self._set = { newValue in
            guard let newValue else {
                keychain.delete(key)
                return
            }
            
            keychain.set(newValue, forKey: key, withAccess: access)
        }
    }
}

// MARK: Support Bool
extension SecureStorage where T == Optional<Bool> {
    /// The Initializer for `SecureStorage`
    /// - Parameters:
    ///   - key: The key for the value in keychain
    ///   - keychain: The `KeychainSwift` being saved with
    ///   - access: Access controls for keychain
    public init(
        _ key: String,
        keychain: KeychainSwift = SecureStorageDefaults.keychain,
        withAccess access: KeychainSwiftAccessOptions? = SecureStorageDefaults.access
    ) {
        self.key = key
        self.keychain = keychain
        self.access = access
        
        self._get = {
            keychain.getBool(key)
        }
        self._set = { newValue in
            guard let newValue else {
                keychain.delete(key)
                return
            }
            
            keychain.set(newValue, forKey: key, withAccess: access)
        }
    }
}

// MARK: Support Data
extension SecureStorage where T == Optional<Data> {
    /// The Initializer for `SecureStorage`
    /// - Parameters:
    ///   - key: The key for the value in keychain
    ///   - keychain: The `KeychainSwift` being saved with
    ///   - access: Access controls for keychain
    public init(
        _ key: String,
        keychain: KeychainSwift = SecureStorageDefaults.keychain,
        withAccess access: KeychainSwiftAccessOptions? = SecureStorageDefaults.access
    ) {
        self.key = key
        self.keychain = keychain
        self.access = access
        
        self._get = {
            keychain.getData(key)
        }
        self._set = { newValue in
            guard let newValue else {
                keychain.delete(key)
                return
            }
            
            keychain.set(newValue, forKey: key, withAccess: access)
        }
    }
}

// MARK: Support Codable

// WARNING: Corrupts Data when saving. Possible bit overflow
//extension SecureStorage where T: Codable & ExpressibleByNilLiteral {
//    /// The Initializer for `SecureStorage`
//    /// - Parameters:
//    ///   - key: The key for the value in keychain
//    ///   - keychain: The `KeychainSwift` being saved with
//    ///   - access: Access controls for keychain
//    public init(
//        _ key: String,
//        keychain: KeychainSwift = .init(),
//        withAccess access: KeychainSwiftAccessOptions? = nil
//    ) {
//        self.key = key
//        self.keychain = keychain
//        self.access = access
//        
//        self._get = {
//            guard let data = keychain.getData(key) else { return nil }
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//            do {
//                return try jsonDecoder.decode(T.self, from: data)
//            } catch {
//                return nil
//            }
//        }
//        self._set = { newValue in
//            guard "\(newValue)" != "nil" else {
//                guard let data = keychain.getData(key) else {
//                    return
//                }
//                let jsonDecoder = JSONDecoder()
//                if (try? jsonDecoder.decode(T.self, from: data)) != nil {
//                    keychain.delete(key)
//                }
//                return
//            }
//            
//            let jsonEncoder = JSONEncoder()
//            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
//            
//            do {
//                let data = try jsonEncoder.encode(newValue)
//                keychain.set(data, forKey: key, withAccess: access)
//            } catch {
//                print("❌ Data Not Saved to Keychain!")
//            }
//        }
//    }
//}
