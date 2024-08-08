import XCTest
@testable import eas_sdk_swift

final class SchemaEncoderTests: XCTestCase {
    func testEncodeDataBoolFalse() throws {
        let schemaEncoder = SchemaEncoder(schema: "bool vote")
        let encodedData = try! schemaEncoder.encodeData(params: [
            SchemaItem(name: "vote", type: "false", value: .boolean)
        ])
        XCTAssertEqual("0x0000000000000000000000000000000000000000000000000000000000000000", encodedData)
    }
    func testEncodeDataBoolTrue() throws {
        let schemaEncoder = SchemaEncoder(schema: "bool vote")
        let encodedData = try! schemaEncoder.encodeData(params: [
            SchemaItem(name: "vote", type: "true", value: .boolean)
        ])
        XCTAssertEqual("0x0000000000000000000000000000000000000000000000000000000000000001", encodedData)
    }
    
    func testEncodeDataString() throws {
        let schemaEncoder = SchemaEncoder(schema: "string vote")
        let encodedData = try! schemaEncoder.encodeData(params: [
            SchemaItem(name: "vote", type: "false", value: .string)
        ])
        XCTAssertEqual("0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000566616c7365000000000000000000000000000000000000000000000000000000", encodedData)
    }
}
