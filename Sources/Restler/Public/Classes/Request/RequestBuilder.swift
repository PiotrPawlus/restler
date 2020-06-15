import Foundation

typealias QueryParametersType = [URLQueryItem]

extension Restler {
    public class RequestBuilder {
        private let baseURL: URL
        private let networking: NetworkingType
        private let encoder: RestlerJSONEncoderType
        private let decoder: RestlerJSONDecoderType
        private let queryEncoder: RestlerQueryEncoderType
        private let multipartEncoder: RestlerMultipartEncoderType
        private let dispatchQueueManager: DispatchQueueManagerType
        private let errorParser: RestlerErrorParserType
        private let method: HTTPMethod
        private let endpoint: RestlerEndpointable
        
        private var header: Restler.Header
        private var query: QueryParametersType?
        private var body: Data?
        private var errors: [Error] = []
        private var customRequestModification: ((inout URLRequest) -> Void)?
        
        // MARK: - Initialization
        internal init(
            baseURL: URL,
            networking: NetworkingType,
            encoder: RestlerJSONEncoderType,
            decoder: RestlerJSONDecoderType,
            queryEncoder: RestlerQueryEncoderType,
            multipartEncoder: RestlerMultipartEncoderType,
            dispatchQueueManager: DispatchQueueManagerType,
            errorParser: RestlerErrorParserType,
            method: HTTPMethod,
            endpoint: RestlerEndpointable,
            header: Restler.Header
        ) {
            self.baseURL = baseURL
            self.networking = networking
            self.encoder = encoder
            self.decoder = decoder
            self.queryEncoder = queryEncoder
            self.multipartEncoder = multipartEncoder
            self.dispatchQueueManager = dispatchQueueManager
            self.errorParser = errorParser
            self.method = method
            self.endpoint = endpoint
            self.header = header
        }
    }
}

// MARK: - RestlerBasicRequestBuilderType
extension Restler.RequestBuilder: RestlerBasicRequestBuilderType {
    public func setInHeader(_ value: String?, forKey key: Restler.Header.Key) -> Self {
        self.header[key] = value
        return self
    }
    
    public func failureDecode<T>(_ type: T.Type) -> Self where T: RestlerErrorDecodable {
        self.errorParser.decode(type)
        return self
    }
    
    public func customRequestModification(_ modification: ((inout URLRequest) -> Void)?) -> Self {
        self.customRequestModification = modification
        return self
    }
    
    public func decode(_ type: Void.Type) -> Restler.Request<Void> {
        return Restler.VoidRequest(
            url: self.url(for: self.endpoint),
            networking: self.networking,
            encoder: self.encoder,
            decoder: self.decoder,
            dispatchQueueManager: self.dispatchQueueManager,
            method: self.buildMethod(),
            errors: self.errors,
            errorParser: self.errorParser,
            header: self.header,
            customRequestModification: self.customRequestModification)
    }
}

// MARK: - RestlerQueryRequestBuilderType
extension Restler.RequestBuilder: RestlerQueryRequestBuilderType {
    public func query<E>(_ object: E) -> Self where E: RestlerQueryEncodable {
        guard self.method.isQueryAvailable else { return self }
        do {
            self.query = try self.queryEncoder.encode(object)
            self.header[.contentType] = "application/x-www-form-urlencoded"
        } catch {
            self.errors.append(Restler.Error.common(type: .invalidParameters, base: error))
        }
        return self
    }
}

// MARK: - RestlerBodyRequestBuilderType
extension Restler.RequestBuilder: RestlerBodyRequestBuilderType {
    public func body<E>(_ object: E) -> Self where E: Encodable {
        guard self.method.isBodyAvailable else { return self }
        do {
            self.body = try self.encoder.encode(object)
            self.header[.contentType] = "application/json"
        } catch {
            self.errors.append(Restler.Error.common(type: .invalidParameters, base: error))
        }
        return self
    }
}

// MARK: - RestlerMultipartRequestBuilderType
extension Restler.RequestBuilder: RestlerMultipartRequestBuilderType {
    public func multipart<E>(_ object: E, boundary: String? = nil) -> Self where E: RestlerMultipartEncodable {
        guard self.method.isMultipartAvailable else { return self }
        do {
            let unwrappedBoundary = boundary ?? "Boundary--\(UUID().uuidString)"
            self.body = try self.multipartEncoder.encode(object, boundary: unwrappedBoundary)
            self.header[.contentType] = "multipart/form-data; charset=utf-8; boundary=\(unwrappedBoundary)"
        } catch {
            self.errors.append(Restler.Error.common(type: .invalidParameters, base: error))
        }
        return self
    }
}

// MARK: - RestlerDecodableResponseRequestBuilderType
extension Restler.RequestBuilder: RestlerDecodableResponseRequestBuilderType {
    public func decode<T>(_ type: T?.Type) -> Restler.Request<T?> where T: Decodable {
        return Restler.OptionalDecodableRequest<T>(
            url: self.url(for: self.endpoint),
            networking: self.networking,
            encoder: self.encoder,
            decoder: self.decoder,
            dispatchQueueManager: self.dispatchQueueManager,
            method: self.buildMethod(),
            errors: self.errors,
            errorParser: self.errorParser,
            header: self.header,
            customRequestModification: self.customRequestModification)
    }
    
    public func decode<T>(_ type: T.Type) -> Restler.Request<T> where T: Decodable {
        return Restler.DecodableRequest<T>(
            url: self.url(for: self.endpoint),
            networking: self.networking,
            encoder: self.encoder,
            decoder: self.decoder,
            dispatchQueueManager: self.dispatchQueueManager,
            method: self.buildMethod(),
            errors: self.errors,
            errorParser: self.errorParser,
            header: self.header,
            customRequestModification: self.customRequestModification)
    }
}

// MARK: - Private
extension Restler.RequestBuilder {
    private func url(for endpoint: RestlerEndpointable) -> URL {
        return self.baseURL.appendingPathComponent(endpoint.restlerEndpointValue)
    }
    
    private func buildMethod() -> HTTPMethod {
        switch self.method {
        case .get:
            return .get(query: self.query ?? [])
        case .post:
            return .post(content: self.body)
        case .put:
            return .put(content: self.body)
        case .patch:
            return .patch(content: self.body)
        case .delete:
            return .delete
        case .head:
            return .head
        }
    }
}
