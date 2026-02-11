import 'package:flutter/material.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/email_auth_datasource.dart';
import '../../../core/storage/token_manager.dart';

/// Manages authentication state across the app.
/// JWT stored securely: iOS Keychain / Android EncryptedSharedPrefs.
class AuthProvider extends ChangeNotifier {
  final AuthRemoteDatasource _socialAuth;
  final EmailAuthDatasource _emailAuth;
  final TokenManager _tokenManager;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _hasSelectedRole = false;
  String? _accessToken;
  String? _errorMessage;
  Map<String, String?> _userProfile = {};

  /// Creates AuthProvider with all auth dependencies.
  AuthProvider({
    AuthRemoteDatasource? socialAuth,
    EmailAuthDatasource? emailAuth,
    TokenManager? tokenManager,
  })  : _socialAuth = socialAuth ?? AuthRemoteDatasource(),
        _emailAuth = emailAuth ?? EmailAuthDatasource(),
        _tokenManager = tokenManager ?? TokenManager();

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasSelectedRole => _hasSelectedRole;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String get userName => _userProfile['full_name'] ?? '';
  String get userEmail => _userProfile['email'] ?? '';
  String get userRole => _userProfile['role'] ?? '';
  String get avatarUrl => _userProfile['avatar_url'] ?? '';

  /// Checks stored token on app startup.
  Future<void> checkAuthStatus() async {
    _isLoggedIn = await _tokenManager.hasToken();
    if (_isLoggedIn) {
      _accessToken = await _tokenManager.getToken();
      _userProfile = await _tokenManager.getUserProfile();
      _hasSelectedRole = await _tokenManager.hasSelectedRole(
          _userProfile['email'] ?? '');
    }
    notifyListeners();
  }

  /// Email registration.
  Future<bool> registerWithEmail({
    required String email, required String password,
    required String fullName,
  }) => _run(() => _emailAuth.register(
        email: email, password: password, fullName: fullName));

  /// Email login.
  Future<bool> loginWithEmail({
    required String email, required String password,
  }) => _run(() => _emailAuth.login(email: email, password: password));

  /// Google OAuth login.
  Future<bool> signInWithGoogle() =>
      _run(() => _socialAuth.signInWithGoogle());

  /// Facebook OAuth login.
  Future<bool> signInWithFacebook() =>
      _run(() => _socialAuth.signInWithFacebook());

  /// Updates the user role via API and marks role as selected.
  Future<bool> updateRole(String role) async {
    if (_accessToken == null) return false;
    _isLoading = true; notifyListeners();
    try {
      await _socialAuth.updateRole(_accessToken!, role);
      _userProfile['role'] = role;
      await _tokenManager.saveUserProfile(
        userId: _userProfile['id'] ?? '',
        email: _userProfile['email'] ?? '',
        fullName: _userProfile['full_name'] ?? '',
        role: role, avatarUrl: _userProfile['avatar_url'] ?? '');
      await _tokenManager.markRoleSelected(_userProfile['email'] ?? '');
      _hasSelectedRole = true;
      _isLoading = false; notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  /// Sign out — clears secure storage.
  Future<void> signOut() async {
    await _socialAuth.signOut();
    await _tokenManager.clearAll();
    _isLoggedIn = false; _hasSelectedRole = false;
    _accessToken = null; _userProfile = {};
    notifyListeners();
  }

  void clearError() { _errorMessage = null; notifyListeners(); }

  Future<bool> _run(Future<Map<String, dynamic>> Function() call) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final res = await call();
      _accessToken = res['access_token'] as String;
      await _tokenManager.saveToken(_accessToken!);
      debugPrint('🔑 JWT TOKEN: $_accessToken');
      final u = res['user'] as Map<String, dynamic>;
      await _tokenManager.saveUserProfile(
        userId: u['id'] ?? '', email: u['email'] ?? '',
        fullName: u['full_name'] ?? '', role: u['role'] ?? '',
        avatarUrl: (u['avatar_url'] as String?) ?? '');
      _userProfile = await _tokenManager.getUserProfile();
      _hasSelectedRole = await _tokenManager.hasSelectedRole(
          _userProfile['email'] ?? '');
      _isLoggedIn = true; _isLoading = false; notifyListeners();
      return true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false; notifyListeners();
      return false;
    }
  }
}
