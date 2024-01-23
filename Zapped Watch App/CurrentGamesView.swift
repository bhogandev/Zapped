//
//  CurrentGamesView.swift
//  Zapped Watch App
//
//  Created by Brandon Hogan on 1/21/24.
//

import SwiftUI

struct CurrentGamesView: View {
    @State private var games: [Game] = []
    @State private var errorMessage: String? = nil
    @State private var isFetching: Bool = false
    
    func fetchCurrentGames() {
        guard let userID = UserDefaults.standard.string(forKey: "userid") else {
            print("User ID not found")
            return
        }
        
        let currentTimestamp = ISO8601DateFormatter().string(from: Date())
        
        let urlBase = "https://zapped-526f3-default-rtdb.firebaseio.com/games.json"
        let urlParams = "?orderBy=\"game_end\"&startAt=\"\(currentTimestamp)\""
        let urlString = "\(urlBase)\(urlParams)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isFetching = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                isFetching = false
                return
            }
            
            if let data = data {
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response JSON: \(jsonString)")
                    }
                    
                    if let gamesData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] {
                        var fetchedGames: [Game] = []
                        
                        for (gameID, gameInfo) in gamesData {
                            if let playerOneID = gameInfo["player_one"] as? String,
                               let playerTwoID = gameInfo["player_two"] as? String,
                               userID == playerOneID || userID == playerTwoID {
                                
                                if let game = parseGameData(gameID: gameID, gameInfo: gameInfo) {
                                    fetchedGames.append(game)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            games = fetchedGames
                            errorMessage = fetchedGames.isEmpty ? "No games found" : nil
                            isFetching = false
                            print("Fetched Games: \(fetchedGames)")
                        }
                    } else {
                        print("Invalid response format")
                        isFetching = false
                    }
                } catch {
                    print("JSON Parsing Error: \(error.localizedDescription)")
                    isFetching = false
                }
            } else {
                print("No data received")
                isFetching = false
            }
        }.resume()
    }
    
    func parseGameData(gameID: String, gameInfo: [String: Any]) -> Game? {
        guard
            let changeDateTime = gameInfo["changeDateTime"] as? String,
            let createDateTime = gameInfo["createDateTime"] as? String,
            let gameEnd = gameInfo["game_end"] as? String,
            let gameStart = gameInfo["game_start"] as? String,
            let gameWinner = gameInfo["game_winner"] as? String,
            let playerOne = gameInfo["player_one"] as? String,
            let playerOneFinalScore = gameInfo["player_one_final_score"] as? Int,
            let playerTwo = gameInfo["player_two"] as? String,
            let playerTwoFinalScore = gameInfo["player_two_final_score"] as? Int
        else {
            return nil
        }
        
        let game = Game(
            id: gameID,
            changeDateTime: changeDateTime,
            createDateTime: createDateTime,
            startTimestamp: gameStart,
            endTimestamp: gameEnd,
            gameWinnerID: gameWinner,
            playerOneID: playerOne,
            playerOneFinalScore: playerOneFinalScore,
            playerTwoID: playerTwo,
            playerTwoFinalScore: playerTwoFinalScore
        )
        return game
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    fetchCurrentGames()
                }) {
                    Text("Get Current Games")
                }

                if isFetching {
                    ProgressView()
                } else {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                    } else {
                        if !games.isEmpty {
                            ForEach(games) { game in
                                if let userID = UserDefaults.standard.string(forKey: "userid") {
                                    let opponentID = determineOpponentID(game: game, currentUserID: userID)

                                    NavigationLink(destination: CurrentGamesView(game: game)) {
                                        GameLinkLabel(opponentID: opponentID)
                                    }
                                }
                            }
                        } else {
                            Text("No games found")
                        }
                    }
                }
            }
            .navigationTitle("Current Games")
        }
    }
    
    func determineOpponentID(game: CurrentGamesView.Game, currentUserID: String) -> String {
        return game.playerOneID != currentUserID ? game.playerOneID : game.playerTwoID
    }
    
    struct GameLinkLabel: View {
        var opponentID: String
        
        var body: some View {
            Text("vs. \(opponentID)")
        }
    }
    
    
    struct Game: Identifiable {
        var id: String
        var changeDateTime: String
        var createDateTime: String
        var startTimestamp: String
        var endTimestamp: String
        var gameWinnerID: String
        var playerOneID: String
        var playerOneFinalScore: Int
        var playerTwoID: String
        var playerTwoFinalScore: Int
    }
    
    struct CurrentGamesView_Previews: PreviewProvider {
        static var previews: some View {
            CurrentGamesView()
        }
    }
}
