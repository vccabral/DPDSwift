//
//  DPDQuery.swift
//  DPDSwift
//
//Created by Sylveus, Steeven on 11/8/18.
//

import UIKit

open class DPDQuery: NSObject {
    
    public typealias QueryCompletionBlock = (_ response: [Any]?, _ error: Error?) -> Void
    
    public enum QueryCondition: Int {
        case greaterThan = 0
        case greaterThanEqualTo = 1
        case lessThan = 2
        case lessThanEqual = 3
        case notEqual = 4
        case equal = 5
        case contains = 6
        case regex = 7
        case none = 8
        case or = 9
        case and = 10
        case generic =  11
    }
    
    public enum OrderType: Int {
        case ascending = 1
        case descending = -1
    }
    
    var queryCondition: QueryCondition = .none
    var sortingOrder: OrderType = .ascending
    var limit: Int? = nil
    var skip: Int? = nil
    var queryField: String?
    var queryFieldValue: Any?
    var sortField: String?
    fileprivate var queryParam: [String: Any]? = nil
    fileprivate var callingThread: Thread? = nil
    
    open class func findObject(_ rootUrl: String, objectId: String, endPoint: String, responseDataModel: DPDObject, compblock: @escaping QueryCompletionBlock) {
        let query = DPDQuery()
        query.makeApiRequest(rootUrl, endpointValue: endPoint + "/\(objectId)", compblock: compblock)
    }
    
    public override init() {
        queryCondition = .none
        sortingOrder = .ascending
        limit = nil
        skip = nil
        queryField = nil
        queryFieldValue = nil
        sortField = nil
    }
    
    public init(queryCondition: QueryCondition = .none,
                ordertype: OrderType = .ascending,
                limit: Int? = nil,
                skip: Int? = nil,
                queryField: String? = nil,
                queryFieldValue: Any? = nil,
                sortField: String? = nil) {
        self.queryCondition = queryCondition
        self.sortingOrder = ordertype
        self.limit = limit
        self.skip = skip
        self.queryField = queryField
        self.queryFieldValue = queryFieldValue
        self.sortField = sortField
    }
    
    open func queryCondition(condition: QueryCondition) -> DPDQuery {
        self.queryCondition = condition
        return self
    }
    
    open func sortingOrder(order: OrderType) -> DPDQuery {
        self.sortingOrder = order
        return self
    }
    
    open func limit(limit: Int) -> DPDQuery {
        self.limit = limit
        return self
    }
    
    open func skip(skip: Int) -> DPDQuery {
        self.skip = skip
        return self
    }
    
    open func queryField(field: String) -> DPDQuery {
        self.queryField = field
        return self
    }
    
    open func queryFieldValue(fieldValue: Any) -> DPDQuery {
        self.queryFieldValue = fieldValue
        return self
    }
    
    open func sortField(sortField: String) -> DPDQuery {
        self.sortField = sortField
        return self
    }
    
    open func findObject(_ rootUrl: String? = nil, endPoint: String, compblock: @escaping QueryCompletionBlock) {
        
        guard let baseUrl = rootUrl ?? DPDConstants.rootUrl else {
            compblock(nil, NSError(domain: "Invalid is required", code: -1, userInfo: nil))
            return
        }
        
        processQueryInfo()
        makeApiRequest(baseUrl, endpointValue: endPoint, compblock: compblock)
    }
    
    open func findMappableObject<T: DPDObject>(_ mapper: T.Type, rootUrl: String? = nil, endPoint: String, compblock: @escaping QueryCompletionBlock) {
        
        guard let baseUrl = rootUrl ?? DPDConstants.rootUrl else {
            compblock(nil, NSError(domain: "Invalid is required", code: -1, userInfo: nil))
            return
        }
        
        processQueryInfo()
        makeApiRequestForMappableObject(mapper, rootUrl: baseUrl, endpointValue: endPoint, compblock: compblock)
    }
    
    fileprivate func makeApiRequestForMappableObject<T: DPDObject>(_ mapper: T.Type, rootUrl: String, endpointValue: String, compblock: @escaping QueryCompletionBlock) {
        
        executeRequest(rootUrl, endpointValue: endpointValue) { (response, responseHeader, error) in
            if error == nil {
                var mnObjects = [T]()
                if let responseDict = response as? [String: Any] {
                    mnObjects = DPDObject.convertToDPDObject(mapper, response: [responseDict])
                    
                } else if let responseArray = response as? [[String: Any]] {
                    mnObjects = DPDObject.convertToDPDObject(mapper, response: responseArray)
                }
                
                compblock(mnObjects, nil)
            } else {
                compblock(nil, error as NSError?)
            }
            
        }
    }
    
    fileprivate func makeApiRequest(_ rootUrl: String, endpointValue: String, compblock: @escaping QueryCompletionBlock) {
        executeRequest(rootUrl, endpointValue: endpointValue) { (response, responseHeader, error) in
            if error == nil {
                if let responseDict = response as? [String: Any] {
                    compblock([responseDict as Any], nil)
                } else if let responseArray = response as? [[String: Any]] {
                    compblock(responseArray, nil)
                } else {
                    compblock(nil, error)
                }
            } else {
                compblock(nil, error)
            }
        }
    }
    
    fileprivate func executeRequest(_ rootUrl: String,  endpointValue: String, compblock: @escaping CompletionBlock) {
        DPDRequest.requestWithURL(rootUrl, endPointURL: endpointValue, parameters: queryParam?.count ?? 0 > 0 ? queryParam : nil, method: HTTPMethod.GET, jsonString: nil) { (response, responseHeader, error) in
            
            DispatchQueue.main.async(execute: {
                compblock(response, responseHeader, error)
            })
        }
    }
    
    func processQueryInfo() {
        queryParam = [String: Any]()
        
        if queryField != nil && queryCondition != .none {
            processQuerycondition()
        } else if queryCondition == .generic {
            processQuerycondition()
        }
        
        if let _ = sortField {
            queryParam?.addDictionary(dictionary: processingSortingOrder())
        }
        
        if let _ = limit {
            queryParam?.addDictionary(dictionary: processingLimit())
        }
        
        if let _ = skip {
            queryParam?.addDictionary(dictionary: processingSkip())
        }
        
    }
    
}

extension DPDQuery {
    //Mark - Querycondition Methods
    fileprivate func processQuerycondition() {
        switch queryCondition {
        case .greaterThan:
            queryParam?.addDictionary(dictionary: processingGreaterThan())
        case .greaterThanEqualTo:
            queryParam?.addDictionary(dictionary: processingGreaterThanEqualTo())
        case .lessThan:
            queryParam?.addDictionary(dictionary: processingLessThan())
        case .lessThanEqual:
            queryParam?.addDictionary(dictionary: processingLessThanEqualTo())
        case .notEqual:
            queryParam?.addDictionary(dictionary: processingNotEqualTo())
        case .contains:
            queryParam?.addDictionary(dictionary: processingContainIn())
        case .regex:
            queryParam?.addDictionary(dictionary: processingRegex())
        case.or:
            queryParam?.addDictionary(dictionary: processingOr())
        case.and:
            queryParam?.addDictionary(dictionary: processingAnd())
        case .generic:
            queryParam?.addDictionary(dictionary: queryFieldValue as! Dictionary<String, AnyObject>)
        default:
            queryParam?.addDictionary(dictionary: processingEqualTo())
        }
    }
    
    fileprivate func processingGreaterThan() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$gt"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingGreaterThanEqualTo() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$gte"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingLessThan() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$lt"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingLessThanEqualTo() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$lte"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingNotEqualTo() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$ne"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingEqualTo() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$eq"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingContainIn() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$in"] = queryFieldValue
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingRegex() -> [String: Any] {
        var queryParam = [String: Any]()
        var valueDict = [String: Any]()
        valueDict["$regex"] = queryFieldValue
        valueDict["$options"] = "i"
        queryParam[queryField!] = valueDict
        return queryParam
    }
    
    fileprivate func processingSortingOrder() -> [String: Any] {
        var sortingParm = [String: Any]()
        var sortindDict = [String: Any]()
        sortindDict.updateValue(NSNumber(value: sortingOrder.rawValue as Int), forKey: sortField!)
        //sortindDict[sortField!] = NSNumber(integer: sortingOrder.rawValue)
        sortingParm["$sort"] = sortindDict
        return sortingParm
    }
    
    fileprivate func processingOr() -> [String: Any] {
        var valueDict = [String: Any]()
        valueDict["$or"] = queryFieldValue
        return valueDict
        
    }
    
    fileprivate func processingAnd() -> [String: Any] {
        var valueDict = [String: Any]()
        valueDict["$and"] = queryFieldValue
        return valueDict
        
    }
    
    fileprivate func processingLimit() -> [String: Any] {
        var limitParm = [String: Any]()
        limitParm["$limit"] = NSNumber(value: limit! as Int)
        
        return limitParm
    }
    
    fileprivate func processingSkip() -> [String: Any] {
        var skipParm = [String: Any]()
        skipParm["$skip"] = NSNumber(value: skip! as Int)
        return skipParm
    }
    
}

extension Dictionary {
    
    mutating func addDictionary(dictionary:Dictionary) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
}

