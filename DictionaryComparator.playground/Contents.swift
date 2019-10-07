import Foundation
import XCTest

public class DictionaryComparator {
    
    private let softAssert: SoftAssert
    private var softAssertCreated = false
    
    init(withAssert assert: SoftAssert){
        self.softAssert = assert
    }
    
    convenience init() {
        self.init(withAssert: SoftAssert())
        softAssertCreated = true
    }
    
    func compare(lhs: [String: AnyObject], rhs: [String: AnyObject],
                 excludeKeys: [String] = [], considerKeys: [String] = []) {
        
        if lhs.count < 1 && rhs.count < 1 {
            print("Cannot compare empty dictionaries")
            return
        }
        
        if lhs.count < 1 || rhs.count < 1 {
            softAssert.assert(false, "One of provided dictionaries is empty \n lhs: \(lhs) \n rhs: \(rhs) \n")
            return
        }
        
        if considerKeys.count > 1 {
            var unVerifiedRhsDict = rhs
            
            for (lhsKey, lhsVal) in lhs {
                
                if let rhsVal = rhs[lhsKey] {
                    
                    if lhsVal is [String: AnyObject] && rhsVal is [String: AnyObject] {
                        compare(lhs: lhsVal as? [String: AnyObject] ?? [:], rhs: rhsVal as? [String: AnyObject] ?? [:],
                                excludeKeys: excludeKeys, considerKeys: considerKeys)
                    }
                    
                    if !considerKeys.contains(lhsKey) {
                        unVerifiedRhsDict[lhsKey] = nil
                        continue
                    }
                    
                    verifyData(lhsKey: lhsKey, lhsVal: lhsVal, rhsKey: lhsKey, rhsVal: rhsVal, softAssert: softAssert)
                    unVerifiedRhsDict[lhsKey] = nil
                    
                } else if !considerKeys.contains(lhsKey) {
                    unVerifiedRhsDict[lhsKey] = nil
                } else {
                    softAssert.assert(false, "lhs key \(lhsKey) is missing in rhs: \n")
                }
                
            }
            
            if unVerifiedRhsDict.count > 1 {
                softAssert.assert(false, "More rhs keys exists compared to lhs. More rhs keys: \(unVerifiedRhsDict.keys) \n")
            }
            
        } else if excludeKeys.count > 1 {
            
            var unVerifiedRhsDict = rhs
            
            for (lhsKey, lhsVal) in lhs {
                
                if excludeKeys.contains(lhsKey) {
                    unVerifiedRhsDict[lhsKey] = nil
                    continue
                }
                
                if let rhsVal = rhs[lhsKey] {
                    
                    
                    if lhsVal is [String: AnyObject] && rhsVal is [String: AnyObject] {
                        compare(lhs: lhsVal as? [String: AnyObject] ?? [:], rhs: rhsVal as? [String: AnyObject] ?? [:],
                                excludeKeys: excludeKeys, considerKeys: considerKeys)
                    }
                    
                    verifyData(lhsKey: lhsKey, lhsVal: lhsVal, rhsKey: lhsKey, rhsVal: rhsVal, softAssert: softAssert)
                    unVerifiedRhsDict[lhsKey] = nil
                    
                } else {
                    softAssert.assert(false, "lhs key \(lhsKey) is missing in rhs: \n")
                }
                
            }
            
            if unVerifiedRhsDict.count > 1 {
                softAssert.assert(false, "More rhs keys exists compared to lhs. More rhs keys: \(unVerifiedRhsDict.keys) \n")
            }
            
        } else {
            
            if lhs.count != rhs.count {
                softAssert.assert(false, "Lhs key count mismatch with rhs key count \n lhs: \(lhs) \n rhs: \(rhs) \n")
                return
            }
            
            softAssert.assert(lhs == rhs, "Entire lhs did not match entire rhs. \n lhs: \(lhs) \n rhs: \(rhs) \n")
        }
        
        if softAssertCreated {
            softAssert.assertAll()
        }
        
    }
    
    private func verifyData(lhsKey: String, lhsVal: AnyObject,
                            rhsKey: String, rhsVal: AnyObject,
                            softAssert: SoftAssert) {
        
        if lhsVal is [String] && rhsVal is [String] {
            let lhsValue = lhsVal as! [String]
            let rhsValue = rhsVal as! [String]
            let lhsArr = lhsValue.sorted(by: { $0 < $1 })
            let rhsArr = rhsValue.sorted(by: { $0 < $1 })
            
            softAssert.assertEquals(lhsArr, rhsArr, "String Array object mismatched \n lhs: \(lhsArr) \n rhs: \(rhsArr) \n")
        }
        
        if lhsVal is Bool && rhsVal is Bool {
            softAssert.assertEquals(lhsVal as? Bool, rhsVal as? Bool,
                                    "Int value mismatched \n lhs: \(lhsKey):\(lhsVal) \n rhs: \(rhsKey):\(rhsVal) \n")
        } else if lhsVal is String && rhsVal is String {
            softAssert.assertEquals(lhsVal as? String, rhsVal as? String,
                                    "String value mismatched \n lhs: \(lhsKey):\(lhsVal) \n rhs: \(rhsKey):\(rhsVal) \n")
        } else if lhsVal is Int && rhsVal is Int {
            softAssert.assertEquals(lhsVal as? Int, rhsVal as? Int,
                                    "Int value mismatched \n lhs: \(lhsKey):\(lhsVal) \n rhs: \(rhsKey):\(rhsVal) \n")
        } else if lhsVal is Double && rhsVal is Double {
            softAssert.assertEquals(lhsVal as? Double, rhsVal as? Double,
                                    "Double value mismatched \n lhs: \(lhsKey):\(lhsVal) \n rhs: \(rhsKey):\(rhsVal) \n")
        } else if lhsVal is Float && rhsVal is Float {
            softAssert.assertEquals(lhsVal as? Float, rhsVal as? Float,
                                    "Float value mismatched \n lhs: \(lhsKey):\(lhsVal) \n rhs: \(rhsKey):\(rhsVal) \n")
        }
    }
    
}

private func == (lhs: [String: AnyObject], rhs: [String: AnyObject]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}


class DictionaryComparatorTest: XCTestCase {
    
    func test_compare_simple_dictionaries() {
        let lhs = ["firstKey": "firstVal"] as [String: AnyObject]
        let rhs = ["firstKey": "firstVal"] as [String: AnyObject]
        let comparator = DictionaryComparator()
        
        comparator.compare(lhs: lhs, rhs: rhs)
    }
    
    func test_compare_multi_level_dictionaries() {
        let firstVal = ["insideKey1" : "insideVal1",
                        "insideKey2": 2] as [String: AnyObject]
        let secondVal = ["secondValKey1": 4.5 as AnyObject,
                         "secondValKey2": firstVal] as [String: AnyObject]
        
        let lhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        let rhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        
        let comparator = DictionaryComparator()
        
        comparator.compare(lhs: lhs, rhs: rhs)
    }
    
    func test_compare_with_specified_keys_from_multi_level_dictionaries() {
        
        let firstVal = ["insideKey1" : "insideVal1",
                        "insideKey2": 2] as [String: AnyObject]
        let secondVal = ["secondValKey1": 4.5 as AnyObject,
                         "secondValKey2": firstVal] as [String: AnyObject]
        
        let lhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        let rhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        
        let comparator = DictionaryComparator()
        
        comparator.compare(lhs: lhs, rhs: rhs, considerKeys: ["insideKey1", "secondKey2"])
    }
    
    func test_compare_with_exclude_keys_from_multi_level_dictionaries() {
        
        let firstVal = ["insideKey1" : "insideVal1",
                        "insideKey2": 2] as [String: AnyObject]
        let secondVal = ["secondValKey1": 4.5 as AnyObject,
                         "secondValKey2": firstVal] as [String: AnyObject]
        
        let lhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        let rhs = ["firstKey": "firstVal",
                   "secondKey": secondVal] as [String: AnyObject]
        
        let comparator = DictionaryComparator()
        
        comparator.compare(lhs: lhs, rhs: rhs, excludeKeys: ["insideKey1", "secondKey2"])
    }
    
}

DictionaryComparatorTest.defaultTestSuite.run()




