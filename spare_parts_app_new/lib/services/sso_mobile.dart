import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class GoogleSSO {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Constants.googleClientId.isNotEmpty ? Constants.googleClientId : null,
    scopes: [
      'email',
    ],
  );

  Future<Map<String, String>?> signIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) return null;

      return {
        'email': user.email,
        'name': user.displayName ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Google sign-in error: $e");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Google sign-out error: $e");
      }
    }
  }
}
