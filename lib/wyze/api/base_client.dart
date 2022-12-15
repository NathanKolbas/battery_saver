import 'dart:convert';

import '../errors/wyze_errors.dart';
import '../service/api_service.dart';

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

  ApiServiceClient apiClient() => baseUrl != null ? ApiServiceClient(token: token, baseUrl: baseUrl) : ApiServiceClient(token: token);

  Future<List<Map>> listDevices() async {
    final response = await apiClient().getObjectList();
    final decodedResponse = jsonDecode(response.body) as Map;
    return List<Map>.from(decodedResponse["data"]["device_list"]);
  }
}
