//
//  MainTabView.swift
//  reFresh
//
//  Created by 고재현 on 5/3/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RefreshView()
                .tabItem {
                    Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                }
            SpinnerView()
                .tabItem {
                    Label("Spinner", systemImage: "rotate.3d")
                }
            CatRunView()
                .tabItem {
                    Label("CatRun", systemImage: "cat.fill")
                }
        }
    }
}


struct CatRunView: View {
    var body: some View {
        Text("Cat Run Placeholder")
            .font(.largeTitle)
    }
}

#Preview {
    MainTabView()
}
