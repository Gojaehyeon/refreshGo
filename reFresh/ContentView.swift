//
//  ContentView.swift
//  reFresh
//
//  Created by 고재현 on 5/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            BannerAdView(adUnitID: "ca-app-pub-5729882423538718/6575074605")
                .frame(width: 320, height: 50)
                .background(Color(.systemBackground))
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
