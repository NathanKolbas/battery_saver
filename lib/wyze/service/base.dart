import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../errors/wyze_errors.dart';
import '../signature/signature.dart';

class BaseServiceClient {
  static const wyzeAppId = "9319141212m2ik";
  static const wyzeAppName = "wyze";
  static const wyzeAppVersion = "2.19.14";
  static const wyzeAppType = 2;

  String? token;
  String? baseUrl;
  int? timeout;
  Map<String, String>? headers;
  String? appId;
  String? appName;
  String? appVersion;
  String? userAgentPrefix;
  String? userAgentSuffix;
  String? phoneId;
  int? phoneType;
  RequestVerifier? requestVerifier;

  BaseServiceClient({
    this.token,
    this.baseUrl,
    this.timeout = 30,
    this.headers,
    this.appId = wyzeAppId,
    this.appName = wyzeAppName,
    this.appVersion = wyzeAppVersion,
    this.userAgentPrefix,
    this.userAgentSuffix,
    this.phoneId,
    this.phoneType = wyzeAppType,
    this.requestVerifier,
  }) {
    token = token?.trim();
    headers ??= {};
    phoneId ??= const Uuid().v4();
  }

  Future<http.Response> doPost({
    required String url,
    Map<String, String>? headers,
    Map? payload,
    Map<String, dynamic>? params,
  }) {
    headers ??= {};
    payload ??= {};
    params ??= {};

    // Need to set the content type manually
    headers['Accept'] = '*/*';
    headers['Content-Type'] = 'application/json';

    return http.post(Uri.parse(url).replace(queryParameters: params), body: jsonEncode(payload), headers: headers);
  }

  Future<http.Response> doGet({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? payload,
  }) {
    headers ??= {};
    payload ??= {};
    return http.get(Uri.parse(url).replace(queryParameters: payload), headers: headers);
  }

  /// Create a request and execute the API call to Wyze.
  /// Args:
  ///     api_endpoint (str): The target Wyze API endpoint.
  ///         e.g. '/app/v2/home_page/get_object_list'
  ///     http_verb (str): HTTP Verb. e.g. 'POST'
  ///     data: The body to attach to the request. If a dictionary is
  ///         provided, form-encoding will take place.
  ///         e.g. {'key1': 'value1', 'key2': 'value2'}
  ///     params (dict): The URL parameters to append to the URL.
  ///         e.g. {'key1': 'value1', 'key2': 'value2'}
  ///     json (dict): JSON for the body to attach to the request
  ///         (if data is not specified).
  ///         e.g. {'key1': 'value1', 'key2': 'value2'}
  ///     headers (dict): Additional request headers
  ///     auth (dict): A dictionary that consists of access_token and refresh_token
  /// Returns:
  ///     (WyzeResponse)
  ///         The server's response to an HTTP request. Data
  ///         from the response can be accessed like a dict.
  /// Raises:
  ///     WyzeApiError: The following Wyze API call failed:
  ///         '/app/v2/home_page/get_object_list'.
  ///     WyzeRequestError: JSON data can only be submitted as
  ///         POST requests.
  Future<http.Response> apiCall({
    required String apiEndpoint,
    String httpVerb = "POST",
    Map? data,
    Map<String, dynamic>? params,
    Map? json,
    Map<String, String>? headers,
    Map? auth,
  }) {
    final hasJson = json != null;
    if (hasJson && httpVerb != "POST") {
      const msg = "JSON data can only be submitted as POST requests. GET requests should use the 'params' argument.";
      throw const WyzeRequestError(msg);
    }

    final apiUrl = getUrl(baseUrl ?? '', apiEndpoint);
    headers ??= {};
    if (this.headers != null) headers.addAll(this.headers!);
    if (httpVerb == "POST") {
      return doPost(url: apiUrl, headers: headers, payload: json, params: params);
    } else if (httpVerb == "GET") {
      return doGet(url: apiUrl, headers: headers, payload: params);
    }

    throw const WyzeRequestError("Unknown request type.");
  }

  /// Joins the base URL and an API endpoint path to form an absolute URL.
  /// Args:
  ///     base_url (str): The base URL. e.g. 'https://api.wyzecam.com'
  ///     api_endpoint (str): The API path. e.g. '/app/v2/home_page/get_object_list'
  /// Returns:
  ///     The absolute endpoint URL.
  ///         e.g. 'https://api.wyzecam.com/app/v2/home_page/get_object_list'
  String getUrl(String baseUrl, String apiEndpoint) => path.url.join(baseUrl, apiEndpoint);

  /// Constructs the headers needed for a request.
  /// Args:
  ///     has_json (bool): Whether or not the request has json.
  ///     has_files (bool): Whether or not the request has files.
  ///     request_specific_headers (dict): Additional headers specified by the user for a specific request.
  /// Returns:
  ///     The headers dictionary.
  ///         e.g. {
  ///             'Content-Type': 'application/json;charset=utf-8',
  ///             'Signature': 'erewf3254rgt453f34f..==',
  ///             'User-Agent': 'Python/3.6.8 wyzeclient/2.1.0 Darwin/17.7.0'
  ///         }
  Map<String, String> getHeaders({
    Map<String, String>? headers,
    String? signature,
    String? signature2,
    bool hasJson = false,
    Map<String, String>? requestSpecificHeaders,
  }) {
    Map<String, String> finalHeaders = {
      'Accept-Encoding': 'gzip',
    };
    if (headers == null || !headers.containsKey('User-Agent')) {
      finalHeaders["User-Agent"] = "okhttp/4.7.2";
    }

    if (signature != null) finalHeaders['Signature'] = signature;
    if (signature2 != null) finalHeaders['Signature2'] = signature2;
    headers ??= {};

    // Merge headers specified at client initialization.
    finalHeaders.addAll(headers);

    // Merge headers specified for a specific request. e.g. oauth.access
    if (requestSpecificHeaders != null) finalHeaders.addAll(requestSpecificHeaders);

    if (hasJson) finalHeaders['Content-Type'] = 'application/json;charset=utf-8';

    return finalHeaders;
  }

  String getSortedParams(List<MapEntry>? params) {
    params ??= [];

    return params.map((e) => e.key + '=' + e.value).join('&');
  }
}

class WpkNetServiceClient extends BaseServiceClient {
  /// wpk net service client is the wrapper to newer Wyze services like WpkWyzeSignatureService and WpkWyzeExService.
  static const wyzeAppName = "com.hualai";
  static const wyzeSalts = {
    "9319141212m2ik": "wyze_app_secret_key_132",
    "venp_4c30f812828de875": "CVCSNoa0ALsNEpgKls6ybVTVOmGzFoiq",
  };

  String? token;
  String? baseUrl;
  String? appId;
  String? appName;
  RequestVerifier? requestVerifier;

  WpkNetServiceClient({
    this.token,
    this.baseUrl = "https://api.wyzecam.com/",
    this.appName = wyzeAppName,
    this.appId = BaseServiceClient.wyzeAppId,
    this.requestVerifier,
  }) : super(
    token: token,
    baseUrl: baseUrl,
    appName: appName,
    appId: appId,
    requestVerifier: requestVerifier ?? RequestVerifier(signingSecret: WpkNetServiceClient.wyzeSalts[appId] ?? '', accessToken: token)
  );

  @override
  Map<String, String> getHeaders({
    Map? headers,
    String? signature,
    String? signature2,
    bool hasJson = false,
    Map<String, String>? requestSpecificHeaders,
    int? nonce,
  }) {
    requestSpecificHeaders ??= {};

    requestSpecificHeaders.addAll({
      'access_token': token ?? '',
      'requestid': requestVerifier?.requestId(nonce),
    });

    return super.getHeaders(headers: null, hasJson: false, requestSpecificHeaders: requestSpecificHeaders);
  }

  @override
  Future<http.Response> apiCall({
    required String apiEndpoint,
    String httpVerb = "POST",
    Map? data,
    Map<String, dynamic>? params,
    Map? json,
    Map<String, String>? headers,
    Map? auth,
    int? nonce,
  }) {
    headers ??= {};

    if (httpVerb == 'POST') {
      json ??= {};
      json['nonce'] = nonce.toString();
      final requestData = jsonEncode(json);
      headers['signature2'] = requestVerifier?.generateDynamicSignature(timestamp: nonce.toString(), body: requestData);
    } else if (httpVerb == 'GET') {
      params ??= {};
      params['nonce'] = nonce.toString();
      headers['signature2'] = requestVerifier?.generateDynamicSignature(
        timestamp: nonce.toString(),
        body: getSortedParams(params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))),
      );
    }

    return super.apiCall(
      apiEndpoint: apiEndpoint,
      httpVerb: httpVerb,
      params: params,
      json: json,
      headers: getHeaders(requestSpecificHeaders: headers, nonce: nonce),
      auth: null,
    );
  }
}

class ExServiceClient extends WpkNetServiceClient {
  String? token;
  String? baseUrl;
  RequestVerifier? requestVerifier;

  ExServiceClient({
    this.token,
    this.baseUrl,
    this.requestVerifier,
  }) : super(
    token: token,
    baseUrl: baseUrl,
    requestVerifier: requestVerifier,
  );

  /// ex service client is the wrapper for WpkWyzeExService
  @override
  Map<String, String> getHeaders({
    Map? headers,
    String? signature,
    String? signature2,
    bool hasJson = false,
    Map<String, String>? requestSpecificHeaders,
    int? nonce,
  }) {
    requestSpecificHeaders ??= {};

    requestSpecificHeaders.addAll({
      'appid': appId ?? '',
      'appinfo': "wyze_android_$appVersion",
      'phoneid': phoneId ?? '',
      'User-Agent': "wyze_android_$appVersion",
    });

    return super.getHeaders(requestSpecificHeaders: requestSpecificHeaders);
  }
}
