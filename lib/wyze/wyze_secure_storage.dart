import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WyzeSecureStorageGet {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;

  WyzeSecureStorageGet(this.accessToken, this.refreshToken, this.userId);
}

class WyzeSecureStorage {
  static const accessTokenStorageKey = 'wyze_access_token';
  static const refreshTokenStorageKey = 'wyze_refresh_token';
  static const userIdKey = 'wyze_user_id';

  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> clear() async {
    await storage.delete(key: accessTokenStorageKey);
    await storage.delete(key: refreshTokenStorageKey);
    await storage.delete(key: userIdKey);
  }

  Future<void> set({String? accessToken, String? refreshToken, String? userId}) async {
    if (accessToken != null) await storage.write(key: accessTokenStorageKey, value: accessToken);
    if (refreshToken != null) await storage.write(key: refreshTokenStorageKey, value: refreshToken);
    if (userId != null) await storage.write(key: userIdKey, value: userId);
  }

  Future<WyzeSecureStorageGet> get() async {
    final accessToken = await storage.read(key: accessTokenStorageKey);
    final refreshToken = await storage.read(key: refreshTokenStorageKey);
    final userId = await storage.read(key: userIdKey);
    return WyzeSecureStorageGet(accessToken, refreshToken, userId);
  }

  Future<bool> isSet() async {
    final creds = await get();
    return creds.accessToken != null && creds.accessToken!.isNotEmpty &&
        creds.refreshToken != null && creds.refreshToken!.isNotEmpty &&
        creds.userId != null && creds.userId!.isNotEmpty;
  }
}
