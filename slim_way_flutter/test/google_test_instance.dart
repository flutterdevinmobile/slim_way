import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Fixed: GoogleSignIn does not have a static 'instance' getter. 
  // Use the constructor to create an instance.
  final googleSignIn = GoogleSignIn();
  debugPrint('Google Sign-In object created: $googleSignIn');

  debugPrint('Diagnostic test: All prints replaced with debugPrint');
}
