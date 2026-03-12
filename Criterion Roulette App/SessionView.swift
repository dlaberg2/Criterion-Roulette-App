//
//  SessionView.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/5/26.
//

import SwiftUI

struct SessionView: View {
    var body: some View {
        var runNumber: Int = 0
        ZStack() {
            Image("merchants")
                .scaledToFit()
            
            VStack() {
                Text("Session")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Run: \(runNumber)")
                    .font(.title)
                    .padding()
                
                
            }
        }
    }
}

#Preview {
    SessionView()
}
