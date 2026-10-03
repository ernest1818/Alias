//
//  AliasUITests.swift
//  AliasUITests
//
//  Created by Ernest Avagovich on 16.01.2025.
//

import XCTest

final class AliasUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testContinueRemainsVisibleButDisabledWithoutSavedGame() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestResetSavedGame"]
        app.launch()

        let continueButton = app.buttons["entrance.1"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 3))
        XCTAssertTrue(continueButton.label.contains("Continue Game"))
        XCTAssertFalse(continueButton.isEnabled)

        let newGameButton = app.buttons["entrance.2"]
        XCTAssertTrue(newGameButton.exists)
        XCTAssertTrue(newGameButton.label.contains("New Game"))
        XCTAssertTrue(newGameButton.isEnabled)

        let rulesButton = app.buttons["entrance.3"]
        XCTAssertTrue(rulesButton.exists)
        XCTAssertTrue(rulesButton.label.contains("Rules"))
        XCTAssertTrue(rulesButton.isEnabled)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
