import XCTest
import SnapshotTesting
import SwiftUI

@testable import Tracker

final class SnapshotTests: XCTestCase {
    
    func testTrackerMainScreenSnapshot() {
        // Given
        let viewController = TrackersViewController()
        viewController.loadViewIfNeeded()
        
        // Then
        assertSnapshot(of: viewController, as: .image(on: .iPhone13))
    }
}
