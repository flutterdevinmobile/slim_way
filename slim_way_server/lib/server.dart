import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;
import 'package:serverpod_auth_idp_server/core.dart' as idp_core;
import 'package:serverpod_auth_idp_server/providers/google.dart' as google_idp;

import 'src/generated/endpoints.dart' as slim_endpoints;
import 'src/generated/protocol.dart' as slim_protocol;
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    slim_protocol.Protocol(),
    slim_endpoints.Endpoints(),
  );

  // 1. Initialize Auth Services for Serverpod 3.2.x (IDP/Google support)
  // This step automatically sets the default pod.authenticationHandler to handle IDP tokens.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      idp_core.ServerSideSessionsConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      google_idp.GoogleIdpConfigFromPasswords(),
    ],
  );

  // 2. WRAP the authentication handler to support BOTH:
  // a) Legacy "Bearer id:key" tokens (Email/Password)
  // b) New IDP tokens (Google)
  final idpHandler = pod.authenticationHandler;
  pod.authenticationHandler = (session, header) async {
    if (header.isEmpty) return null;

    // Strip "Bearer " prefix if present (Commonly sent by Flutter client)
    final token = header.startsWith('Bearer ') ? header.substring(7) : header;

    // A) Try legacy email-based authentication (serverpod_auth_keys table)
    final legacyAuth = await auth.authenticationHandler(session, token);
    if (legacyAuth != null) return legacyAuth;

    // B) Try IDP/Google authentication (handled by the default handler we captured above)
    if (idpHandler != null) {
      try {
        return await idpHandler(session, token);
      } catch (_) {
        return null;
      }
    }

    return null;
  };

  // Configure additional auth settings (Email, User Creation)
  auth.AuthConfig.set(
    auth.AuthConfig(
      sendValidationEmail: (session, email, validationCode) async {
        session.log('VERIFICATION CODE for $email: $validationCode', level: LogLevel.info);
        return true;
      },
      onUserCreated: (session, userInfo) async {
        session.log('SUCCESS: Auth record created for: ${userInfo.email}', level: LogLevel.info);
      },
      // Note: In 3.2.x session duration is managed via token managers.
      // Default is usually 7 days for server-side sessions.
    ),
  );

  // Setup routes
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(FlutterRoute(appDir), '/app');
  } else {
    pod.webServer.addRoute(
      StaticRoute.file(
        File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath()),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();
}
