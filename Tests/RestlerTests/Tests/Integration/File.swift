import XCTest
@testable import Restler

class QueryEncoderIntegrationTests: XCTestCase {}

extension QueryEncoderIntegrationTests {
    func testEncoding_stringDictionary() throws {
        //Arrange
        let sut = Restler.QueryEncoder()
        //Act
        let result = try sut.encode(["value": "name"])
        //Assert
        XCTAssertEqual(result, [URLQueryItem(name: "value", value: "name")])
    }
    
    func testEncoding_intDictionary() throws {
        //Arrange
        let sut = Restler.QueryEncoder()
        //Act
        let result = try sut.encode(["value": 123])
        //Assert
        XCTAssertEqual(result, [URLQueryItem(name: "value", value: "123")])
    }
    
    func testEncoding_boolDictionary() throws {
        //Arrange
        let sut = Restler.QueryEncoder()
        //Act
        let result = try sut.encode(["value": true])
        //Assert
        XCTAssertEqual(result, [URLQueryItem(name: "value", value: "true")])
    }
    
    func testEncoding_intArrayDictionary() throws {
        //Arrange
        let sut = Restler.QueryEncoder()
        let object = IntArrayObject(id: 1, intArray: [1, 5, 2])
        let expectedResult = [
            URLQueryItem(name: "id", value: "1"),
            URLQueryItem(name: "intArray[]", value: "1"),
            URLQueryItem(name: "intArray[]", value: "5"),
            URLQueryItem(name: "intArray[]", value: "2"),
        ]
        //Act
        let result = try sut.encode(object)
        //Assert
        XCTAssertEqual(result, expectedResult)
    }
}

private struct IntArrayObject: Codable, RestlerQueryEncodable {
    let id: Int
    let intArray: [Int]
    
    func encodeToQuery(using encoder: RestlerQueryEncoderType) throws {
        let container = encoder.container(using: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.intArray, forKey: .intArray)
    }
}
