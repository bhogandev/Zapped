//
//  ContentView.swift
//  Zapped Watch App
//
//  Created by Brandon Hogan on 1/21/24.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    RowView(title: "NewGame", btnText: "Start A New Game", nextView: NewGameView())
                    RowView(title: "OngoingGames", btnText: "Ongoing Games", nextView: CurrentGamesView())
                    RowView(title: "LeaderboardView", btnText: "Leaderboard", nextView: LeaderboardView())
                    RowView(title: "Settings", btnText: "Settings", nextView: SettingsView())
                }
            }
            .padding()
        }
    }
}

struct RowView<TargetView: View>: View {
    let title: String
    let btnText: String
    var nextView: TargetView
    var body: some View {
        
        NavigationLink(destination: nextView) {
            Text(btnText)
                .frame(height: 50, alignment: .center)
                .listRowBackground(
                    Color.white
                        .cornerRadius(12)
                )
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
