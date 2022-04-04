//
//  ColorData.swift
//  LegoDimensionsToyPad (iOS)
//
//  Created by Maximilian Litteral on 4/3/22.
//

import Foundation
import SwiftUI

struct FadeOne {
    let padNumber: Int
    let padSpeed: Int
    let padCycles: Int
    let padColor: Color
}

struct FadeAll {
    struct FadeInfo {
        let padSpeed: Int
        let padCycles: Int
        let padColor: Color
    }
    
    let center: FadeInfo
    let left: FadeInfo
    let right: FadeInfo
}

struct ColorOne {
    let padNumber: Int
    let padColor: Color
}

struct ColorAll {
    let centerPadColor: Color
    let leftPadColor: Color
    let rightPadColor: Color
}
