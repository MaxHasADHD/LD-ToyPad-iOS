//
//  NetworkManager.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import Foundation
import SocketIO
import SwiftUI

final class NetworkManager: ObservableObject {
    
    // MARK: - Properties
    
    enum Constants {
        static let toyTags = "/json/toytags.json"
        static let characters = "/json/charactermap.json"
        static let vehicles = "/json/tokenmap.json"
    }
    
    enum Status {
        // Connected to Pi, Recognized by LD
        case ready
        // Connected to pi, waiting for LD to recognize
        case connected
        // Looking for Pi
        case connecting
        // Not connected or in the process of connecting.
        case disconnected

        var description: String? {
            switch self {
                case .ready, .disconnected:
                    return nil
            case .connected:
                return "Waiting for Console"
            case .connecting:
                return "Looking for Pi"
            }
        }
    }
    
    @AppStorage("IPAddress") var ipAddress: String = ""
    @Published private(set) var status: Status = .disconnected
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    var onRefreshTokens: (() -> Void)?
    var onColorAll: ((ColorAll) -> Void)?
    var onColorOne: ((ColorOne) -> Void)?
    var onFadeAll: ((FadeAll) -> Void)?
    var onFadeOne: ((FadeOne) -> Void)?
    
    // MARK: - Actions
    
    func connect() {
        guard status == .disconnected else { return }
        self.status = .connecting
        
        print("Connecting to \(ipAddress)")
        
        guard ipAddress.isEmpty == false else { return }
        
        manager = SocketManager(socketURL: URL(string: "http://" + ipAddress)!, config: [.log(false), .compress])
        socket = manager.defaultSocket

        // Connection events
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            self?.status = .connected
            // Socket will reply with `Connection True` if the toypad is connected to the game
            self?.socket.emit("connectionStatus")
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            self?.status = .disconnected
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("Error: \(data)")
        }
        
        // Emitted when database has been updated
        socket.on("refreshTokens") { [weak self] data, ack in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.onRefreshTokens?()
            }
        }
        
        // Emitted when the game has discovered the toypad
        socket.on("Connection True") { [weak self] data, ack in
            self?.status = .ready
        }
        
        // Emitted with colors for all 3 gamepads
        socket.on("Color All") { [weak self] data, ack in
            guard
                let d = data.first as? [Any],
                let hexes = d as? [String],
                hexes.count == 3
            else { return }
            let colorData = ColorAll(
                centerPadColor: Color(hexes[0]) ?? .white,
                leftPadColor: Color(hexes[1]) ?? .white,
                rightPadColor: Color(hexes[2]) ?? .white
            )
            self?.onColorAll?(colorData)
        }
        
        // Emitted with pad number and color
        socket.on("Color One") { [weak self] data, ack in
            guard
                let d = data.first as? [Any],
                let padNumber = d[0] as? Int,
                let padHex =  d[1] as? String,
                let padColor = Color(padHex)
            else { return }
            let colorData = ColorOne(padNumber: padNumber, padColor: padColor)
            self?.onColorOne?(colorData)
        }
        
        // Emitted with fade information for all 3 gamepads
        socket.on("Fade All") { [weak self] data, ack in
            guard
                let d = data.first as? [Any],
                let speed = d[0] as? Int,
                let cycles = d[1] as? Int,
                let centerColor = Color(d[2] as! String + "80"),
                let leftColor = Color(d[5] as! String + "80"),
                let rightColor = Color(d[8] as! String + "80")
            else { return }
            let fadeData = FadeAll(
                center: FadeAll.FadeInfo(padSpeed: speed, padCycles: cycles, padColor: centerColor),
                left: FadeAll.FadeInfo(padSpeed: speed, padCycles: cycles, padColor: leftColor),
                right: FadeAll.FadeInfo(padSpeed: speed, padCycles: cycles, padColor: rightColor)
            )
            self?.onFadeAll?(fadeData)
        }
        
        // Emitted with pad number and fade information
        socket.on("Fade One") { [weak self] data, ack in
            guard
                let d = data.first as? [Any],
                let padNumber = d[0] as? Int,
                let padSpeed = d[1] as? Int,
                let padCycles = d[2] as? Int,
                let padColor = Color(d[3] as! String + "80")
            else { return }
            let fadeData = FadeOne(padNumber: padNumber, padSpeed: padSpeed, padCycles: padCycles, padColor: padColor)
            self?.onFadeOne?(fadeData)
        }
        
        socket.connect(timeoutAfter: 15) {
            print("Failed to connect with Pi")
            self.status = .disconnected
        }
    }
    
    func sync() {
        socket.emit("syncToyPad", completion: {
            print("posted sync")
        })
    }
    
    /* Toys in the toybox and on the toy pad */
    func getToyTags() async throws -> [ToyTag] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://" + ipAddress + Constants.toyTags)!)
        return try JSONDecoder().decode([ToyTag].self, from: data)
    }
    
    func getCharacters() async throws -> [Character] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://" + ipAddress + Constants.characters)!)
        return try JSONDecoder().decode([Character].self, from: data)
    }
    
    func getVehicles() async throws -> [Vehicle] {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "http://" + ipAddress + Constants.vehicles)!)
        return try JSONDecoder().decode([Vehicle].self, from: data)
    }
    
    func addCharacterToToybox(_ character: Character) async throws {
        var request = URLRequest(url: URL(string: "http://" + ipAddress + "/character")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(String("{ \"id\" : \(character.id) }").utf8)
        let (_, response) = try await URLSession.shared.data(for: request)
        print(response)
    }
    
    func addVehicleToToybox(_ vehicle: Vehicle) async throws {
        var request = URLRequest(url: URL(string: "http://" + ipAddress + "/vehicle")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(String("{ \"id\" : \(vehicle.id) }").utf8)
        let (_, response) = try await URLSession.shared.data(for: request)
        print(response)
    }
    
    private struct PlaceToyBody: Encodable {
        let position: ToyPad.Panel
        let index: Int
        let id: Int
        let uid: String
    }
    
    func placeToy(_ toy: ToyTag, on panel: ToyPad.Panel, at index: Int) async throws -> Bool {
        var request = URLRequest(url: URL(string: "http://" + ipAddress + "/characterPlace")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PlaceToyBody(position: panel, index: index, id: toy.id, uid: toy.uid)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        return (response as? HTTPURLResponse)?.statusCode ?? 0 == 200
    }
    
    private struct RemoveToyBody: Encodable {
        let index: Int
        let uid: String
    }
    
    /* Remove toy from pad and put back in box */
    func removeToy(_ toy: ToyTag, from index: Int) async throws {
        var request = URLRequest(url: URL(string: "http://" + ipAddress + "/remove")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RemoveToyBody(index: index, uid: toy.uid)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        print(response)
    }

}
