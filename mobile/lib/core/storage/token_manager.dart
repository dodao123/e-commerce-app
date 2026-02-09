import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages JWT token storage using platform-secure storage.
/// iOS: Keychain (AES-256), Android: EncryptedSharedPreferences.
class TokenManager {
  static const _accessTokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';
  static const _userAvatarKey = 'user_avatar';
  static const _roleSelectedKey = 'role_selected';

  final FlutterSecureStorage _storage;

  /// Creates a TokenManager with optional storage override.
  TokenManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  /// Saves the access token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Saves user profile data securely.
  Future<void> saveUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    String avatarUrl = '',
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userEmailKey, value: email),
      _storage.write(key: _userNameKey, value: fullName),
      _storage.write(key: _userRoleKey, value: role),
      _storage.write(key: _userAvatarKey, value: avatarUrl),
    ]);
  }

  /// Retrieves the stored access token, or null if none.
  Future<String?> getToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Retrieves stored user profile as a map.
  Future<Map<String, String?>> getUserProfile() async {
    final results = await Future.wait([
      _storage.read(key: _userIdKey),
      _storage.read(key: _userEmailKey),
      _storage.read(key: _userNameKey),
      _storage.read(key: _userRoleKey),
      _storage.read(key: _userAvatarKey),
    ]);
    return {
      'id': results[0],
      'email': results[1],
      'full_name': results[2],
      'role': results[3],
      'avatar_url': results[4],
    };
  }

  /// Marks that this email has explicitly selected a role.
  Future<void> markRoleSelected(String email) async {
    await _storage.write(key: '${_roleSelectedKey}_$email', value: 'true');
  }

  /// Returns true if this email has previously selected a role.
  Future<bool> hasSelectedRole(String email) async {
    final value = await _storage.read(key: '${_roleSelectedKey}_$email');
    return value == 'true';
  }

  /// Clears auth data but preserves role selection flag.
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userRoleKey),
      _storage.delete(key: _userAvatarKey),
      // NOTE: _roleSelectedKey is NOT deleted — persists across logins
    ]);
  }

  /// Returns true if an access token exists.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
