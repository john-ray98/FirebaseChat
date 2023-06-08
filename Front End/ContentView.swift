//
//  ContentView.swift
//  FirebaseChat
//
//  Created by Jazmine Pickens on 6/8/23.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            TabView {
                ChatView()
                .tabItem {
                    Image(systemName: "bubble.right.circle")
                    Text("Care Chat")
                }

                ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
            }
            
            .onAppear(){
                
                UITabBar.appearance().backgroundColor = .init(Color.backgroundBlue)
            }
        }
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

