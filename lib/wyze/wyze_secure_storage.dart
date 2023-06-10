import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WyzeSecureStorageGet {
  final String? accessToken;
  final String? refreshToken;
  /// Note: It looks like the token expires in ~48 hours from testing. However,
  /// their website sets the expiration of the token to 24 hours in the
  /// browsers cookies so that is what I would recommend to check for.
  final String? refreshTokenDate;
  final String? userId;

  WyzeSecureStorageGet(this.accessToken, this.refreshToken, this.refreshTokenDate, this.userId);
}

class WyzeSecureStorage {
  static const accessTokenStorageKey = 'wyze_access_token';
  static const refreshTokenStorageKey = 'wyze_refresh_token';
  static const refreshTokenDateStorageKey = 'wyze_refresh_token_date';
  static const userIdKey = 'wyze_user_id';

  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> clear() async {
    await storage.delete(key: accessTokenStorageKey);
    await storage.delete(key: refreshTokenStorageKey);
    await storage.delete(key: refreshTokenDateStorageKey);
    await storage.delete(key: userIdKey);
  }

  Future<void> set({String? accessToken, String? refreshToken, String? refreshTokenDate, String? userId}) async {
    if (accessToken != null) await storage.write(key: accessTokenStorageKey, value: accessToken);
    if (refreshToken != null) await storage.write(key: refreshTokenStorageKey, value: refreshToken);
    if (refreshToken != null) await storage.write(key: refreshTokenDateStorageKey, value: refreshTokenDate);
    if (userId != null) await storage.write(key: userIdKey, value: userId);
  }

  Future<WyzeSecureStorageGet> get() async {
    final accessToken = await storage.read(key: accessTokenStorageKey);
    final refreshToken = await storage.read(key: refreshTokenStorageKey);
    final refreshTokenDate = await storage.read(key: refreshTokenDateStorageKey);
    final userId = await storage.read(key: userIdKey);
    return WyzeSecureStorageGet(accessToken, refreshToken, refreshTokenDate, userId);
  }

  Future<bool> isSet() async {
    final creds = await get();
    return creds.accessToken != null && creds.accessToken!.isNotEmpty &&
        creds.refreshToken != null && creds.refreshToken!.isNotEmpty &&
        creds.userId != null && creds.userId!.isNotEmpty;
  }
}
