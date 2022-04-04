//
//  VehicleList.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import SwiftUI

struct VehicleList: View {
    @EnvironmentObject var toyBox: ToyBox
    
    var body: some View {
        NavigationView {
            List {
                ForEach(toyBox.vehicles, id: \.self) { vehicle in
                    HStack {
                        Text(vehicle.name)
                        Spacer()
                        Button {
                            let _ = print("Adding \(vehicle.name) to toy box")
                            toyBox.add(vehicle: vehicle)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .padding(.leading, 0)
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .navigationTitle("Vehicles")
        }
        .onAppear {
            toyBox.getVehicles()
        }
    }
}

//struct VehicleList_Previews: PreviewProvider {
//    static var previews: some View {
//        VehicleList()
//    }
//}
