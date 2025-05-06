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
            SpinnerView()
                .tabItem {
                    Label("Spinner", systemImage: "rotate.3d")
                }
            RefreshView()
                .tabItem {
                    Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                }
            CatRunView()
                .tabItem {
                    Label("CatRun", systemImage: "cat")
                }
        }
    }
}

#Preview {
    MainTabView()
}
