//
//  SettingsUserView.swift
//  Zapped Watch App
//
//  Created by Brandon Hogan on 1/22/24.
//

import SwiftUI

struct SettingsUserView: View {
    @State private var userID: String = ""
    @State private var errorMessage: String? = nil

    func checkUserID() {
        // Construct the URL for checking the userID in the users collection
        guard let url = URL(string: "https://zapped-526f3-default-rtdb.firebaseio.com/users/\(userID).json") else {
           
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
                            // User ID found, store it in local storage
                            UserDefaults.standard.set(userID, forKey: "userid")
                            print("User has been set!")

                            // Reset error message
                            errorMessage = nil
                        } else {
                            // User ID not found
                            errorMessage = "Please try again:"
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
        VStack {
            if let storedUserID = UserDefaults.standard.string(forKey: "userid") {
                Text("Your Current UserID:")
                Text(storedUserID)
            } else {
                Text(errorMessage ?? "Please Enter User ID:")
                TextField("User ID", text: $userID)
                Button("Enter") {
                    checkUserID()
                }
            }
        }
    }
}

struct SettingsUserView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsUserView()
    }
}
