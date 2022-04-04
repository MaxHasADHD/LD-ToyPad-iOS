//
//  ContentView.swift
//  Shared
//
//  Created by Maximilian Litteral on 4/1/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        switch networkManager.status {
            case .ready:
                EmulatorContainer(networkManager: networkManager)
                    .environmentObject(networkManager)
            case .connecting, .connected:
                StartupView()
                    .environmentObject(networkManager)
            case .disconnected:
                PiSetupView()
                    .environmentObject(networkManager)                
        }
    }
}
