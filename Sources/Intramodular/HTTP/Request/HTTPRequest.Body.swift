//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension HTTPRequest {
    public struct Body: Codable, Hashable {
        public enum Content: Codable, Hashable {
            case data(Data)
            case inputStream(InputStream)
            
            public var dataValue: Data? {
                if case let .data(data) = self {
                    return data
                }
                
                return nil
            }
            
            public init(from decoder: Decoder) throws {
                self = .data(try decoder.singleValueContainer().decode(Data.self))
            }
            
            public func encode(to encoder: Encoder) throws {
                switch self {
                    case .data(let data):
                        try data.encode(to: encoder)
                    case .inputStream(let stream):
                        throw EncodingError.invalidValue(stream, EncodingError.Context(codingPath: [], debugDescription: "Cannot encode an InputStream"))
                }
            }
        }
        
        public let header: [HTTPHeaderField]
        public let content: Content
    }
}

// MARK: - Helpers -

extension HTTPRequest {
    public func jsonQuery<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        TODO.whole(.fix)
        
        let encoder = JSONEncoder()
        
        dateEncodingStrategy.map(into: &encoder.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &encoder.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &encoder.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &encoder.nonConformingFloatEncodingStrategy)
        
        let queryItems = try JSONDecoder()
            .decode([String: AnyCodable].self, from: try encoder.encode(value))
            .map {
                URLQueryItem(
                    name: $0.key,
                    value: try JSONEncoder().encode($0.value).toString()
                )
            }
        
        return query(queryItems)
    }
        
    public func jsonBody<T: Encodable>(
        _ value: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) throws -> Self {
        let encoder = JSONEncoder()
        
        dateEncodingStrategy.map(into: &encoder.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &encoder.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &encoder.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &encoder.nonConformingFloatEncodingStrategy)
        
        return body(try encoder.encode(value))
    }
    
    public func jsonBody(_ value: [String: Any?]) throws -> Self {
        body(
            try JSONSerialization.data(
                withJSONObject: value.compactMapValues({ $0 }),
                options: [.fragmentsAllowed, .sortedKeys]
            )
        )
    }
}
