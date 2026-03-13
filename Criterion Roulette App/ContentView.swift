//
//  ContentView.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MainMenuView()
                    .navigationTitle(Text("Criterion Roulette"))
            }
            .tabItem {
                Label("Main", systemImage: "house.fill")
                
                Label("Session", systemImage: "play.circle.fill")
            }
            NavigationStack {
                HistoryView()
                    .navigationTitle(Text("Sessions"))
            }
            .tabItem{
                Label("History", systemImage: "book.closed.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
