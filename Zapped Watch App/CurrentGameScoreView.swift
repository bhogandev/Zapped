//
//  CurrentGameScoreView.swift
//  Zapped Watch App
//
//  Created by Brandon Hogan on 1/22/24.
//

import SwiftUI

struct CurrentGameScoreView: View {
    var game: Game

    var body: some View {
        VStack {
            Text("Game ID: \(game.id)")
            Text("Start: \(game.startTimestamp)")
            Text("End: \(game.endTimestamp)")
            Text("Winner: \(game.gameWinnerID)")
            Text("Player One: \(game.playerOneID), Score: \(game.playerOneFinalScore)")
            Text("Player Two: \(game.playerTwoID), Score: \(game.playerTwoFinalScore)")
        }
        .navigationTitle("Game Details")
    }
}

struct CurrentGameScoreView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleGame = Game(
            id: "sampleID",
            changeDateTime: "sampleChangeDateTime",
            createDateTime: "sampleCreateDateTime",
            startTimestamp: "sampleStartTimestamp",
            endTimestamp: "sampleEndTimestamp",
            gameWinnerID: "sampleGameWinnerID",
            playerOneID: "samplePlayerOneID",
            playerOneFinalScore: 10,
            playerTwoID: "samplePlayerTwoID",
            playerTwoFinalScore: 5
        )

        CurrentGameScoreView(game: sampleGame)
    }
}

