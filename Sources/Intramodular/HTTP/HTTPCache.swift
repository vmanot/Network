//
// Copyright (c) Vatsal Manot
//

import FoundationX
import Swallow

public struct HTTPCache: CacheProtocol, Initiable {
    public typealias Key = HTTPRequest
    public typealias Value = HTTPResponse
    
    public let base = URLCache()
    
    public init() {
        
    }
    
    public func cache(_ value: Value, forKey key: Key) throws {
        try base.storeCachedResponse(.init(value), for: .init(key))
    }
    
    public func decacheValue(forKey key: Key) throws -> Value? {
        try base.cachedResponse(for: try URLRequest(key)).map(HTTPResponse.init)
    }
    
    public func removeCachedValue(forKey key: Key) throws {
        try base.removeCachedResponse(for: .init(key))
    }
    
    public func removeAllCachedValues() throws {
        base.removeAllCachedResponses()
    }
}
