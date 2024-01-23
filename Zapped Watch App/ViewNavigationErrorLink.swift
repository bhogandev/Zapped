//
//  ViewNavigationErrorLink.swift
//  Zapped
//
//  Created by Brandon Hogan on 1/22/24.
//

import SwiftUI

extension View {
    func navigationErrorLink<Destination: View>(_ title: String, destination: Destination) -> some View {
        NavigationLink(
            destination: destination,
            label: {
                self
            })
            .navigationBarTitle(title)
    }
}

