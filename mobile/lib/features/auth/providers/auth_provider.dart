import 'package:flutter/material.dart';
import '../data/datasources/auth_remote_datasource.dart';

/// Manages authentication state across the app.
class AuthProvider extends ChangeNotifier {
  final AuthRemoteDatasource _datasource;

  bool _isLoading = false;
  String? _accessToken;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  /// Creates AuthProvider with datasource dependency.
  AuthProvider({AuthRemoteDatasource? datasource})
      : _datasource = datasource ?? AuthRemoteDatasource();

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// The JWT access token from the backend.
  String? get accessToken => _accessToken;

  /// The authenticated user profile data.
  Map<String, dynamic>? get user => _user;

  /// Error message from the last failed operation.
  String? get errorMessage => _errorMessage;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _accessToken != null;

  /// Signs in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    return _performAuth(() => _datasource.signInWithGoogle());
  }

  /// Signs in with Facebook OAuth.
  Future<bool> signInWithFacebook() async {
    return _performAuth(() => _datasource.signInWithFacebook());
  }

  /// Shared authentication flow for all providers.
  Future<bool> _performAuth(
    Future<Map<String, dynamic>> Function() authCall,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authCall();
      _accessToken = response['access_token'] as String?;
      _user = response['user'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates the user's role after initial login.
  Future<bool> updateRole(String role) async {
    if (_accessToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _datasource.updateRole(_accessToken!, role);
      if (_user != null) _user!['role'] = role;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signs out and clears all auth state.
  Future<void> signOut() async {
    await _datasource.signOut();
    _accessToken = null;
    _user = null;
    notifyListeners();
  }
}
