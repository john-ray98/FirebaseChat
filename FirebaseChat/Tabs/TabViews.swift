//
//  TabViews.swift
//  FirebaseChat
//
//  Created by John Ray on 5/26/23.
//

import SwiftUI

struct TabViews: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message" )
                }
                .tag(0)
            
            OpenChatRoom()
                .tabItem {
                    Label("Support Room", systemImage: "person.3")
                }
                .tag(1)
        }
    }
}

struct TabViews_Previews: PreviewProvider {
    static var previews: some View {
        TabViews()
    }
}
