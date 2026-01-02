//
//  UserModel.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase


class UserController: ObservableObject {
    @Published var user: UserModel?

    init(user: UserModel? = nil) {
        self.user = user
    }
    
    func login() {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController ?? UIViewController()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        
        // SIGN IN
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) {user, error in
            if error != nil {
              return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            if let user {
                self.user = UserModel(
                    id: user.userID,
                    name: user.profile?.name,
                    email: user.profile?.email,
                    imageURL: user.profile?.imageURL(withDimension: 1000)?.absoluteString
                )
            }
            
            // SIGN IN FIRE BASE
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else { return }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.user = nil
    }
    
    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn() {user, error in
            if let user {
                self.user = UserModel(
                    id: user.userID,
                    name: user.profile?.name,
                    email: user.profile?.email,
                    imageURL: user.profile?.imageURL(withDimension: 1000)?.absoluteString
                )
            }
        }
    }
}

struct UserModel: Codable, Identifiable {
    let id: String?
    let name: String?
    let email: String?
    let imageURL: String?
}
