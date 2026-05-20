import 'maps_script_loader_stub.dart'
    if (dart.library.html) 'maps_script_loader_web.dart' as impl;

Future<void> ensureGoogleMapsScriptLoaded(String apiKey) =>
    impl.ensureGoogleMapsScriptLoaded(apiKey);
