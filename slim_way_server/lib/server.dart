import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    // FIX: Serverpod 3.x passes the full "Bearer userId:token" string to the handler.
    // But the legacy auth module expects only "userId:token" (no Bearer prefix).
    // We strip "Bearer " here so auth.authenticationHandler can correctly look
    // up the token in the serverpod_auth_keys database table.
    authenticationHandler: (session, header) async {
      final token =
          header.startsWith('Bearer ') ? header.substring(7) : header;
      print('DEBUG-AUTH: header="$header" → token="$token"');
      final authInfo = await auth.authenticationHandler(session, token);
      print(
        'DEBUG-AUTH: result=${authInfo != null ? "SUCCESS userId=${authInfo.userId}" : "FAILED"}',
      );
      return authInfo;
    },
  );

  // REMOVED: pod.initializeAuthServices() was overriding our custom
  // authenticationHandler above, making all tokens unrecognized.
  // The Flutter client uses EmailAuthController (legacy serverpod_auth_server
  // endpoints), not the new IDP system. So we only need auth.AuthConfig.set().

  // Configure the legacy Email auth module for Flutter's EmailAuthController
  auth.AuthConfig.set(
    auth.AuthConfig(
      sendValidationEmail: (session, email, validationCode) async {
        // In development, log the validation code to the console
        print('====================================');
        print('VERIFICATION CODE for $email: $validationCode');
        print('====================================');
        session.log(
          'Verification code for $email: $validationCode',
          level: LogLevel.info,
        );
        return true; // Return true to indicate email was "sent" successfully
      },
      sendPasswordResetEmail: (session, userInfo, validationCode) async {
        print('====================================');
        print('PASSWORD RESET CODE for ${userInfo.email}: $validationCode');
        print('====================================');
        session.log(
          'Password reset code for ${userInfo.email}: $validationCode',
          level: LogLevel.info,
        );
        return true;
      },
    ),
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();
}
