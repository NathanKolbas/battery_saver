import 'dart:convert';

import 'package:crypto/crypto.dart';

class Clock {
  double now() => DateTime.now().millisecondsSinceEpoch / 1000;
  int nonce() => DateTime.now().millisecondsSinceEpoch;
}

class RequestVerifier {
  String? signingSecret;
  String? accessToken;
  late Clock clock;

  RequestVerifier({this.signingSecret, this.accessToken, clock}) {
    this.clock = clock ?? Clock();
  }

  requestId(int? timestamp) {
    if (timestamp != null) return md5String(md5String(timestamp));

    return md5String(md5String(clock.nonce()));
  }

  String md5String(dynamic body) {
    if (body is int) body = body.toString();
    if (body is String) body = utf8.encode(body);

    return md5.convert(body).toString();
  }

  generateDynamicSignature({String? timestamp, dynamic body}) {
    if (timestamp == null) return null;

    body ??= '';
    if (body is List<int>) body = utf8.decode(body);

    final formatReq = utf8.encode("$body");
    final encodedSecret = utf8.encode(md5String("$accessToken$signingSecret"));
    final requestHash = Hmac(md5, encodedSecret).convert(formatReq);
    return "$requestHash";
  }
}
