//
//  ToyPadView.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ToyPadView: View {
    @EnvironmentObject var toyPad: ToyPad
    
    @State var draggingPadIndex: Int?
    
    var body: some View {
        VStack {
            HStack {
                ToySpace(index: 1, draggingPadIndex: $draggingPadIndex)
                Spacer(minLength: 60)
                ToySpace(index: 2, draggingPadIndex: $draggingPadIndex)
                Spacer(minLength: 60)
                ToySpace(index: 3, draggingPadIndex: $draggingPadIndex)
            }
            HStack {
                ToySpace(index: 4, draggingPadIndex: $draggingPadIndex)
                ToySpace(index: 5, draggingPadIndex: $draggingPadIndex)
                Spacer(minLength: 60)
                ToySpace(index: 6, draggingPadIndex: $draggingPadIndex)
                ToySpace(index: 7, draggingPadIndex: $draggingPadIndex)
            }
        }
        .padding(5)
    }
}

private struct ToyUI: View {
    let currentTag: ToyTag?
    var color: Color
    
    var body: some View {
        if let currentTag = currentTag {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .animation(.easeOut(duration: 0.25), value: color)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .overlay {
                    Text(currentTag.name)
                }
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .animation(.easeOut(duration: 0.25), value: color)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
        }
    }
}

private struct ToySpace: View {
    @EnvironmentObject var toyBox: ToyBox
    @EnvironmentObject var toyPad: ToyPad
    
    @Binding var draggingPadIndex: Int?
    
    let padIndex: Int
    
    init(index: Int, draggingPadIndex: Binding<Int?>) {
        self.padIndex = index
        _draggingPadIndex = draggingPadIndex
    }
    
    var body: some View {
        let toy = toyPad.toy(at: padIndex)
        ToyUI(currentTag: toy, color: toyPad.padColors[padIndex - 1])
            .contextMenu {
                if let toy = toy {
                    Button {
                        toyPad.removeToy(at: padIndex)
                    } label: {
                        Text("Remove")
                    }
                    
                    Button {
                        toyPad.place(toy: toy, at: toy.index)
                    } label: {
                        Text("Pickup and drop")
                    }
                } else {
                    ForEach(toyBox.idleTags) { toy in
                        Button {
                            print("Selected \(toy.name) for pad \(padIndex)")
                            toyPad.place(toy: toy, at: padIndex)
                        } label: {
                            Label(toy.name, systemImage: toy.type == .character ? "person.fill" : "car.fill")
                        }
                    }
                }
            }
            .onDrag {
                self.draggingPadIndex = padIndex
                return NSItemProvider(object: "\(padIndex)" as NSString)
            }
            .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(from: draggingPadIndex ?? -1, to: padIndex, toyBox: toyBox, toyPad: toyPad))
    }
}

struct DragRelocateDelegate: DropDelegate {
    let from: Int
    let to: Int
    let toyBox: ToyBox
    let toyPad: ToyPad
    
    func dropEntered(info: DropInfo) {
        
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard from != to else { return false }
        guard toyPad.toy(at: to) == nil else {
            print("Toy already exists, remove or move first")
            return false
        }
        guard let toyToMove = toyPad.toy(at: from) else {
            print("No toy found to move")
            return false
        }
        print("Moving \(toyToMove.name) from \(from) to \(to)")
        Task {
            print("Removing toy from original position")
            await toyBox.remove(toy: toyToMove, from: from)
            print("Moving toy to new position")
            try? await Task.sleep(nanoseconds: 500_000_000)
            let didPlace = await toyBox.place(toy: toyToMove, on: toyPad.panel(for: to), at: to)
            print((didPlace ? "Successfully" : "Failed to") + "move character from \(from) to \(to)")
        }
        return true
    }
}

//struct ToyPad_Previews: PreviewProvider {
//    static var previews: some View {
//        ToyPadView()
//    }
//}
