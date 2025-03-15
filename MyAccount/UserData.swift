//
//  UserData.swift
//  Account
//
//  Created by Hossein Zare on 3/15/25.
//

import Foundation
import SwiftUI

// MARK: - User Profile Data Model
struct UserProfile: Codable {
    var firstname: String
    var lastname: String
    var email: String
    var birthday: Date
    var gender: String
    var password: String
}

// MARK: - User Data and Image Storage Manager
class UserProfileManager {
    
    static let shared = UserProfileManager()
    private let userDefaultsKey = "userProfile"
    private let imageKey = "profileImage" // Key for storing profile image
    
    private init() { }
    
    // Save user profile data
    func saveUser(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Load user profile data
    func loadUser() -> UserProfile? {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        }
        return nil
    }
    
    // Save profile image
    func saveProfileImage(_ data: Data) {
        UserDefaults.standard.set(data, forKey: imageKey)
    }
    
    // Load profile image
    func loadProfileImage() -> UIImage? {
        if let data = UserDefaults.standard.data(forKey: imageKey),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    // Load both user data and profile image together
    func loadCompleteUserData() -> (UserProfile?, UIImage?) {
        return (loadUser(), loadProfileImage())
    }
}


