//
//  GameFunctions.swift
//  Zapped
//
//  Created by Brandon Hogan on 1/22/24.
//

import Foundation

class GameFunctions {
    static func fetchCurrentGameState(forUserID userID: String, completion: @escaping (String?, String?, String?, String?, String?) -> Void) {
        guard let url = URL(string: "https://your-firebase-project-id.firebaseio.com/scores.json?orderBy=\"game_end\"&limitToLast=1&equalTo=\"\(userID)\"") else {
            
            completion(nil, nil, nil, nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                completion(nil, nil, nil, nil, nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil, nil, nil, nil, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]],
                   let gameId = json.keys.first,
                   let gameData = json[gameId],
                   let playerOne = gameData["player_one"] as? String,
                   let playerTwo = gameData["player_two"] as? String {

                    completion(gameId, playerOne, playerTwo, gameData["game_start"] as? String, gameData["game_end"] as? String)

                } else {
                    print("Invalid response format")
                    completion(nil, nil, nil, nil, nil)
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(nil, nil, nil, nil, nil)
            }
        }.resume()
    }

    static func incrementPlayerScore(gameId: String, currentPlayerID: String, existingGameStartTimestamp: String, existingGameEndTimestamp: String, existingCreateTimestamp: String, existingPlayerOneID: String, existingPlayerTwoID: String, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "https://your-firebase-project-id.firebaseio.com/scores/\(gameId).json") else {
            
            completion(0)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "changeDateTime": ISO8601DateFormatter().string(from: Date()),
            "game_start": existingGameStartTimestamp,
            "game_end": existingGameEndTimestamp,
            "createDateTime": existingCreateTimestamp,
            "player_one": existingPlayerOneID,
            "player_one_score": (currentPlayerID == existingPlayerOneID) ? 1 : 0,
            "player_two": existingPlayerTwoID,
            "player_two_score": (currentPlayerID == existingPlayerTwoID) ? 1 : 0
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        } catch {
            print("JSON Serialization Error: \(error.localizedDescription)")
            completion(0)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                completion(0)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
                completion(httpResponse.statusCode)
            } else {
                completion(0)
            }
        }.resume()
    }
    
    static func startNewGame(playerOneID: String, playerTwoID: String, completion: @escaping (String?) -> Void) {
           guard let gamesURL = URL(string: "https://zapped-526f3-default-rtdb.firebaseio.com/games.json") else {
              
               completion(nil)
               return
           }

           var gamesRequest = URLRequest(url: gamesURL)
           gamesRequest.httpMethod = "POST"
           gamesRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let currentDate = Date()
           let endDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)
           let timestamp = ISO8601DateFormatter().string(from: currentDate)
           let endTimestamp = ISO8601DateFormatter().string(from: endDate!)

           let gameBody: [String: Any] = [
               "changeDateTime": timestamp,
               "createDateTime": timestamp,
               "game_start": timestamp,
               "game_end": endTimestamp,
               "game_winner": "",
               "player_one": playerOneID,
               "player_one_final_score": "",
               "player_two": playerTwoID,
               "player_two_final_score": ""
           ]

           do {
               let gameJsonData = try JSONSerialization.data(withJSONObject: gameBody)
               gamesRequest.httpBody = gameJsonData
           } catch {
               print("JSON Serialization Error: \(error.localizedDescription)")
               completion(nil)
               return
           }

           URLSession.shared.dataTask(with: gamesRequest) { data, response, error in
               if let error = error {
                   print("Request Error: \(error.localizedDescription)")
                   completion(nil)
                   return
               }

               if let data = data,
                  let gameJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let newGameID = gameJson["name"] as? String {

                 
                   guard let scoresURL = URL(string: "https://zapped-526f3-default-rtdb.firebaseio.com/scores.json") else {
                      
                       completion(nil)
                       return
                   }

                   var scoresRequest = URLRequest(url: scoresURL)
                   scoresRequest.httpMethod = "POST"
                   scoresRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

                   // Set up the scores data with default values
                   let scoresBody: [String: Any] = [
                       "gameUID": newGameID,  // Linking the scores to the game
                       "player_one": playerOneID,
                       "player_one_score": 0,
                       "player_two": playerTwoID,
                       "player_two_score": 0,
                       "game_start": timestamp,
                       "game_end": endTimestamp,
                       "createDateTime": timestamp,
                       "changeDateTime": timestamp
                   ]

                   do {
                       let scoresJsonData = try JSONSerialization.data(withJSONObject: scoresBody)
                       scoresRequest.httpBody = scoresJsonData
                   } catch {
                       print("JSON Serialization Error: \(error.localizedDescription)")
                       completion(nil)
                       return
                   }

                   URLSession.shared.dataTask(with: scoresRequest) { _, _, _ in
                       // Ignore the response for simplicity
                
                       // Completion with the new game ID
                       completion(newGameID)
                   }.resume()
               } else {
                   print("Invalid response format")
                   completion(nil)
               }
           }.resume()
       }
}
