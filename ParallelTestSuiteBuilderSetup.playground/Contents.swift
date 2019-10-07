import XCTest
import UIKit

public extension UIDevice {
    static var isSimulator: Bool = {
        var isSimulator = false
        #if targetEnvironment(simulator)
        isSimulator = true
        #endif
        return isSimulator
    }()
}

enum TestFilter {
    static let Smoke: String = "smoke"
    static let Functional: String = "functional"
    static let Regression: String = "regression"
    static let All: String = "all"
    
    static let Feature1 = "f1"
    static let Feature2 = "f2"
    static let OldFeature = "oldFeature"
}

protocol SmokeTest {}
protocol FunctionalTest {}
protocol RegressionTest {}

protocol DeviceTest {}
protocol SimulatorTest {}

protocol iPhoneTest {}
protocol iPadTest {}

protocol NeedDevFix {}
protocol NeedQAFix {}

class BaseTestCase: XCTestCase {
    
    public static var test_filter: String?
    
    override func perform(_ run: XCTestRun) {
        let test = run.test
        let testFilter = ProcessInfo.processInfo.environment["TEST_FILTER"] ?? BaseTestCase.test_filter ?? TestFilter.Smoke
        
        if test is NeedDevFix || test is NeedQAFix {
            print("Skipping the test as it expected to be fixed \(test)")
            return
        }
        
        if test is DeviceTest && UIDevice.isSimulator {
            print("Skipping the device test as it is a simuator \(test)")
            return
        }
        
        if test is iPhoneTest && UIDevice.current.userInterfaceIdiom == .pad {
            print("Skipping the iPhone test as it is an iPad \(test)")
            return
        }
        
        if test is iPadTest && UIDevice.current.userInterfaceIdiom == .phone {
            print("Skipping the iPad test as it is an iPhone \(test)")
            return
        }
        
        if  testFilter == TestFilter.Smoke && !(test is SmokeTest) {
            print("Skipping the test as per smoke test selection param \(test)")
            return
        }
        
        // Add other test filter conditions
    }
}

class Feature1_1Test: BaseTestCase, FunctionalTest {
    func test_feature11() {
        print("Starting feature11 test")
        print("Completed feature11 test")
    }
}

class Feature1_2Test: BaseTestCase, FunctionalTest, NeedDevFix {
    
    func test_smoke_feature11() {
        print("Starting feature12 smoke test")
        print("Completed feature12 smoke test")
    }
}

class Feature1_3Test: BaseTestCase, FunctionalTest, SmokeTest, NeedDevFix {
    
    func test_feature13() {
        print("Starting feature13 smoke test")
        print("Completed feature13 smoke test")
    }
}

class Feature2_1Test: BaseTestCase, FunctionalTest, SimulatorTest {
    func test_feature21() {
        print("Starting feature2 test")
        print("Completed feature2 test")
    }
}

class Feature2_2Test: BaseTestCase, FunctionalTest, DeviceTest {
    
    func test_smoke_feature22() {
        print("Starting feature2 smoke test")
        print("Completed feature2 smoke test")
    }
}

class Feature3_1Test: BaseTestCase, FunctionalTest, iPadTest {
    func test_feature31() {
        print("Starting feature3 test")
        print("Completed feature3 test")
    }
}

class Feature3_2Test: BaseTestCase, SmokeTest, FunctionalTest, NeedQAFix {
    
    func test_need_fix_smoke_feature32() {
        print("Starting feature3 smoke test")
        print("Completed feature3 smoke test")
    }
}

class OldFeature0_1Test: BaseTestCase, RegressionTest, iPhoneTest {
    func test_old_feature11() {
        print("Starting old feature1 test")
        print("Completed old feature1 test")
    }
}

class OldFeature0_2Test: BaseTestCase, SmokeTest, RegressionTest {
    
    func test_smoke_feature22() {
        print("Starting old feature2 smoke test")
        print("Completed old feature2 smoke test")
    }
}

// This is only for this test run purpose.
//In real projects it will be provided by command line.
// Enabled for smoke run
BaseTestCase.test_filter = TestFilter.Smoke // Change this for different functionalities

Feature1_1Test.defaultTestSuite.run()
Feature1_2Test.defaultTestSuite.run()
Feature1_3Test.defaultTestSuite.run()

Feature2_1Test.defaultTestSuite.run()
Feature2_2Test.defaultTestSuite.run()

Feature3_1Test.defaultTestSuite.run()
Feature3_2Test.defaultTestSuite.run()

OldFeature0_1Test.defaultTestSuite.run()
OldFeature0_2Test.defaultTestSuite.run()




