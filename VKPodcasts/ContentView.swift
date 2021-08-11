//
//  ContentView.swift
//  VKPodcasts
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PlayerView(currentSpeedId: 2, volume: 0.7)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
