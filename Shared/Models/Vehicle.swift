//
//  Vehicle.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation

struct Vehicle: Codable, Hashable, Identifiable {
    let id: Int
    let upgradeMap: Int
    let rebuild: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, rebuild, name
        case upgradeMap = "upgrademap"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
