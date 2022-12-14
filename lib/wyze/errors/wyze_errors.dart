import 'dart:core';

/// Base class for Client errors
class WyzeClientError implements Exception {
    final String message;

    const WyzeClientError([this.message = '']);

    @override
    String toString() => "WyzeClientError: $message";
}


/// Error raised when there's a problem with the request that's being submitted
class WyzeRequestError implements WyzeClientError {
    @override
    final String message;

    const WyzeRequestError([this.message = '']);

    @override
    String toString() => "WyzeRequestError: $message";
}


/// Error raised when there's a problem with the request that's being submitted
class WyzeFeatureNotSupportedError implements WyzeRequestError {
    final String action;

    const WyzeFeatureNotSupportedError([this.action = '']);

    @override
    String toString() => "WyzeFeatureNotSupportedError: $action is not supported on this device";

    @override
    String get message => action;
}


/// Error raised when Wyze does not send the expected response
class WyzeApiError implements WyzeClientError {
    final String response;

    const WyzeApiError([this.response = '']);

    @override
    String toString() => "WyzeApiError: The server responded with: $response";

    @override
    String get message => response;
}

/// Error raised when attempting to send messages over the websocket when the connection is closed
class WyzeClientNotConnectedError implements WyzeClientError {
    final String message;

    const WyzeClientNotConnectedError([this.message = '']);

    @override
    String toString() => "WyzeClientNotConnectedError: $message";
}

/// Error raised when a constructed object is not valid/malformed
class WyzeObjectFormationError implements WyzeClientError {
    final String message;

    const WyzeObjectFormationError([this.message = '']);

    @override
    String toString() => "WyzeObjectFormationError: $message";
}

/// Error raised when attempting to send messages over the websocket when the connection is closed
class WyzeClientConfigurationError implements WyzeClientError {
    final String message;

    const WyzeClientConfigurationError([this.message = '']);

    @override
    String toString() => "WyzeClientConfigurationError: $message";
}
