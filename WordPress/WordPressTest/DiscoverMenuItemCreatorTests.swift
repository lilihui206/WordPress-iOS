import XCTest
@testable import WordPress
@testable import Gridicons

final class DiscoverMenuItemCreatorTests: XCTestCase {
    private var testContextManager: TestContextManager?
    private var topic: ReaderAbstractTopic?
    private var creator: ReaderMenuItemCreator?

    private struct TestConstants {
        static let path = "/read/sites/53424024/posts"
        static let title = "Discover"
        static let icon = Gridicon.icon(type: .mySites)
    }

    override func setUp() {
        super.setUp()
        testContextManager = TestContextManager()
        topic = NSEntityDescription.insertNewObject(forEntityName: ReaderListTopic.classNameWithoutNamespaces(), into: ContextManager.sharedInstance().mainContext) as! ReaderListTopic
        topic!.path = TestConstants.path
        topic!.title = TestConstants.title
        topic!.type = ReaderListTopic.TopicType

        creator = DiscoverMenuItemCreator()
    }

    override func tearDown() {
        ContextManager.overrideSharedInstance(nil)
        testContextManager = nil
        topic = nil
        creator = nil
        super.tearDown()
    }

    func testItemCreatorSupportsTopic() {
        let supported = creator!.supports(topic!)

        XCTAssertTrue(supported)
    }

    func testItemCreatorReturnsItemWithExpectedTitle() {
        let item = creator!.menuItem(with: topic!)

        XCTAssertEqual(item.title, TestConstants.title)
    }

    func testItemCreatorReturnsItemWithExpectedIcon() {
        let item = creator!.menuItem(with: topic!)

        XCTAssertEqual(item.icon, TestConstants.icon)
    }
}
