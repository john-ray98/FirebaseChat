//
//  OpenChatRoom.swift
//  FirebaseChat
//
//  Created by John Ray on 5/24/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct User {
    let name: String
    let email: String
}

struct ChatRoomMessage: Identifiable {
    let id = UUID()
    let sender: User
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
               let senderData = messageData["sender"] as? [String: Any],
               let senderName = senderData["name"] as? String,
               let senderEmail = senderData["email"] as? String,
               let message = messageData["message"] as? String,
               let timestamp = messageData["timestamp"] as? Double {
                
                let sender = User(name: senderName, email: senderEmail)
                let chatRoomMessage = ChatRoomMessage(sender: sender, message: message, timestamp: timestamp)
                
                DispatchQueue.main.async {
                    self.messages.append(chatRoomMessage)
                }
            }
        }
    }
    
    func sendChatMessage(sender: User, message: String) {
        let ref = Database.database().reference().child("chatRoom_messages").childByAutoId()
        let timestamp = Date().timeIntervalSince1970
        let messageData: [String: Any] = [
            "sender": [
                "name": sender.name,
                "email": sender.email
            ],
            "message": message,
            "timestamp": timestamp
        ]
        ref.setValue(messageData)
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .edgesIgnoringSafeArea(keyboardHeight > 0 ? .bottom : [])
            .onAppear(perform: subscribeToKeyboardEvents)
            .onDisappear(perform: unsubscribeFromKeyboardEvents)
            .animation(.easeOut(duration: 0.25))
    }
    
    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            keyboardHeight = keyboardFrame.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(self)
    }
}




struct ChatRoomView: View {
    @ObservedObject var chatRoomViewModel = ChatRoomViewModel()
    @State private var messageText = ""
    @State private var sender: User? = nil
    
    var body: some View {
        VStack {
            List(chatRoomViewModel.messages) { message in
                VStack(alignment: .leading) {
                    Text("\(message.sender.name) (\(message.sender.email)):")
                        .font(.headline)
                    Text(message.message)
                }
            }
            .padding()
            
            HStack {
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
        .onAppear(perform: {
            fetchUserData()
        })
        .modifier(KeyboardAdaptive())
        .gesture (
        TapGesture()
            .onEnded { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
    
    func fetchUserData() {
        if let user = Auth.auth().currentUser {
            let name = user.displayName ?? ""
            let email = user.email ?? ""
            sender = User(name: name, email: email)
        }
    }
    
    func sendMessage() {
        guard let sender = sender, !messageText.isEmpty else { return }
        chatRoomViewModel.sendChatMessage(sender: sender, message: messageText)
        messageText = ""
    }
}

    
    struct OpenChatRoom: View {
        
        var body: some View {
            NavigationView {
                
                ChatRoomView()
                    .navigationTitle("Support Room")
            }
            }
            }
        


struct OpenChatRoom_Previews: PreviewProvider {
    static var previews: some View {
        OpenChatRoom()
    }
}

