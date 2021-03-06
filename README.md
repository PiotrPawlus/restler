# Restler

[![Package Build Status](https://github.com/railwaymen/restler/workflows/Package%20Actions/badge.svg)](https://github.com/railwaymen/restler/actions)
[![Example App Build Status](https://github.com/railwaymen/restler/workflows/Example%20App%20Actions/badge.svg)](https://github.com/railwaymen/restler/actions)
[![Coverage Status](https://coveralls.io/repos/github/railwaymen/restler/badge.svg?branch=master)](https://coveralls.io/github/railwaymen/restler?branch=master)

The Restler framework has been built to use features of the newest versions of Swift. Inspiration for it is Vapor library for building Server-side with Swift. What we love is functional programming, so you can build your desired request just calling some chained functions. The main goal of the framework is to provide nice interface for making API requests the easiest as possible and the fastest as possible.

## List of Content

1. [Documentation](#documentation)
2. [Instalation](#instalation)
3. [Usage](#usage)
  - [Error Parser](#error-parser)
  - [Header](#header)
  - [Restler calls](#restler-calls)
4. [Contribution](#contribution)

## Documentation

We think that README isn't a good place for complete documentation so that's why we decided to generate it to a folder inside the framework repository. Full documentation you can find in the [Documentation](Documentation/Reference) folder. If you're looking for a description of a specific protocol or class, we put here a list of the most important symbols.

### Restler

[RestlerType](Documentation/Reference/protocols/RestlerType) - it's the main protocol which should be used when it comes to mocking or using [Restler's](Documentation/Reference/classes/Restler.md) class' instance.

### Request builder

- [RestlerBasicRequestBuilderType](Documentation/Reference/protocols/RestlerBasicRequestBuilderType.md) - available for all HTTP methods.
- [RestlerQueryRequestBuilderType](Documentation/Reference/protocols/RestlerQueryRequestBuilderType.md) - available only for GET.
- [RestlerBodyRequestBuilderType](Documentation/Reference/protocols/RestlerBodyRequestBuilderType.md) - available for POST, PUT and PATCH.
- [RestlerMultipartRequestBuilderType](Documentation/Reference/protocols/RestlerMultipartRequestBuilderType.md) - available only for POST.
- [RestlerDecodableResponseRequestBuilderType](Documentation/Reference/protocols/RestlerDecodableResponseRequestBuilderType.md) - available for GET, POST, PUT, PATCH and DELETE (all without HEAD).

All these protocols are defined in one file: [RestlerRequestBuilderType](Sources/Restler/Public/Protocols/Request/RestlerRequestBuilderType.swift)

### Request

[Restler.Request](Documentation/Reference/classes/Restler.Request.md) - generic class for all request types provided by Restler.

### Errors

- [Restler.Error](Documentation/Reference/enums/Restler.Error.md) - errors returned by Restler.
- [Restler.ErrorType](Documentation/Reference/enums/Restler.ErrorType.md) - types which Restler can decode by himself. Every different type would be an `unknownError`.

### Error parser

- [RestlerErrorParserType](Documentation/Reference/protocols/RestlerErrorParserType.md) - a public protocol for the ErrorParser class.
- [RestlerErrorDecodable](Documentation/Reference/protocols/RestlerErrorDecodable.md) - a protocol to implement if an object should be decoded by the ErrorParser.

## Instalation

Nothing is easier there - you just add the framework to the **Swift Package Manager** dependecies if you use one.

Otherwise you can use **CocoaPods**. If you use one simply add to your `Podfile`:

```ruby
...
pod 'Restler'
...
```

and call in your console:

```bash
pod install
```

Import the framework to the project:

```swift
import Restler
```

and call it!

## Usage Examples

### Error parser

If you don't want to add the same error to be parsed on failure of every request, simply add the error directly to the error parser of the Restler object.

```swift
restler.errorParser.decode(ErrorToDecodeOnFailure.self)
```

If you don't want to decode it anymore, simply stop decoding it:

```swift
restler.errorParser.stopDecoding(ErrorToDecodeOnFailure.self)
```

### Header

Setting header values is very easy. Simply set it as a dictionary:

```swift
restler.header = [
  .contentType: "application/json",
  .cacheControl: "none",
  "customKey": "value"
]
restler.header[.cacheControl] = nil
```

If you're using basic authentication at "Authorization" key, simply provide username and password to header:

```swift
restler.header.setBasicAuthentication(username: "me", password: "password")
```

### Restler calls

#### GET

```swift
Restler(baseURL: myBaseURL)
  .get(Endpoint.myProfile) // 1
  .query(anEncodableQueryObject) // 2
  .failureDecode(ErrorToDecodeOnFailure.self) // 3
  .setInHeader("myNewTemporaryToken", forKey: "token") // 4
  .decode(Profile.self) // 5
  // 6

  .onSuccess({ profile in // 7
    updateProfile(with: profile)
  })
  .onCompletion({ _ in // 8
    hideLoadingIndicator()
  })
  .start() // 9
```

1. Makes GET request to the given endpoint.
2. Encodes the object and puts it in query for GET request.
3. If an error will occur, an error parser would try to decode the given type.
4. Sets the specified value for the given key in the header only for this request.
5. Decodes Profile object on a successful response. If it is not optional, a failure handler can be called.
6. Since this moment we're operating on a request, not a request builder.
7. A handler called if Restler would successfully end request.
8. A handler called on completion of the request whatever the result would be.
9. Create and start data task.

#### POST

```swift
Restler(baseURL: myBaseURL)
  .post(Endpoint.myProfile) // 1
  .body(anEncodableQueryObject) // 2
  .failureDecode(ErrorToDecodeOnFailure.self)
  .decode(Profile.self)

  .onFailure({ error in // 3
    print("\(error)")
  })
  .onCompletion({ _ in
    hideLoadingIndicator()
  })
  .start()
```

1. Makes POST request to the given endpoint.
2. Encodes the object and puts it into the body of the request. Ignored if the selected request method doesn't support it.
3. A handler called if the request has failed.

#### Other

Any other method call is very similar to these two, but if you have questions simply create an issue.

## Contribution

If you want to contribute in this framework, simply put your pull request here.

If you have found any bug, file it in the issues.

If you would like Restler to do something else, create an issue for feature request.

### Dependencies

#### Gems

- [cocoapods](https://rubygems.org/gems/cocoapods) 1.9.3
- [fastlane](https://rubygems.org/gems/fastlane) 2.149.1
- [slather](https://rubygems.org/gems/slather) 2.4.9
