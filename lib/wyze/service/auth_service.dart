import 'dart:convert';
import 'package:otp/otp.dart';

import 'package:battery_saver/wyze/errors/wyze_errors.dart';
import 'package:http/http.dart' as http;

import '../signature/signature.dart';
import 'base.dart';

class AuthServiceClient extends ExServiceClient {
  /// Auth service client is the wrapper on the requests to https://auth-prod.api.wyze.com
  static const wyzeApiKey = 'RckMFKbsds5p6QY3COEXc2ABwNTYY0q18ziEiSEm';
  static const wyzeApiUrl = "https://auth-prod.api.wyze.com";

  String? token;
  String? baseUrl = wyzeApiUrl;
  String apiKey = wyzeApiKey;

  AuthServiceClient({
    this.token,
    this.baseUrl = wyzeApiUrl,
    this.apiKey = wyzeApiKey,
  }) : super(token: token, baseUrl: baseUrl, requestVerifier: RequestVerifier());

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
    requestSpecificHeaders['x-api-key'] = apiKey;

    return super.getHeaders(requestSpecificHeaders: requestSpecificHeaders);
  }

  @override
  Future<http.Response> apiCall({
    required String apiEndpoint,
    String httpVerb = "POST",
    Map? data,
    Map<String, dynamic>? params,
    Map? json,
    Map? headers,
    Map? auth,
    Map<String, String>? requestSpecificHeaders,
    int? nonce,
  }) {
    nonce ??= requestVerifier?.clock.nonce();

    return super.apiCall(
      apiEndpoint: apiEndpoint,
      httpVerb: httpVerb,
      params: params,
      json: json,
      headers: getHeaders(requestSpecificHeaders: requestSpecificHeaders, nonce: nonce),
      nonce: nonce,
    );
  }

  Future<http.Response> userLogin({
    required String email,
    required String password,
    String? totpKey,
  }) async {
    if (requestVerifier == null) throw const WyzeApiError('requestVerifier is null');

    final nonce = requestVerifier!.clock.nonce();
    password = requestVerifier!.md5String(requestVerifier!.md5String(requestVerifier!.md5String(password)));
    final kwargs = {
      'nonce': nonce.toString(),
      'email': email,
      'password': password
    };
    final response = await apiCall(apiEndpoint: '/user/login', json: kwargs, nonce: nonce);
    final decodedResponse = jsonDecode(response.body) as Map;
    print(decodedResponse);
    if (decodedResponse['access_token'] != null) return response;
    if (decodedResponse['errorCode'] == 1000) throw const WyzeApiError('Too many failed attempts');

    var mfaType = '';
    var verificationCode = '';
    var verificationId = '';

    print(decodedResponse);
    if (decodedResponse.containsKey('mfa_options') &&
        decodedResponse['mfa_options'] is List &&
        (decodedResponse['mfa_options'] as List).contains('TotpVerificationCode')) {
      // TOTP 2FA
      mfaType = 'TotpVerificationCode';
      if (totpKey != null) {
        // From: https://github.com/susam/mintotp/blob/b96dce1a1879d71efc300cd7c8b6c178a52fafec/mintotp.py#L19
        // def totp(key, time_step=30, digits=6, digest='sha1'):
        //     return hotp(key, int(time.time() / time_step), digits, digest)
        verificationCode = OTP.generateTOTPCode(totpKey, ((DateTime.now().millisecondsSinceEpoch / 1000) / 30).round(), algorithm: Algorithm.SHA1).toString();
      } else {
        verificationCode = ''; // TODO ASK FOR 2FA
      }
      verificationId = decodedResponse['mfa_details']['totp_apps'][0]['app_id'];
    } else {
      // SMS 2FA
      mfaType = 'PrimaryPhone';
      final params = {
        'mfaPhoneType': 'Primary',
        'sessionId': decodedResponse['sms_session_id'],
        'userId': decodedResponse['user_id']
      };
      final responsePhone = await apiCall(apiEndpoint: '/user/login/sendSmsCode', params: params, json: {});
      final decodedPhoneResponse = jsonDecode(responsePhone.body) as Map;
      verificationId = decodedPhoneResponse['session_id'];
      verificationCode = ''; // TODO get the user to give the input
    }

    final payload = {
      'email': email,
      'password': password,
      'mfa_type': mfaType,
      'verification_id': verificationId,
      'verification_code': verificationCode
    };
    return apiCall(apiEndpoint: '/user/login', json: payload, nonce: requestVerifier!.clock.nonce());
  }
}
