import Foundation

typealias QueryParametersType = [URLQueryItem]

extension Restler {
    public class RequestBuilder: RestlerRequestBuilderType {
        private let baseURL: URL
        private let networking: NetworkingType
        private let encoder: RestlerJSONEncoderType
        private let decoder: RestlerJSONDecoderType
        private let queryEncoder: RestlerQueryEncoderType
        private let dispatchQueueManager: DispatchQueueManagerType
        private let errorParser: RestlerErrorParserType
        private let method: HTTPMethod
        private let endpoint: RestlerEndpointable
        
        private var header: Restler.Header
        private var query: QueryParametersType?
        private var body: Data?
        private var errors: [Error] = []
        
        // MARK: - Initialization
        internal init(
            baseURL: URL,
            networking: NetworkingType,
            encoder: RestlerJSONEncoderType,
            decoder: RestlerJSONDecoderType,
            queryEncoder: RestlerQueryEncoderType,
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
            self.dispatchQueueManager = dispatchQueueManager
            self.errorParser = errorParser
            self.method = method
            self.endpoint = endpoint
            self.header = header
        }
        
        // MARK: - Public
        public func query<E>(_ object: E) -> Self where E: RestlerQueryEncodable {
            guard self.method.isQueryAvailable else { return self }
            do {
                self.query = try self.queryEncoder.encode(object)
            } catch {
                self.errors.append(Error.common(type: .invalidParameters, base: error))
            }
            return self
        }
        
        public func body<E>(_ object: E) -> Self where E: Encodable {
            guard self.method.isBodyAvailable else { return self }
            do {
                self.body = try self.encoder.encode(object)
            } catch {
                self.errors.append(Error.common(type: .invalidParameters, base: error))
            }
            return self
        }
        
        public func setInHeader(_ value: String?, forKey key: Restler.Header.Key) -> Self {
            self.header[key] = value
            return self
        }
        
        public func failureDecode<T>(_ type: T.Type) -> Self where T: RestlerErrorDecodable {
            self.errorParser.decode(type)
            return self
        }
        
        public func decode<T>(_ type: T?.Type) -> Request<T?> where T: Decodable {
            return OptionalDecodableRequest<T>(
                url: self.url(for: self.endpoint),
                networking: self.networking,
                encoder: self.encoder,
                decoder: self.decoder,
                dispatchQueueManager: self.dispatchQueueManager,
                method: self.buildMethod(),
                errors: self.errors,
                errorParser: self.errorParser,
                header: self.header)
        }
        
        public func decode<T>(_ type: T.Type) -> Request<T> where T: Decodable {
            return DecodableRequest<T>(
                url: self.url(for: self.endpoint),
                networking: self.networking,
                encoder: self.encoder,
                decoder: self.decoder,
                dispatchQueueManager: self.dispatchQueueManager,
                method: self.buildMethod(),
                errors: self.errors,
                errorParser: self.errorParser,
                header: self.header)
        }
        
        public func decode(_ type: Void.Type) -> Request<Void> {
            return VoidRequest(
                url: self.url(for: self.endpoint),
                networking: self.networking,
                encoder: self.encoder,
                decoder: self.decoder,
                dispatchQueueManager: self.dispatchQueueManager,
                method: self.buildMethod(),
                errors: self.errors,
                errorParser: self.errorParser,
                header: self.header)
        }
    }
}

// MARK: - Private
extension Restler.RequestBuilder {
    private func url(for endpoint: RestlerEndpointable) -> URL {
        return self.baseURL.appendingPathComponent(endpoint.stringValue)
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
        }
    }
}