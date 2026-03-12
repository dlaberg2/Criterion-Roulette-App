//
//  PartyView.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/5/26.
//

import SwiftUI

struct PartyView: View {
    @Binding var partyMember1: String
    @Binding var partyMember2: String
    @Binding var partyMember3: String
    @Binding var partyMember4: String
    var body: some View {
        NavigationStack() {
            ZStack() {
                Image("merchants")
                
                VStack {
                    Text("Party Members")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .padding()
                    
                    Text("1. \(partyMember1)")
                    Text("2. \(partyMember2)")
                    Text("3. \(partyMember3)")
                    Text("4. \(partyMember4)")
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
        }
    }
}

#Preview {
    PartyView(partyMember1: .constant("Tyss"), partyMember2: .constant("Chiyo"), partyMember3: .constant("Godly"), partyMember4: .constant("Lance"))
}
