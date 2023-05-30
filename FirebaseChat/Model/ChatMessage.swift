//
//  ChatMessage.swift
//  FirebaseChat
//
//  Created by John Ray on 5/25/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
