//
//  ToyBox.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation

final class ToyBox: ObservableObject {
    
    // MARK: - Properties
    
    let networkManager: NetworkManager
    
    @Published var tags = [ToyTag]() {
        didSet {
            print("Updated toys: \(tags)")
        }
    }
    @Published var characters = [Character]() {
        didSet {
            print("Updated characters: \(characters)")
        }
    }
    @Published var vehicles = [Vehicle]() {
        didSet {
            print("Updated vehicles: \(vehicles)")
        }
    }
    
    // Tags not on the board
    var idleTags: [ToyTag] {
        tags.filter { $0.index == -1 }
    }
    
    // Tags in play
    var tagsOnBoard: [ToyTag] {
        tags.filter { $0.index != -1 }
    }
    
    // MARK: - Lifecycle
    
    init(networkManager: NetworkManager) {
        print("Toy box init")
        self.networkManager = networkManager
        
        networkManager.onRefreshTokens = { [weak self] in
            self?.getToys()
        }
    }
    
    // MARK: - Actions
    
    func getToys() {
        Task {
            do {
                print("Fetching toys")
                let toys = try await networkManager.getToyTags()
                DispatchQueue.main.async {
                    print("Toys updated")
                    self.tags = toys
                }
            } catch {
                print("failed to get toys: \(error)")
            }
        }
    }
    
    func getCharacters() {
        guard characters.isEmpty else { return }
        Task {
            do {
                let characters = try await networkManager.getCharacters()
                DispatchQueue.main.async {
                    self.characters = characters
                }
            } catch {
                print("Failed to get characters: \(error)")
            }
        }
    }
    
    func getVehicles() {
        guard vehicles.isEmpty else { return }
        Task {
            do {
                let vehicles = try await networkManager.getVehicles()
                DispatchQueue.main.async {
                    self.vehicles = vehicles
                }
            } catch {
                print("Failed to get vehicles: \(error)")
            }
        }
    }
    
    // MARK: - Add tags to toybox
    
    func add(character: Character) {
        Task {
            do {
                try await networkManager.addCharacterToToybox(character)
            } catch {
                print("Failed to add \(character.name) to toybox: \(error)")
            }
        }
    }
    
    func add(vehicle: Vehicle) {
        Task {
            do {
                try await networkManager.addVehicleToToybox(vehicle)
            } catch {
                print("Failed to add \(vehicle.name) to toybox: \(error)")
            }
        }
    }
    
    // MARK: - Toypad
    
    func place(toy: ToyTag, on panel: ToyPad.Panel, at index: Int) async -> Bool {
        do {
            let didPlace = try await networkManager.placeToy(toy, on: panel, at: index)
            guard didPlace else { return false }
            print("Placed toy on toypad")
            
            DispatchQueue.main.async {
                self.tags.indices
                    .filter { self.tags[$0].uid == toy.uid }
                    .forEach { self.tags[$0].index = index }
            }
            return true
        } catch {
            print("Failed to place toy on toypad: \(error)")
            return false
        }
    }
    
    func remove(toy: ToyTag, from index: Int) async {
        do {
            try await networkManager.removeToy(toy, from: index)
            print("Removed \(toy.name) from toypad")
            DispatchQueue.main.async {
                self.tags.indices
                    .filter { self.tags[$0].uid == toy.uid }
                    .forEach { self.tags[$0].index = -1 }
            }
        } catch {
            print("Failed to remove toy: \(toy), from index \(index)")
        }
    }
}
