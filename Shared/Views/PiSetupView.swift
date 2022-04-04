//
//  PiSetupView.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/2/22.
//

import SwiftUI

struct PiSetupView: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Lego Dimensions\nToy Pad")
                .font(.largeTitle)
            Text("Enter the IP address of your raspberry pi")
            HStack(spacing: 30) {
                TextField("IP Address", text: $networkManager.ipAddress)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                
                Button {
                    networkManager.connect()
                } label: {
                    Text("Connect")
                        .padding(5)
                }
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(4)
            }
            .padding()
        }
    }
}

struct PiSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PiSetupView()
    }
}
