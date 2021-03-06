import XCTest
import Restler

class RestlerRequestBuilderMock {
    
    // MARK: - RestlerBasicRequestBuilderType
    private(set) var setInHeaderParams: [SetInHeaderParams] = []
    struct SetInHeaderParams {
        let value: String?
        let key: Restler.Header.Key
    }
    
    private(set) var failureDecodeParams: [FailureDecodeParams] = []
    struct FailureDecodeParams {
        let type: RestlerErrorDecodable.Type
    }
    
    private(set) var customRequestModificationParams: [CustomRequestModificationParams] = []
    struct CustomRequestModificationParams {
        let modification: ((inout URLRequest) -> Void)?
    }
    
    // MARK: - RestlerQueryRequestBuilderType
    private(set) var queryParams: [QueryParams] = []
    struct QueryParams {
        let object: Any
    }
    
    // MARK: - RestlerBodyRequestBuilderType
    private(set) var bodyParams: [BodyParams] = []
    struct BodyParams {
        let object: Any
    }
    
    // MARK: - RestlerMultipartRequestBuilderType
    private(set) var multipartParams: [MultipartParams] = []
    struct MultipartParams {
        let object: Any
        let boundary: String?
    }
    
    // MARK: - RestlerDecodableResponseRequestBuilderType
    private(set) var decodeReturnedMocks: [Any] = []
    private(set) var decodeParams: [DecodeParams] = []
    struct DecodeParams {
        let type: Any
    }
    
    // MARK: - Internal
    func callCompletion<T>(type: T.Type, result: Result<T, Error>) throws {
        guard let request = self.decodeReturnedMocks.last as? RestlerRequestMock<T> else { throw "Decode hasn't return value with a specified type." }
        var isCalledAnything = false
        switch result {
        case let .success(object):
            guard let successHandler = request.onSuccessParams.last?.handler else { break }
            successHandler(object)
            isCalledAnything = true
        case let .failure(error):
            guard let failureHandler = request.onFailureParams.last?.handler else { break }
            failureHandler(error)
            isCalledAnything = true
        }
        if let completionHandler = request.onCompletionParams.last?.handler {
            completionHandler(result)
            isCalledAnything = true
        }
        guard isCalledAnything else { throw "None handler has been called." }
    }
}

// MARK: - RestlerBasicRequestBuilderType
extension RestlerRequestBuilderMock: RestlerBasicRequestBuilderType {
    func setInHeader(_ value: String?, forKey key: Restler.Header.Key) -> Self {
        self.setInHeaderParams.append(SetInHeaderParams(value: value, key: key))
        return self
    }
    
    func failureDecode<T>(_ type: T.Type) -> Self where T: RestlerErrorDecodable {
        self.failureDecodeParams.append(FailureDecodeParams(type: type))
        return self
    }
    
    func customRequestModification(_ modification: ((inout URLRequest) -> Void)?) -> Self {
        self.customRequestModificationParams.append(CustomRequestModificationParams(modification: modification))
        return self
    }
    
    func decode(_ type: Void.Type) -> Restler.Request<Void> {
        self.decodeParams.append(DecodeParams(type: type))
        let mock = RestlerRequestMock<Void>()
        self.decodeReturnedMocks.append(mock)
        return mock
    }
}

// MARK: - RestlerQueryRequestBuilderType
extension RestlerRequestBuilderMock: RestlerQueryRequestBuilderType {
    func query<E>(_ object: E) -> Self where E: RestlerQueryEncodable {
        self.queryParams.append(QueryParams(object: object))
        return self
    }
}

// MARK: - RestlerBodyRequestBuilderType
extension RestlerRequestBuilderMock: RestlerBodyRequestBuilderType {
    func body<E>(_ object: E) -> Self where E: Encodable {
        self.bodyParams.append(BodyParams(object: object))
        return self
    }
}

// MARK: - RestlerMultipartRequestBuilderType
extension RestlerRequestBuilderMock: RestlerMultipartRequestBuilderType {
    func multipart<E>(_ object: E, boundary: String?) -> Self where E: RestlerMultipartEncodable {
        self.multipartParams.append(MultipartParams(object: object, boundary: boundary))
        return self
    }
}

// MARK: - RestlerDecodableResponseRequestBuilderType
extension RestlerRequestBuilderMock: RestlerDecodableResponseRequestBuilderType {
    func decode<T>(_ type: T?.Type) -> Restler.Request<T?> where T: Decodable {
        self.decodeParams.append(DecodeParams(type: type))
        let mock = RestlerRequestMock<T?>()
        self.decodeReturnedMocks.append(mock)
        return mock
    }
    
    func decode<T>(_ type: T.Type) -> Restler.Request<T> where T: Decodable {
        self.decodeParams.append(DecodeParams(type: type))
        let mock = RestlerRequestMock<T>()
        self.decodeReturnedMocks.append(mock)
        return mock
    }
}
