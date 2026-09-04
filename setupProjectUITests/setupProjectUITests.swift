//
//  setupProjectUITests.swift
//  setupProjectUITests
//
//  Created by it on 31.05.2026.
//

import XCTest

final class setupProjectUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        
        sleep(5)
        
        let loginTextField = webView.descendants(matching: .textField).element
        
        
        loginTextField.tap()
        loginTextField.typeText("enter ur gmail")
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssert(passwordTextField.waitForExistence(timeout: 3))
        passwordTextField.tap()
        passwordTextField.typeText("enter ur passw")
        
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        sleep(5)
        
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["noLike"].tap()
        sleep(1)
        cellToLike.buttons["like"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["backButton"]
        backButton.tap()
    }
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(2)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["name, lastName"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            app.buttons["quit"].tap()
            
            app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        
    }
}
