//
//  MainMenuView.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/5/26.
//

import SwiftUI

struct MainMenuView: View {
    @State private var partyMember1: String = "Tyss"
    @State private var partyMember2: String = "None"
    @State private var partyMember3: String = "None"
    @State private var partyMember4: String = "None"
    
    var body: some View {
        NavigationStack{
            ZStack() {
                Image("merchants")
                    .scaledToFit()
                
                VStack() {
                    Text("Criterion Roulette")
                        .font(.title)
                        .bold()
                    
                    NavigationLink("Start a Session"){
                        SessionView()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    NavigationLink("Set Party Members") {
                        PartyView(
                            partyMember1: $partyMember1,
                            partyMember2: $partyMember2,
                            partyMember3: $partyMember3,
                            partyMember4: $partyMember4
                        )
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    Text("Current Party Members:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("1. \(partyMember1)")
                        .font(.subheadline)
                    
                    Text("2. \(partyMember2)")
                        .font(.subheadline)
                    
                    Text("3. \(partyMember3)")
                        .font(.subheadline)
                    
                    Text("4. \(partyMember4)")
                        .font(.subheadline)
                }
                .padding()
                .background() {
                    Rectangle()
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black, radius: 10)
                        .opacity(0.7)
                }
            }
            .padding()
        }
        .navigationTitle("Criterion Roulette")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    MainMenuView()
}
