//  ----------------------------------------------------
//
//  ZoundCaseUITestsLaunchTests.swift
//  Version 1.0
//
//  Unique ID:  A3B4E0A8-3407-4B40-B8EB-C012D5870C0C
//
//  part of the ZoundCaseUITests™ product.
//
//  Written in Swift 5.0 on macOS 12.5
//
//  https://github.com/coldpointblue
//  Created by Hugo Diaz on 01/09/22.
//
//  ----------------------------------------------------

//  ----------------------------------------------------
/*  Goal explanation:  Configure UI code tests to ensure app runs smoothly
 and to identify problems as soon as they break any code. */
//  ----------------------------------------------------

import XCTest

class ZoundCaseUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
