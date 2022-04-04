//
//  ToyTag.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation

struct ToyTag: Decodable, Hashable, Identifiable {
    let name: String
    let id: Int
    let uid: String
    var index: Int
    let type: TagType
    let vehicleUpgradesP23: Int
    let vehicleUpgradesP25: Int
    
    enum TagType: String, Codable {
        case character, vehicle
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uid)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id, uid, index, type, vehicleUpgradesP23, vehicleUpgradesP25
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(Int.self, forKey: .id)
        uid = try container.decode(String.self, forKey: .uid)
        if let stringIndex = try? container.decode(String.self, forKey: .index) {
            index = Int(stringIndex) ?? -1
        } else {
            index = try container.decode(Int.self, forKey: .index)
        }
        type = try container.decode(TagType.self, forKey: .type)
        vehicleUpgradesP23 = try container.decode(Int.self, forKey: .vehicleUpgradesP23)
        vehicleUpgradesP25 = try container.decode(Int.self, forKey: .vehicleUpgradesP25)
    }
}
