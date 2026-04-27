class AppConfig {
  AppConfig._();

  // Web OAuth Client ID from Google Cloud Console (server-side)
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '437511136009-pddn35icihv85ujqrhu3afik6k35l74b.apps.googleusercontent.com',
  );

  // Must match an Authorized Redirect URI in Google Cloud Console → Web Client
  static const String googleRedirectUri = String.fromEnvironment(
    'GOOGLE_REDIRECT_URI',
    defaultValue: 'https://slim-way-server.onrender.com/',
  );
}
