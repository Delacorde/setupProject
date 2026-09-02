//
//  setupProjectTests_ProfileViewController.swift
//  setupProjectTests_ProfileViewController
//
//  Created by it on 02.09.2026.
//

import XCTest
@testable import setupProject

final class setupProjectTests_ProfileViewController: XCTestCase {

    private func makeSUT() -> (
            viewController: ProfileViewController,
            presenter: ProfilePresenterSpy
        ) {
            let viewController = ProfileViewController()
            let presenter = ProfilePresenterSpy()
            
            viewController.presenter = presenter
            presenter.view = viewController
            
            return (viewController, presenter)
        }
        
        func testViewControllerCallsViewDidLoad() {
            // Given
            let (viewController, presenter) = makeSUT()
            
            // When
            _ = viewController.view
            
            // Then
            XCTAssertTrue(presenter.viewDidLoadCalled)
        }

        func testPresenterAssignViewCorrectly() {
            // Given
            let viewControllerSpy = ProfileViewControllerSpy()
            let presenter = ProfileViewControllerPresenter()
            
            // When
            viewControllerSpy.presenter = presenter
            presenter.view = viewControllerSpy
            
            // Then
            XCTAssertNotNil(presenter.view)
        }
}
