// NewGameView.swift

import SwiftUI

struct NewGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var oppID: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigateToMenu: Bool = false  // Added state variable

    func startNewGame() {
        guard let playerOneID = UserDefaults.standard.string(forKey: "userid") else {
            print("User ID not found")
            return
        }

        // Construct the URL for checking the opponent ID in the users collection
        guard let url = URL(string: "https://zapped-526f3-default-rtdb.firebaseio.com/users/\(oppID).json") else {
            // Replace "your-firebase-project-id" with your actual Firebase project ID
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                // Print the response to the console
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }

                do {
                    // Parse the response data
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if json["uid"] != nil {
                            // Opponent user found, proceed to start the game
                            GameFunctions.startNewGame(playerOneID: playerOneID, playerTwoID: oppID) { newGameID in
                                if let newGameID = newGameID {
                                    print("New game started! Game ID: \(newGameID)")
                                    // Set the state variable to true to trigger navigation
                                    navigateToMenu = true
                                } else {
                                    print("Failed to start a new game")
                                }
                            }
                        } else {
                            // Opponent user not found, navigate to error view
                            errorMessage = "User Not Found. Please make sure ID is correct"
                        }
                    } else {
                        print("Invalid response format")
                    }
                } catch {
                    print("JSON Parsing Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    var body: some View {
        NavigationView {  // Wrap the view in NavigationView
            Group {
                if UserDefaults.standard.string(forKey: "userid") != nil {
                    VStack {
                        Text("Who would you like to start a game with?")
                        TextField("Opponent ID", text: $oppID)
                        Button("Enter") {
                            startNewGame()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }
                } else {
                    Text("Go to settings to enter userid")
                }
            }
            .navigationBarHidden(true)  // Hide the navigation bar for this view
        }
    }
}

struct NewGameView_Previews: PreviewProvider {
    static var previews: some View {
        NewGameView()
    }
}
