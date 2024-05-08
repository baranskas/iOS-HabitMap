//
//  ContentView.swift
//  HabitMap
//
//  Created by Martynas Baranskas on 08/05/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OverviewView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            HabitsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Habits")
                }
        }
    }
}

#Preview {
    ContentView()
}
