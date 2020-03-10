import Foundation

/// A request builder. Builds a request from the given data.
public protocol RestlerRequestBuilderType: class {
    
    /// Query encoded parameters. Works only with GET request.
    ///
    /// If error while encoding occurs, it's returned in the completion of the request inside the `Restler.Error.multiple`.
    ///
    /// - Parameters:
    ///   - object: An encodable object which is parsable to the `[String: String?]` type.
    ///
    /// - Returns: `self` for chaining.
    ///
    func query<E>(_ object: E) -> Self where E: Encodable
    
    /// Sets body of the request. Works only with POST and PUT request.
    ///
    /// If error while encoding occurs, it's returned in the completion of the request inside the `Restler.Error.multiple`.
    ///
    /// - Parameters:
    ///   - object: An encodable object.
    ///
    /// - Returns: `self` for chaining.
    ///
    func body<E>(_ object: E) -> Self where E: Encodable
    
    
    /// Sets custom value for the header in the single request.
    ///
    /// Use this if you want to send a specific value in the header of a single request.
    /// This value will override existing one in the header or will be added if header doesn't conint the key yet.
    ///
    /// - Note:
    ///   This function doesn't remove existing field in the header.
    ///
    /// - Parameters:
    ///   - value: A string value for the key.
    ///   - key: A key for the value.
    ///
    /// - Returns: `self` for chaining.
    ///
    func setInHeader(_ value: String, forKey key: Restler.Header.Key) -> Self
    
    
    /// Try to decode the error on failure of the data task.
    ///
    /// If the request will end with error, the given error would be decoded if init of the error doesn't return nil.
    /// Otherwise the Restler.Error.common will be returned.
    ///
    /// - Note:
    ///   If multiple errors will be decoded. The completion will return Restler.Error.multiple with all the decoded errors.
    ///
    /// - Parameters:
    ///   - type: A type for the error to be decoded. It will be added to an array of errors to decode on failed request.
    ///
    /// - Returns: `self` for chaining.
    ///
    func failureDecode<T>(_ type: T.Type) -> Self where T: RestlerErrorDecodable
    
    
    /// Builds a request with a decoding type.
    ///
    /// Optional decoding ignores the returned data if decoding of the given type failes.
    /// It returns success with nil in this case. So it is always successful if the data request was successful.
    ///
    /// - Parameters:
    ///   - type: Decodable object type to be decoded on the request completion.
    ///
    /// - Returns: Appropriate request for the given type.
    ///
    func decode<T>(_ type: T?.Type) -> Restler.Request<T?> where T: Decodable
    
    /// Builds a request with a decoding type.
    ///
    /// If decoding of the given type failes, completion will be called with `failure` containing the underlying error in the `Restler.Error.common`'s base.
    ///
    /// - Parameters:
    ///   - type: Decodable object type to be decoded on the request completion.
    ///
    /// - Returns: Appropriate request for the given type.
    ///
    func decode<T>(_ type: T.Type) -> Restler.Request<T> where T: Decodable
    
    /// Builds a request with a decoding type.
    ///
    /// Ignores any data received on the successful request.
    ///
    /// - Parameters:
    ///   - type: `Void.self`
    ///
    /// - Returns: Appropriate request for the given type.
    ///
    func decode(_ type: Void.Type) -> Restler.Request<Void>
}