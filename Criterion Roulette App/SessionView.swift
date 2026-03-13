//
//  SessionView.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/5/26.
//

import SwiftUI

struct SessionView: View {
    @State private var runNumber: Int = 0
    
    var body: some View {
        ZStack() {
            Image("merchants")
                .scaledToFit()
            
            VStack() {
                Text("Session")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Runs: \(runNumber)")
                    .font(.title)
                    .padding()
                
                Button("Start Run", action: startRun)
                    .padding()
                .buttonStyle(.borderedProminent)
                
                Button {
                    startRun()
                } label: {
                    Label("Start Run", systemImage: "play.fill")
                }
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
    private func startRun() {
        runNumber += 1
    }
}

#Preview {
    SessionView()
}
