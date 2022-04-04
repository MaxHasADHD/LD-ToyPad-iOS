//
//  StartupView.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/2/22.
//

import SwiftUI

struct StartupView: View {
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text(networkManager.status.description ?? "Unknown state")
                .font(.largeTitle)
            ProgressView()
                .progressViewStyle(.circular)
                .foregroundColor(.blue)
        }
        .onAppear {
            networkManager.connect()
        }
    }
}
