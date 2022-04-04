//
//  ToyPadContainer.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import SwiftUI

struct ToyPadContainer: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var toyBox: ToyBox
    @EnvironmentObject var toyPad: ToyPad

    var body: some View {
        NavigationView {
            VStack {
                ToyPadView()
            }
            .navigationTitle("Toy Pad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        networkManager.sync()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
        }
    }
}

struct Toy: View {
    let tag: ToyTag
    
    var color: Color {
        switch tag.type {
        case .character:
            return .yellow
        case . vehicle:
            return .green
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .overlay {
                Text(tag.name)
                    .foregroundColor(.black)
            }
            .frame(width: 100, height: 100)
    }
}

struct ToyBoxView: View {
    let tags: [ToyTag]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags, id: \.self) {
                    Toy(tag: $0)
                }
            }
        }
    }
}

//struct ToyPadView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToyPadView()
//    }
//}
