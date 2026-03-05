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
        ZStack {
            Color(.darkGray)
                .ignoresSafeArea(edges: .all)
            
            VStack(alignment: .leading, spacing: 16) {
                Image("niagara_falls")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                HStack {
                    Text("Niagara Falls")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.leadinghalf.filled")
                        }
                        Text("(Reviews 361)")
                    }
                    .foregroundStyle(.orange)
                    .font(.caption)
                }
                
                Text("Come visit for an experience of a lifetime.")
                
                HStack {
                    Spacer()
                    Image(systemName: "fork.knife")
                    Image(systemName: "binoculars.fill")
                }
                .foregroundStyle(.gray)
                .font(.caption)
            }
            .padding()
            .background() {
                Rectangle()
                    .foregroundStyle(.white)
                    .cornerRadius(16)
                    .shadow(radius: 15)
            }
            .padding()
        }
        
        
    }
}

#Preview {
    ContentView()
}
