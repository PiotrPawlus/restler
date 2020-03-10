import Foundation

/// Interface of the main functional class of the Restler framework.
public protocol RestlerType: class {
    
    /// Encoder used for encoding requests' body.
    var encoder: RestlerJSONEncoderType { get set }
    
    /// Decoder used for decoding response's data to expected object.
    var decoder: RestlerJSONDecoderType { get set }
    
    /// Error parser for failed requests. Setting its decoded errors makes trying to decode them globally.
    var errorParser: RestlerErrorParserType { get set }
    
    /// Global header sent in requests.
    var header: Restler.Header { get set }
    
    
    /// Creates GET request builder.
    ///
    /// - Parameter endpoint: Endpoint for the request
    ///
    /// - Returns: Restler.RequestBuilder for building the request in the functional way.
    ///
    func get(_ endpoint: RestlerEndpointable) -> RestlerRequestBuilderType
    
    /// Creates POST request builder.
    ///
    /// - Parameter endpoint: Endpoint for the request
    ///
    /// - Returns: Restler.RequestBuilder for building the request in the functional way.
    ///
    func post(_ endpoint: RestlerEndpointable) -> RestlerRequestBuilderType
    
    /// Creates PUT request builder.
    ///
    /// - Parameter endpoint: Endpoint for the request
    ///
    /// - Returns: Restler.RequestBuilder for building the request in the functional way.
    ///
    func put(_ endpoint: RestlerEndpointable) -> RestlerRequestBuilderType
    
    /// Creates DELETE request builder.
    ///
    /// - Parameter endpoint: Endpoint for the request
    ///
    /// - Returns: Restler.RequestBuilder for building the request in the functional way.
    ///
    func delete(_ endpoint: RestlerEndpointable) -> RestlerRequestBuilderType
}