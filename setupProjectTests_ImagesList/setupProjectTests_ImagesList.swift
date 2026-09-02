import XCTest
@testable import setupProject

final class setupProjectTests_ImagesList: XCTestCase {
    
     func makeSUT() -> (
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
    
    func testPresenterAssignsViewCorrectly() {
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

