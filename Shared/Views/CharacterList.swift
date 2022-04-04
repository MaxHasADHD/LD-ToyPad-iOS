//
//  CharacterList.swift
//  LegoDimensionsToyPad
//
//  Created by Maximilian Litteral on 4/1/22.
//

import SwiftUI

struct CharacterList: View {
    @EnvironmentObject var toyBox: ToyBox
    
    var body: some View {
        NavigationView {
            List {
                ForEach(toyBox.characters, id: \.self) { character in
                    HStack {
                        Text(character.name)
                        Spacer()
                        Button {
                            let _ = print("Adding \(character.name) to toy box")
                            toyBox.add(character: character)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .padding(.leading, 0)
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .navigationTitle("Characters")
        }
        .onAppear {
            toyBox.getCharacters()
        }
    }
}

//struct CharacterList_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacterList(toyBox: ToyBox())
//    }
//}
