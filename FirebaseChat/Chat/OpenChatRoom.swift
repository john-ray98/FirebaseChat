//
//  OpenChatRoom.swift
//  FirebaseChat
//
//  Created by John Ray on 5/24/23.
//

/*import SwiftUI
import FirebaseDatabase

struct ChatRoomMessage: Identifiable {
    let id = UUID()
    let sender: String
    let message: String
    let timestamp: Double
}

class ChatRoomViewModel: ObservableObject {
    @Published var messages = [ChatRoomMessage]()
    
    init() {
        observeChatMessages()
    }
    
    func observeChatMessages() {
        let ref = Database.database().reference().child("chatRoom_messages")
        ref.observe(.childAdded) { snapshot in
            if let messageData = snapshot.value as? [String: Any],
               let sender = messageData["sender"] as? String,
               let message = messageData["message"] as? String,
               let timestamp = messageData["timestamp"] as? Double {
                let chatRoomMessage = ChatRoomMessage(sender: sender, message: message, timestamp: timestamp)
                DispatchQueue.main.async {
                    self.messages.append(chatRoomMessage)
                }
            }
        }
    }
    
    func sendChatMessage(sender: String, message: String) {
        let ref = Database.database().reference().child("chatRoom_messages").childByAutoId()
        let timestamp = Date().timeIntervalSince1970
        let messageData: [String: Any] = [
            "sender": sender,
            "message": message,
            "timestamp": timestamp
        ]
        ref.setValue(messageData)
    }
}

struct ChatRoomView: View {
    @ObservedObject var chatRoomViewModel = ChatRoomViewModel()
    @State private var messageText = ""
    @State private var senderName = ""
    
    var body: some View {
        VStack {
            List(chatRoomViewModel.messages) { message in
                VStack(alignment: .leading) {
                    Text("\(message.sender):")
                        .font(.headline)
                    Text(message.message)
                }
            }
            .padding()
            
            HStack {
                TextField("Enter your name", text: $senderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !senderName.isEmpty, !messageText.isEmpty else { return }
        chatRoomViewModel.sendChatMessage(sender: senderName, message: messageText)
        messageText = ""
    }
}

struct OpenChatRoom: View {
    var body: some View {
        NavigationView {
            ChatRoomView()
                .navigationTitle("Chat Room")
        }
    }
}



struct OpenChatRoom_Previews: PreviewProvider {
    static var previews: some View {
        OpenChatRoom()
    }
}*/

