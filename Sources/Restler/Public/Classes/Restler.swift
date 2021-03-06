import Foundation

/// Class for making requests to the API
open class Restler: RestlerType {
    
    // MARK: - Internal Static
    internal static func internalError(file: StaticString = #file, line: UInt = #line) -> Restler.Error {
        return Restler.Error.common(
            type: .internalFrameworkError,
            base: NSError(
                domain: "Restler",
                code: 0,
                userInfo: [
                    "file": #file,
                    "line": #line
            ]))
    }
    
    // MARK: - Properties
    
    open var encoder: RestlerJSONEncoderType
    
    open var decoder: RestlerJSONDecoderType
    
    open var errorParser: RestlerErrorParserType
    
    open var header: Restler.Header = .init()
    
    private let baseURL: URL
    private let networking: NetworkingType
    private let dispatchQueueManager: DispatchQueueManagerType
    
    private var queryEncoder: QueryEncoder { .init(jsonEncoder: self.encoder) }
    private var multipartEncoder: MultipartEncoder { .init() }
    // MARK: - Initialization
    
    /// Default initializer.
    ///
    /// - Parameters:
    ///   - baseURL: Base for endpoints calls.
    ///   - encoder: Encoder used for encoding requests' body.
    ///   - decoder: Decoder used for decoding response's data to expected object.
    ///
    public convenience init(
        baseURL: URL,
        encoder: RestlerJSONEncoderType = JSONEncoder(),
        decoder: RestlerJSONDecoderType = JSONDecoder()
    ) {
        self.init(
            baseURL: baseURL,
            networking: Networking(),
            dispatchQueueManager: DispatchQueueManager(),
            encoder: encoder,
            decoder: decoder,
            errorParser: Restler.ErrorParser())
    }
    
    internal init(
        baseURL: URL,
        networking: NetworkingType,
        dispatchQueueManager: DispatchQueueManagerType,
        encoder: RestlerJSONEncoderType,
        decoder: RestlerJSONDecoderType,
        errorParser: RestlerErrorParserType
    ) {
        self.baseURL = baseURL
        self.networking = networking
        self.dispatchQueueManager = dispatchQueueManager
        self.encoder = encoder
        self.decoder = decoder
        self.errorParser = errorParser
    }
    
    // MARK: - Open
    
    open func get(_ endpoint: RestlerEndpointable) -> RestlerGetRequestBuilderType {
        return self.requestBuilder(for: .get(query: []), to: endpoint)
    }
    
    open func post(_ endpoint: RestlerEndpointable) -> RestlerPostRequestBuilderType {
        return self.requestBuilder(for: .post(content: nil), to: endpoint)
    }
    
    open func put(_ endpoint: RestlerEndpointable) -> RestlerPutRequestBuilderType {
        return self.requestBuilder(for: .put(content: nil), to: endpoint)
    }
    
    open func patch(_ endpoint: RestlerEndpointable) -> RestlerPatchRequestBuilderType {
        return self.requestBuilder(for: .patch(content: nil), to: endpoint)
    }
    
    open func delete(_ endpoint: RestlerEndpointable) -> RestlerDeleteRequestBuilderType {
        return self.requestBuilder(for: .delete, to: endpoint)
    }
    
    open func head(_ endpoint: RestlerEndpointable) -> RestlerHeadRequestBuilderType {
        return self.requestBuilder(for: .head, to: endpoint)
    }
}

// MARK: - Private
extension Restler {
    private func requestBuilder(for method: HTTPMethod, to endpoint: RestlerEndpointable) -> RequestBuilder {
        return RequestBuilder(
            dependencies: .init(
                url: self.url(for: endpoint),
                networking: self.networking,
                encoder: self.encoder,
                decoder: self.decoder,
                queryEncoder: self.queryEncoder,
                multipartEncoder: self.multipartEncoder,
                dispatchQueueManager: self.dispatchQueueManager,
                method: method),
            header: self.header,
            errorParser: self.errorParser)
    }
    
    private func url(for endpoint: RestlerEndpointable) -> URL {
        self.baseURL.appendingPathComponent(endpoint.restlerEndpointValue)
    }
}
