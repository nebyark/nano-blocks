//
//  WalletManager.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/22/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation

final class WalletManager {
    
    static let shared: WalletManager = WalletManager()
    private(set) var verifiedReps: [VerifiedAccount] = []
    private(set) var accounts: [AccountInfo] = PersistentStore.getAccounts()
    fileprivate var sd: Data?
    
    var isLocked: Bool {
        if Keychain.standard.get(key: KeychainKey.allowedFailAttempts) == nil {
            resetFailedAttempts()
        }
        guard let epoch = Keychain.standard.get(key: KeychainKey.lockUntilDate)?.uint32 else { return false }
        if Date().timeIntervalSince1970 >= TimeInterval(epoch) {
            resetLock()
            return false
        }
        return true
    }
    
    // MARK: - Accessors
    
    func keyPair(at index: Int) -> KeyPair? {
        guard let idx = Keychain.standard.get(key: KeychainKey.walletSeedIndex),
            index <= idx.uint32,
            let seed = sd else { return nil }
        // In order for keyPair to return the correct (or any) key pair, the correct secret key MUST be provided. In the event that the device has been jailbroken and is undergoing runtime analysis, the attacker would need to know the user's secret to proceed.
        return WalletUtil.keyPair(seed: seed, index: UInt32(index))
    }
    
    func account(at index: Int) -> AccountInfo? {
        guard index < accounts.count else { return nil }
        return accounts[index]
    }
    
    // MARK: - Cached PoW
    
    // MARK: - Lock Wallet
    
    /// Decrements the allowedFailAttempts counter.
    ///
    /// - Returns: Whether or not the fail count threshold has been reached.
    func unlockFailed() -> Bool {
        guard let remaining = Keychain.standard.get(key: KeychainKey.allowedFailAttempts)?.uint32 else { return false }
        if remaining > 1 {
            Keychain.standard.set(value: Data(remaining - 1), key: KeychainKey.allowedFailAttempts)
            return false
        }
        return true
    }
    
    /// Resets the wallet lock date and failed attempt count.
    func resetLock() {
        Keychain.standard.remove(key: KeychainKey.lockUntilDate)
        resetFailedAttempts()
    }
    
    /// Sets a lock date on the wallet to 30 minutes from now.
    func lockWallet() {
        let dateUntilUnlock = Int(Date().timeIntervalSince1970 + 1800)
        Keychain.standard.set(value: Data(dateUntilUnlock), key: KeychainKey.lockUntilDate)
        if sd != nil {
            NaCl.zero(&sd)
        }
    }
    
    /// Reset the failed attempt count to 10.
    func resetFailedAttempts() {
        Keychain.standard.set(value: Data(10), key: KeychainKey.allowedFailAttempts)
    }
    
    /// Set seed for wallet, and encrypt the seed using password.
    ///
    /// - Parameter password: The password to salt and store. This is used to decrypt the seed at runtime. The password stored is a hash of the salted pw hash.
    /// - Returns: A PasswordSetResult that provides info on the set operation.
    func setWalletSeed(_ seed: Data?, password: String) -> Bool {
        guard let seed = seed else { return false }
        // 1. Create Salt
        guard let passwordData = password.data(using: .utf8),
            let salt = NaCl.randomBytes(NaCl.saltBytes) else { return false }
        // 2. Salt password
        guard let pwHash = NaCl.hash(passwordData + salt) else { return false }
        // 3. Generate key from password, encrypt seed
        guard let key = NaCl.hash(passwordData, salt: salt),
            let encryptedSeed: Data = NaCl.encrypt(seed, secret: key) else { return false }
        // 4. Store items
        guard Keychain.standard.set(value: pwHash, key: KeychainKey.saltySecret),
            Keychain.standard.set(value: salt, key: KeychainKey.salt),
            Keychain.standard.set(value: encryptedSeed, key: KeychainKey.walletSeed) else { return false }
        
        if UserSettings.requireBiometricseOnLaunch {
            Keychain.standard.set(value: key, key: KeychainKey.biometricsKey)
        }
        sd = seed
        return true
    }
    
    func setWalletPassword(_ newPassword: String, oldPassword: String) -> Bool {
        guard unlockWallet(oldPassword), let seed = sd else { return false }
        return setWalletSeed(seed, password: newPassword)
    }
    
    /// Unlocks the wallet. Once the wallet has been unlocked, address generation and block signing are available.
    ///
    /// - Parameter password: The user's password to unlock the wallet.
    /// - Returns whether or not the wallet has been unlocked.
    /// NOTE: Requires an existing seed.
    func unlockWalletImpl(_ password: String) -> Data? {
        guard let passwordData = password.data(using: .utf8),
            let salt = Keychain.standard.get(key: KeychainKey.salt),
            let storedSaltedSecret = Keychain.standard.get(key: KeychainKey.saltySecret) else { return nil }
        guard let testSaltedSecret = NaCl.hash(passwordData + salt) else { return nil }
        if testSaltedSecret == storedSaltedSecret {
            // Decrypt seed
            guard let key = NaCl.hash(passwordData, salt: salt),
                let encryptedSeed = Keychain.standard.get(key: KeychainKey.walletSeed),
                let decrytpedSeed = NaCl.decrypt(encryptedSeed, secret: key) else { return nil }
            return decrytpedSeed
        }
        return nil
    }
    
    func unlockWalletBiometrics() -> Bool {
        guard let biometricKey = Keychain.standard.get(key: KeychainKey.biometricsKey),
            let encryptedSeed = Keychain.standard.get(key: KeychainKey.walletSeed),
            let decrytpedSeed = NaCl.decrypt(encryptedSeed, secret: biometricKey) else { return false }
        sd = decrytpedSeed
        return true
    }
    
    func unlockWallet(_ password: String) -> Bool {
        guard let decryptedSeed = unlockWalletImpl(password) else { return false }
        sd = decryptedSeed
        return true
    }
    // MARK: - Reps
    
    func setRepList(_ list: [VerifiedAccount]) {
        verifiedReps = list
    }
    
    func getRandomRep() -> VerifiedAccount? {
        guard verifiedReps.count > 0 else { return nil }
        let rand = arc4random_uniform(UInt32(verifiedReps.count))
        return verifiedReps[Int(rand)]
    }
    
    // MARK: - Account/Wallet Creation
    
    fileprivate func createAccountImpl(_ index: UInt32, name: String? = nil) {
        guard let seed = sd else { return }
        let name = name ?? "Account \(index)"
        Keychain.standard.set(value: Data(index), key: KeychainKey.walletSeedIndex)
        guard let accountAddress = WalletUtil.keyPair(seed: seed, index: index)?.xrbAccount else { return }
        Lincoln.log("Account created '\(accountAddress)'", inConsole: true)
        // Create account
        PersistentStore.addAccount(name: name, address: accountAddress, index: Int(index))
        PersistentStore.addAddressEntry(name, address: accountAddress)
        updateAccounts()
    }
    
    /// Creates a wallet from a wallet backup phrase.
    ///
    /// - Parameter phrase: An array containing the backup phrase from which the seed is derived.
    func createWallet(phrase: [String]) {
        
    }
    
//    func createVanityAddress(with value: String, completion: ((Bool) -> Void)) {
//        var target: String = ""
//        var result = ""
//        var seed: Data?
//        // Addresses must start with either a 1 or 3
//        while !result.contains(value) {
//            guard let sd = Sodium().randomBytes.buf(length: 32) else {
//                completion(false)
//                return
//            }
//            guard let keyPair = WalletUtil.keyPair(seed: sd, index: 0), let account = keyPair.xrbAccount else {
//                completion(false)
//                return
//            }
//            result = account
//            seed = sd
//        }
//    }
    
    /// Adds an account address by incrementing the seed index by 1. First account's index is 0.
    ///
    /// - Parameter name: A name for the account (Savings, Chump-change, etc)
    /// - Parameter completion: A completion handler that gets invoked upon successful account creation.
    func addAccount(name: String?) {
        guard let seedIndexData = Keychain.standard.get(key: KeychainKey.walletSeedIndex) else { return }
        createAccountImpl(seedIndexData.uint32 + 1, name: name)
    }
    
    func createWallet() {
        createAccountImpl(0)
    }
    
    func clearWalletData() {
        KeychainKey.allKeys.forEach {
            Keychain.standard.remove(key: $0)
        }
        accounts.removeAll()
    }
    
    func updateAccounts() {
        accounts = PersistentStore.getAccounts()
    }
}

struct KeychainKey {
    static let saltySecret: String = "kSaltySecret"
    static let salt: String = "kSalt"
    static let walletSeed: String = "kWalletSeed"
    static let walletSeedIndex: String = "kWalletSeedIndex"
    static let passcodeSalt: String = "kPasscodeSalt"
    static let allowedFailAttempts: String = "kAllowedFailAttempts"
    static let lockUntilDate: String = "kLockUntilDate"
    static let useBiometricsOnSend: String = "kUseBiometricsOnSend"
    static let useBiometricsOnLaunch: String = "kUseBiometricsOnLaunch"
    static let biometricsKey: String = "kBiometricsKey"
    static let mqttWalletID: String = "kMqttWalletID"
    static let mqttUsername: String = "kMqttUsername"
    static let mqttPassword: String = "kMqttPassword"
    
    static var allKeys: [String] = [KeychainKey.walletSeed, KeychainKey.walletSeedIndex, KeychainKey.passcodeSalt, KeychainKey.useBiometricsOnSend, KeychainKey.useBiometricsOnLaunch, KeychainKey.allowedFailAttempts, KeychainKey.lockUntilDate, KeychainKey.saltySecret, KeychainKey.salt, KeychainKey.biometricsKey, KeychainKey.mqttPassword, KeychainKey.mqttUsername, KeychainKey.mqttWalletID]
}
