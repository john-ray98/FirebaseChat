//
//  TabViews.swift
//  FirebaseChat
//
//  Created by John Ray on 5/26/23.
//

import SwiftUI

struct TabViews: View {
    var body: some View {
        TabView {
            MainMessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message" )
                }
            Text("Future Chat room")
                .tabItem {
                    Label("Support Room", systemImage: "person.3")
                }
        }
    }
}

struct TabViews_Previews: PreviewProvider {
    static var previews: some View {
        TabViews()
    }
}
