//
//  ChatLogView.swift
//  FirebaseChat
//
//  Created by John Ray on 5/18/23.
//

import SwiftUI
import Firebase
import UIKit


class ChatLogViewModel: ObservableObject {
    
    @Published var count = 0
    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func persistRecentMessage() {
        guard let chatUser = chatUser else {
            return
        }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String: Any]
        
        
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    
    
    
    func fetchMessages() {
        guard let fromId =
                FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener =
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let cm = try?
                                change.document.data(as:
                                                        ChatMessage.self) {
                                self.chatMessages.append(cm)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        if let selectedImage = selectedImage {
            // Convert the selected image to Data
            guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else { return }
            
            // Generate a unique filename for the image
            let filename = UUID().uuidString
            
            // Create a storage reference with the filename
            let imageRef = FirebaseManager.shared.storage.reference().child(filename)
            
            // Upload the image data to the storage reference
            let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to upload image: \(error)"
                    return
                }
                
                // Get the download URL of the uploaded image
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print(error)
                        self.errorMessage = "Failed to get image download URL: \(error)"
                        return
                    }
                    
                    guard let imageUrl = url?.absoluteString else {
                        print("Failed to get image download URL")
                        self.errorMessage = "Failed to get image download URL"
                        return
                    }
                    
                    // Create a ChatMessage object with the image URL
                    let message = ChatMessage(id: nil, fromId: fromId, toId: toId, text: "", imageUrl: imageUrl, timestamp: Date())
                    
                    // Save the message to Firestore
                    let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                        .document(fromId)
                        .collection(toId)
                        .document()
                    
                    try? document.setData(from: message) { error in
                        if let error = error {
                            print(error)
                            self.errorMessage = "Failed to save message into Firestore: \(error)"
                            return
                        }
                        
                        print("Successfully saved current user sending message")
                        
                        self.persistRecentMessage()
                        
                        self.selectedImage = nil
                    }
                    
                    let recipientMessageDocument = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                        .document(toId)
                        .collection(fromId)
                        .document()
                    
                    try? recipientMessageDocument.setData(from: message) { error in
                        if let error = error {
                            print(error)
                            self.errorMessage = "Failed to save message into Firestore: \(error)"
                            return
                        }
                        
                        print("Recipient saved message as well")
                    }
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Track the progress of the image upload if needed
            }
            
            uploadTask.observe(.success) { snapshot in
                // The image upload is complete
            }
        } else {
            // No image selected, handle the text message
            let message: ChatMessage
            if let image = selectedImage {
                message = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, imageUrl: "", timestamp: Date())
            } else {
                message = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
            }
            
            let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                .document(fromId)
                .collection(toId)
                .document()
            
            try? document.setData(from: message) { error in
                if let error = error {
                    
                    
                    
                    /* func handleSend() {
                     print(chatText)
                     guard let fromId =
                     FirebaseManager.shared.auth.currentUser?.uid else { return }
                     
                     guard let toId = chatUser?.uid else { return
                     
                     }
                     
                     let document =
                     FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                     .document(fromId)
                     .collection(toId)
                     .document()
                     
                     let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
                     
                     try? document.setData(from: msg) { error in
                     if let error = error {
                     print(error)
                     self.errorMessage = "Failed to save message into Firestore: \(error)"
                     return
                     }
                     
                     print("Successfully saved curent user sending message")
                     
                     self.persistRecentMessage()
                     
                     self.chatText = ""
                     self.count += 1
                     }
                     
                     let recipientMessageDocument =
                     FirebaseManager.shared.firestore.collection("messages")
                     .document(toId)
                     .collection(fromId)
                     .document()
                     
                     try? recipientMessageDocument.setData(from: msg) { error in
                     if let error = error {
                     print(error)
                     self.errorMessage = "Failed to save message into Firestore: \(error)"
                     return
                     }
                     
                     print("Recipent saved message as well")
                     }
                     
                     } */
                    
                    /* func persistRecentMessage() {
                     guard let chatUser = chatUser else {
                     return
                     }
                     
                     guard let uid = FirebaseManager.shared.auth.currentUser?.uid
                     else { return }
                     guard let toId = self.chatUser?.uid else { return }
                     
                     let document = FirebaseManager.shared.firestore
                     .collection(FirebaseConstants.recentMessages)
                     .document(uid)
                     .collection(FirebaseConstants.messages)
                     .document(toId)
                     
                     let data = [
                     FirebaseConstants.timestamp: Timestamp(),
                     FirebaseConstants.text: self.chatText,
                     FirebaseConstants.fromId: uid,
                     FirebaseConstants.toId: toId,
                     FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                     FirebaseConstants.email: chatUser.email
                     ] as [String: Any]
                     
                     
                     
                     document.setData(data) { error in
                     if let error = error {
                     self.errorMessage = "Failed to save recent message: \(error)"
                     print("Failed to save recent message: \(error)")
                     return
                     }
                     }
                     }*/
                    
                    //@Published var count = 0
                }
            }
            
            struct ChatLogView: View {
                
                @State private var isShowingImagePicker = false
                @State private var selectedImage: UIImage?
                
                let chatUser: ChatUser?
                
                init(chatUser: ChatUser?) {
                    self.chatUser = chatUser
                    self.vm = .init(chatUser: chatUser)
                }
                
                @ObservedObject var vm: ChatLogViewModel
                
                var body: some View {
                    ZStack {
                        messagesView
                        Text(vm.errorMessage)
                        VStack(spacing: 0) {
                            Spacer()
                            chatBottomBar
                                .background(Color.white.ignoresSafeArea())
                            
                        }
                    }
                    .navigationTitle(chatUser?.email ?? "")
                    .navigationBarTitleDisplayMode(.inline)
                    //       .navigationBarItems(trailing: Button(action: {
                    //             vm.count += 1
                    //        }, label: {
                    //             Text("Count: \(vm.count)")
                    //       }))
                }
                
                static let emptyScrollToString = "Empty"
                
                private var messagesView: some View {
                    VStack {
                        if #available(iOS 15.0, *) {
                            ScrollView {
                                ScrollViewReader { scrollViewProxy in
                                    VStack {
                                        ForEach(vm.chatMessages) { message in
                                            MessageView(message: message)
                                            
                                        }
                                        
                                        HStack{ Spacer() }
                                            .id(Self.emptyScrollToString)
                                    }
                                    .onReceive(vm.$count) { _ in
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                                        }
                                    }
                                }
                                
                            }
                            .background(Color(.init(white: 0.95, alpha: 1)))
                            .safeAreaInset(edge: .bottom) {
                                chatBottomBar
                                    .background(Color(.systemBackground))
                                    .ignoresSafeArea()
                            }
                        } else {
                            //fallback on earlier versions
                        }
                    }
                }
                
                
                private var chatBottomBar: some View {
                    HStack(spacing: 16) {
                        VStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                            }
                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(.darkGray))
                            }
                            .sheet(isPresented: $isShowingImagePicker) {
                                ImagePicker(image: $selectedImage)
                            }
                        }
                        ZStack {
                            DescriptionPlaceholder()
                            TextEditor(text: $vm.chatText)
                                .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                        }
                        .frame(height: 40)
                        
                        Button {
                            vm.handleSend()
                        } label: {
                            Text("Send")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        
        struct MessageView: View {
            
            let message: ChatMessage
            
            var body: some View {
                VStack {
                    if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                        HStack {
                            Spacer()
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        
                    } else {
                        HStack {
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    
    struct DescriptionPlaceholder: View {
        var body: some View {
            HStack {
                Text("Description")
                    .foregroundColor(Color(.gray))
                    .font(.system(size: 17))
                    .padding(.leading, 5)
                    .padding(.top, -4)
                Spacer()
            }
        }
    }
}
                
                struct ChatLogView_Previews: PreviewProvider {
                    static var previews: some View {
                        //   NavigationView {
                        //   ChatLogView(chatUser: .init(data: ["uid" : "XG02f1D2WlaL16UWV8sudgTgZZO2", "email":
                        //                                    "waterfall@gmail.com"]))
                        MainMessagesView()
                    }
                    
                }
                
