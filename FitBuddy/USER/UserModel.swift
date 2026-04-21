//
//  UserModel.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import Foundation
import SwiftUI

// UserController is kept as a data holder for user info across the app.
// Authentication is handled by SupabaseAuthManager.
class UserController: ObservableObject {
    @Published var user: UserModel?

    init(user: UserModel? = nil) {
        self.user = user
    }
    
    func signOut() {
        self.user = nil
    }
}

struct UserModel: Codable, Identifiable, Equatable {
    let id: String?
    var name: String?
    var email: String?
    var imageURL: String?
    var bio: String?
    var username: String?
    var points: Int?
    var badge: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case imageURL = "avatar_url"
        case bio
        case username
        case points
        case badge
    }
}
