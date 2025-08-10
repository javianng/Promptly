//
//  ContentView.swift
//  Promptly
//
//  Created by Javian Ng on 10/8/25.
//
//  Note: This view is no longer used since the app now runs as a menubar application
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "wand.and.rays")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Promptly is running in the menubar!")
                .font(.headline)
            Text("Press Option + Spacebar after selecting text to open query dialog")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
