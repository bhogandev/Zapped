//
//  SettingsView.swift
//  Zapped Watch App
//
//  Created by Brandon Hogan on 1/21/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            RowView(title: "Set User Id", btnText: "Set UserID", nextView: SettingsUserView())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
