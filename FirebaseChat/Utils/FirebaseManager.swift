//
//  FirebaseManager.swift
//  FirebaseChat
//
//  Created by John Ray on 5/17/23.
//

import Foundation
import Firebase
import FirebaseStorage

//@main

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
   // FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
