import 'package:google_sign_in/google_sign_in.dart';

void main() {
  // Test if .instance exists
  try {
    print(GoogleSignIn.instance);
  } catch (e) {
    print(e);
  }
}
