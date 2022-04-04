//
//  Character.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation

struct Character: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let world: World
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum World: String, Codable {
    case dcComics = "DC Comics"
    case lotr = "Lord of the Rings"
    case legoMovie = "The LEGO Movie"
    case simpsons = "The Simpsons"
    case portal2 = "Portal 2"
    case ninjago = "Ninjago"
    case chima = "Legends of Chima"
    case doctorWho = "Doctor Who"
    case BTTF = "Back to the Future"
    case jurassicPark = "Jurassic Park"
    case midwayArcade = "Midway Arcade"
    case ghostbusters = "Ghostbusters"
    case scoobyDoo = "Scooby-Doo"
    case wizardOfOz = "Wizard of OZ"
    case ghostbusters2016 = "Ghostbuster 2016"
    case adventureTime = "Adventure Time"
    case missionImpossible = "Mission Impossible"
    case harryPotter = "Harry Potter"
    case knightRider = "Knight Rider"
    case aTeam = "A-Team"
    case fantasticBeasts = "Fantastic Beasts"
    case sonic = "Sonic"
    case gremlins = "Gremlins"
    case et = "E.T."
    case legoBatman = "LEGO Batman Movie"
    case goonies = "Goonies"
    case legoCity = "LEGO City"
    case teenTitans = "Teen Titans Go"
    case beetleJuice = "Beetle Juice"
    case legoDimensions = "Lego Dimensions"
    case powerPuffGirls = "Power Puff Girls"
    case unknown = "Unknown"
    case na = "N/A"
    case world15 = "15"
    case world16 = "16"
    case world17 = "17"
    case world18 = "18"
    case world19 = "19"
    case world20 = "20"
}

enum Abilities {
    // Common
    case acrobat
    case boomerang
    case dive
    case electric
    case fixIt
    case flying
    case hacking
    case illumination
    case laser
    case laserDeflection
    case magic
    case bomb
    case sonar
    case stealth
    case superStrength
    case target
    case technology
}
