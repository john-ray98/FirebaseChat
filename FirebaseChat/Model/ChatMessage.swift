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
    let imageUrl: String?
    
    init(id: String?, fromId: String, toId: String, text: String, imageUrl: String? = nil, timestamp: Date) {
            self.id = id
            self.fromId = fromId
            self.toId = toId
            self.text = text
            self.imageUrl = imageUrl
            self.timestamp = timestamp
   }
}
