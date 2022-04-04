//
//  ToyPad.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation
import Combine
import SwiftUI

final class ToyPad: ObservableObject {
    
    // MARK: - Structures
    
    private enum Constants {
        static let leftPanel = [1, 4, 5]
        static let rightPanel = [3, 6, 7]
        static let centerPanel = 2
    }
    
    enum Panel: Int, Codable {
        case all = 0
        case center = 1
        case left = 2
        case right = 3
        
        var padNumbers: [Int] {
            switch self {
                case .all:
                    return Array(1...7)
                case .center:
                    return [Constants.centerPanel]
                case .left:
                    return Constants.leftPanel
                case .right:
                    return Constants.rightPanel
            }
        }
    }
    
    private var cachedColors = Array(repeating: Color("#e8eaf6") ?? .white, count: 7)
    @Published var padColors = Array(repeating: Color("#e8eaf6") ?? .white, count: 7)
    
    // MARK: - Properties
    
    @Published private var tags: [Int: ToyTag] = [:]
    let toyBox: ToyBox
    private var bag = Set<AnyCancellable>()
    
    init(toyBox: ToyBox) {
        self.toyBox = toyBox
        
        toyBox.$tags
            .sink { toyTags in
                print("Toy tags were updated: \(toyTags.count)")
                let tagsOnBoard = toyTags.filter { $0.index != -1 }
                var tags = [Int: ToyTag]()
                tagsOnBoard.forEach { tag in
                    tags[tag.index] = tag
                }
                print("Toypad was updated: \(tags)")
                self.tags = tags
            }
            .store(in: &bag)
        
        toyBox.getToys()
        
        toyBox.networkManager.onColorOne = { colorOne in
            self.panel(for: colorOne.padNumber).padNumbers.forEach {
                self.cachedColors[$0 - 1] = colorOne.padColor
                self.padColors[$0 - 1] = colorOne.padColor
            }
        }
        toyBox.networkManager.onColorAll = { colorAll in
            self.padColors.indices.forEach {
                let padIndex = $0 + 1
                if Constants.leftPanel.contains(padIndex) {
                    self.cachedColors[$0] = colorAll.leftPadColor
                    self.padColors[$0] = colorAll.leftPadColor
                } else if Constants.rightPanel.contains(padIndex) {
                    self.cachedColors[$0] = colorAll.rightPadColor
                    self.padColors[$0] = colorAll.rightPadColor
                } else {
                    self.cachedColors[$0] = colorAll.centerPadColor
                    self.padColors[$0] = colorAll.centerPadColor
                }
            }
        }
        toyBox.networkManager.onFadeOne = { fadeOne in
            self.panel(for: fadeOne.padNumber).padNumbers.forEach { padNumber in
                let padIndex = padNumber - 1
                self.padColors[padIndex] = fadeOne.padColor
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(fadeOne.padSpeed * 100)) {
//                    self.padColors[padIndex] = self.cachedColors[padIndex]
//                }
            }
        }
        toyBox.networkManager.onFadeAll = { fadeAll in
            self.padColors.indices.forEach { padIndex in
                let padNumber = padIndex + 1
                if Constants.leftPanel.contains(padNumber) {
                    self.padColors[padIndex] = fadeAll.left.padColor
                } else if Constants.rightPanel.contains(padNumber) {
                    self.padColors[padIndex] = fadeAll.right.padColor
                } else {
                    self.padColors[padIndex] = fadeAll.center.padColor
                }
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(fadeAll.center.padSpeed * 100)) {
//                    self.padColors[padIndex] = self.cachedColors[padIndex]
//                }
            }
        }
    }
    
    // MARK: - Actions
    
    func panel(for index: Int) -> Panel {
        if Constants.leftPanel.contains(index) {
            return .left
        } else if Constants.rightPanel.contains(index) {
            return .right
        } else {
            return .center
        }
    }
    
    func place(toy: ToyTag, at index: Int) {
        tags[index] = toy
        Task {
            await toyBox.place(toy: toy, on: panel(for: index), at: index)
        }
    }
    
    func toys(on panel: Panel) -> [ToyTag] {
        switch panel {
        case .all:
            return Array(tags.values)
        case .center:
            return Array(tags.filter { $0.key == 2 }.values)
        case .left:
            return Array(tags.filter { (key, _) in Constants.leftPanel.contains(key) }.values)
        case .right:
            return Array(tags.filter { (key, _) in Constants.rightPanel.contains(key) }.values)
        }
    }
    
    func toy(at index: Int) -> ToyTag? {
        return tags[index]
    }
    
    func removeToy(at index: Int) {
        guard let toy = tags[index] else { return }
        tags[index] = nil
        Task {
            await toyBox.remove(toy: toy, from: index)
        }
    }
}
