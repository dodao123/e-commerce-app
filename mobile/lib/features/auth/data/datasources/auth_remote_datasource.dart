import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

/// Remote data source for authentication via social login providers.
class AuthRemoteDatasource {
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  /// Creates AuthRemoteDatasource with required dependencies.
  AuthRemoteDatasource({
    ApiClient? apiClient,
    GoogleSignIn? googleSignIn,
  })  : _apiClient = apiClient ?? ApiClient(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: ApiConstants.googleWebClientId,
            );

  /// Signs in with Google and sends ID token to backend.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    debugPrint('🔵 [Auth] Starting Google Sign-In...');

    // Sign out first to always show account picker
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('🔴 [Auth] Google sign-in cancelled by user');
      throw Exception('Google sign-in cancelled');
    }

    debugPrint('🟢 [Auth] Google user: ${googleUser.email}');
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      debugPrint('🔴 [Auth] No ID token from Google');
      throw Exception('Failed to get Google ID token');
    }

    debugPrint('🟢 [Auth] Got ID token, sending to backend...');
    return _apiClient.post(
      ApiConstants.googleLoginEndpoint,
      {'id_token': idToken},
    );
  }

  /// Signs in with Facebook and sends access token to backend.
  Future<Map<String, dynamic>> signInWithFacebook() async {
    debugPrint('🔵 [Auth] Starting Facebook Login...');

    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
      loginBehavior: LoginBehavior.webOnly,
    );

    debugPrint('🔵 [Auth] Facebook status: ${result.status}');
    debugPrint('🔵 [Auth] Facebook message: ${result.message}');

    if (result.status != LoginStatus.success) {
      debugPrint('🔴 [Auth] Facebook failed: ${result.message}');
      throw Exception('Facebook login failed: ${result.message}');
    }

    final accessToken = result.accessToken?.tokenString;
    if (accessToken == null) throw Exception('No Facebook access token');

    debugPrint('🟢 [Auth] Got FB token, sending to backend...');
    return _apiClient.post(
      ApiConstants.facebookLoginEndpoint,
      {'access_token': accessToken},
    );
  }

  /// Updates the user's role after initial login.
  Future<Map<String, dynamic>> updateRole(
    String token,
    String role,
  ) async {
    debugPrint('🔵 [Auth] Updating role to: $role');
    return _apiClient.post(
      ApiConstants.updateRoleEndpoint,
      {'role': role},
      authToken: token,
    );
  }

  /// Signs out from all providers.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    debugPrint('🟢 [Auth] Signed out');
  }
}
