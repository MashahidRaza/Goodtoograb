/// **Mobile (Android / iOS):** ignore this file — maps use native keys in
/// `android/.../strings.xml` and `ios/Runner/Info.plist`. This value is only
/// read when you run or build **for web** (`-d chrome`, etc.).
///
/// Web only: `flutter run -d chrome --dart-define=GOOGLE_MAPS_WEB_API_KEY=your_key`
abstract final class AppMapsConfig {
  static const String webApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_WEB_API_KEY',
    defaultValue: '',
  );

  static bool get hasWebApiKey => webApiKey.isNotEmpty;
}
