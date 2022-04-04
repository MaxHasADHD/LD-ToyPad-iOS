//
//  EmulatorContainer.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/2/22.
//

import SwiftUI

struct EmulatorContainer: View {
    
    // MARK: - State
    
    @EnvironmentObject var networkManager: NetworkManager
    
    @StateObject var toyBox: ToyBox
    @StateObject var toyPad: ToyPad
    
    // MARK: - Initializer
    
    init(networkManager: NetworkManager) {
        let tBox = ToyBox(networkManager: networkManager)
        _toyBox = StateObject(wrappedValue: tBox)
        _toyPad = StateObject(wrappedValue: ToyPad(toyBox: tBox))
    }
    
    // MARK: - View
    
    var body: some View {
        TabView {
            ToyPadContainer()
                .tabItem {
                    Label("Toy Pad", systemImage: "apps.ipad.landscape")
                }
            CharacterList()
                .tabItem {
                    Label("Characters", systemImage: "person.crop.circle")
                }
            VehicleList()
                .tabItem {
                    Label("Vehicles", systemImage: "car.2.fill")
                }
        }
        .tabViewStyle(.automatic)
        .environmentObject(networkManager)
        .environmentObject(toyBox)
        .environmentObject(toyPad)
    }
}

//struct EmulatorContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        EmulatorContainer()
//    }
//}
