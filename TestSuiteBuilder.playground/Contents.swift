import XCTest

class Feature1Test: XCTestCase {
    func test_feature1() {
        print("Starting feature1 test")
        print("Completed feature1 test")
    }
    
    func test_need_fix_smoke_feature1() {
        print("Starting feature1 smoke test")
        print("Completed feature1 smoke test")
    }
}

class Feature2Test: XCTestCase {
    func test_feature2() {
        print("Starting feature2 test")
        print("Completed feature2 test")
    }
    
    func test_smoke_feature2() {
        print("Starting feature2 smoke test")
        print("Completed feature2 smoke test")
    }
}

class Feature3Test: XCTestCase {
    func test_feature3() {
        print("Starting feature3 test")
        print("Completed feature3 test")
    }
    
    func test_need_fix_smoke_feature3() {
        print("Starting feature3 smoke test")
        print("Completed feature3 smoke test")
    }
}

class OldFeature1Test: XCTestCase {
    func test_old_feature1() {
        print("Starting old feature1 test")
        print("Completed old feature1 test")
    }
    
    func test_smoke_feature1() {
        print("Starting old feature1 smoke test")
        print("Completed old feature1 smoke test")
    }
}

class OldFeature2Test: XCTestCase {
    func test_old_feature2() {
        print("Starting old feature2 test")
        print("Completed old feature2 test")
    }
    
    func test_smoke_feature2() {
        print("Starting old feature2 smoke test")
        print("Completed old feature2 smoke test")
    }
}

fileprivate let oldFeature1Tests = [OldFeature1Test.self]

fileprivate let oldFeature2Tests = [OldFeature2Test.self]

fileprivate let feature1Tests = [Feature1Test.self]

fileprivate let feature2Tests = [Feature2Test.self, Feature3Test.self]

fileprivate let functionalTests = feature1Tests + feature2Tests

fileprivate let regressionTests = oldFeature1Tests + oldFeature2Tests

fileprivate let allTests = functionalTests + regressionTests

enum TestFilter {
    static let Smoke: String = "smoke"
    static let Functional: String = "functional"
    static let Regression: String = "regression"
    static let All: String = "all"
    
    static let Feature1 = "f1"
    static let Feature2 = "f2"
    static let OldFeature = "oldFeature"
}

class TestSuiteBuilder : XCTestCase {
    
    private static var isSmoke : Bool = false
    
    public static var test_filter: String?
    
    private class var testClassesList : [AnyClass] {
        // Extract test filter from command line or test_filter var and default to smoke value in case no value.
        let testFilter = ProcessInfo.processInfo.environment["TEST_FILTER"] ?? test_filter ?? TestFilter.Smoke
        
        switch(testFilter){
            case TestFilter.Smoke:
                isSmoke = true
                return allTests
            case TestFilter.Functional:
                return functionalTests
            case TestFilter.Feature1:
                return feature1Tests
            case TestFilter.Feature2:
                return feature2Tests
            case TestFilter.Regression:
                return regressionTests
            case TestFilter.All:
                return allTests
            default:
                return allTests
        }
        
    }
    
    override class var defaultTestSuite: XCTestSuite {
        let defaultSuite = XCTestSuite(forTestCaseClass: self)
        let tests = extractTestsFrom(testClassesList)
        
        // Add tests
        for test in tests {
            
            // if test method name contains need_fix
            if test.name.contains("need_fix"){
                continue
            }
            
            // if test method name contains smoke
            if isSmoke && !test.name.contains("smoke"){
                continue
            }
            
            defaultSuite.addTest(test)
        }
        
        return defaultSuite
    }
    
    private class func extractTestsFrom(_ testClasses : [AnyClass]) -> [XCTest] {
        var tests : [XCTest] = []
        
        for testClass in testClasses {
            let testSuite = XCTestSuite(forTestCaseClass: testClass)
            tests += testSuite.tests
        }
        
        return tests
    }
    
}

TestSuiteBuilder.test_filter = "f2"
TestSuiteBuilder.defaultTestSuite.run()

