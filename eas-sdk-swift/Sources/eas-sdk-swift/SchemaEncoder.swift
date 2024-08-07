//
//  SchemaEncoder.swift
//
//
//  Created by mgarciate on 8/8/24.
//

public enum SchemaValue: StringLiteralType {
    case string, boolean, number
}

public protocol SchemaItemProtocol {
    var name: String { get }
    var type: String { get }
    var value: SchemaValue { get }
}

public struct SchemaItem: SchemaItemProtocol {
    public let name: String
    public let type: String
    public let value: SchemaValue
}

public struct SchemaItemWithSignature: SchemaItemProtocol {
    public let name: String
    public let type: String
    public let value: SchemaValue
    public let signature: String
}

enum EncodeDataError: Error {
    case invalidNumberOrValues
    case incompatibleParamType(String)
    case incompatibleParamName(String)
}

public class SchemaEncoder {
    public let schema: [SchemaItemWithSignature]
    
    public init(schema: String) {
        self.schema = []
    }
    
    public func encodeData(params: [SchemaItem]) throws -> String {
        if params.count != self.schema.count {
            throw EncodeDataError.invalidNumberOrValues
        }
        
        var data: [Any] = []
    }
}
