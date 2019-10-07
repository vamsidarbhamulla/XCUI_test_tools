import XCTest

public class SoftAssert {
    
    private var errorMessages : [String] = []
    private let testFile : StaticString
    private let testFileLine : UInt
    
    public init(file: StaticString = #file, line: UInt = #line) {
        testFile = file
        testFileLine = line
    }
    
    public func assert(_ condition: @autoclosure() -> Bool,
                _ message: @autoclosure() -> String = "",
                assertFile: StaticString = #file,
                assertLine: UInt = #line) {
        let simpleFileName = fileName(for: assertFile)
        let errorMsg = " with message: " + message()
        
        if !condition(){
            errorMessages.append("\nAssertion failed \(errorMsg) at file: \(simpleFileName) and line: \(assertLine)\n")
        }
    }
    
    public func assertTrue(_ condition: @autoclosure() -> Bool,
                    _ message: @autoclosure() -> String = "",
                    assertFile: StaticString = #file,
                    assertLine: UInt = #line){
        assert(condition(), message(), assertFile: assertFile, assertLine: assertLine)
    }
    
    public func assertFalse(_ condition: @autoclosure() -> Bool,
                     _ message: @autoclosure() -> String = "",
                     assertFile: StaticString = #file,
                     assertLine: UInt = #line){
        assert(!condition(), message(),assertFile: assertFile, assertLine: assertLine)
    }
    
    public func assertEquals<T: Equatable>(_ arg1: @autoclosure() -> T,
                                    _ arg2: @autoclosure() -> T,
                                    _ message: @autoclosure() -> String = "",
                                    assertFile: StaticString = #file,
                                    assertLine: UInt = #line){
        assert(arg1() == arg2(), message(),assertFile: assertFile, assertLine: assertLine)
    }
    
    public func assertAll(){
        if !errorMessages.isEmpty{
            XCTFail("Failed at the following assertions \n\n \(errorMessages.joined(separator: "\n\n"))")
        }
    }
    
    private func fileName(for filePath: StaticString) -> String.SubSequence {
        let splitPath = filePath.description.split(separator: "/")
        return splitPath[splitPath.count-1]
    }
}

