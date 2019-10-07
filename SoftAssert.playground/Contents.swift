import XCTest

class SoftAssert {
    
    private var errorMessages : [String] = []
    private let testFile : StaticString
    private let testFileLine : UInt
    
    init(file: StaticString = #file, line: UInt = #line) {
        testFile = file
        testFileLine = line
    }
    
    func assert(_ condition: @autoclosure() -> Bool,
                _ message: @autoclosure() -> String = "",
                assertFile: StaticString = #file,
                assertLine: UInt = #line) {
        let simpleFileName = fileName(for: assertFile)
        let errorMsg = " with message: " + message()
        
        if !condition(){
            errorMessages.append("\nAssertion failed \(errorMsg) at file: \(simpleFileName) and line: \(assertLine)\n")
        }
    }
    
    func assertTrue(_ condition: @autoclosure() -> Bool,
                    _ message: @autoclosure() -> String = "",
                    assertFile: StaticString = #file,
                    assertLine: UInt = #line){
        assert(condition(), message(), assertFile: assertFile, assertLine: assertLine)
    }
    
    func assertFalse(_ condition: @autoclosure() -> Bool,
                     _ message: @autoclosure() -> String = "",
                     assertFile: StaticString = #file,
                     assertLine: UInt = #line){
        assert(!condition(), message(),assertFile: assertFile, assertLine: assertLine)
    }
    
    func assertEquals<T: Equatable>(_ arg1: @autoclosure() -> T,
                                    _ arg2: @autoclosure() -> T,
                                    _ message: @autoclosure() -> String = "",
                                    assertFile: StaticString = #file,
                                    assertLine: UInt = #line){
        assert(arg1() == arg2(), message(),assertFile: assertFile, assertLine: assertLine)
    }
    
    func assertAll(){
        if !errorMessages.isEmpty{
            XCTFail("Failed at the following assertions \n\n \(errorMessages.joined(separator: "\n\n"))")
        }
    }
    
    private func fileName(for filePath: StaticString) -> String.SubSequence {
        let splitPath = filePath.description.split(separator: "/")
        return splitPath[splitPath.count-1]
    }
}


class SoftAssertTest: XCTestCase {
    
    
    func test_multiple_failed_asserts() {
        let assert = SoftAssert()
        assert.assert(1==2, "Number comparision failed") //Assertion failed  with message: Number comparision failed at file: SoftAssert.playground and line: 66
        assert.assertEquals(0.3,0.5, "Float comparision failed") //Assertion failed  with message: Float comparision failed at file: SoftAssert.playground and line: 67
        assert.assertTrue("ram" == "raj", "String comparision failed") //Assertion failed  with message: String comparision failed at file: SoftAssert.playground and line: 68

        assert.assertFalse(true, "Assert false failed") //Assertion failed  with message: Assert false failed at file: SoftAssert.playground and line: 69
        assert.assertAll()
    }
    
    func test_multiple_successful_asserts() {
        let assert = SoftAssert()
        assert.assert(1==1)
        assert.assertEquals(0.5,0.5)
        assert.assertTrue("ram" == "ram")
        assert.assertFalse(false)
        assert.assertAll()
    }
}

SoftAssertTest.defaultTestSuite.run()

