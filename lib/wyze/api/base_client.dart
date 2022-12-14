import '../errors/wyze_errors.dart';

class BaseClient {
  String? token;
  String? userId;
  String? baseUrl;

  BaseClient({
    this.token,
    this.userId,
    this.baseUrl,
  }) {
    if (token == null) {
      throw const WyzeClientConfigurationError("client is not logged in");
    }
    token = token?.trim();
  }
}
