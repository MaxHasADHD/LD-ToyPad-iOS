//
//  ToyPadTests.swift
//  LegoDimensionsToyPadTests
//
//  Created by Maximilian Litteral on 4/1/22.
//

import XCTest
@testable import LegoDimensionsToyPad

class ToyPadTests: XCTestCase {

    func testPanelRetreival() {
        let toyPad = ToyPad()
        toyPad.place(toy: ToyTag(name: "Batman", id: 1, uid: "", index: "-1", type: .character, vehicleUpgradesP23: 0, vehicleUpgradesP25: 0), at: ToyPad.TagIndex(panel: .left, index: 1))
        toyPad.place(toy: ToyTag(name: "Batman", id: 1, uid: "", index: "-1", type: .character, vehicleUpgradesP23: 0, vehicleUpgradesP25: 0), at: ToyPad.TagIndex(panel: .left, index: 4))
        toyPad.place(toy: ToyTag(name: "Batman", id: 1, uid: "", index: "-1", type: .character, vehicleUpgradesP23: 0, vehicleUpgradesP25: 0), at: ToyPad.TagIndex(panel: .left, index: 5))
        
        XCTAssert(toyPad.toys(on: .left).count == 3)
        XCTAssert(toyPad.toys(on: .right).isEmpty)
    }

}
