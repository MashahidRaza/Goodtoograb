// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<void>? _inFlight;

bool _scriptAlreadyPresent() {
  for (final node in html.document.querySelectorAll('script')) {
    final src = node.getAttribute('src') ?? '';
    if (src.contains('maps.googleapis.com/maps/api/js')) {
      return true;
    }
  }
  return false;
}

Future<void> ensureGoogleMapsScriptLoaded(String apiKey) async {
  if (apiKey.isEmpty) return;
  if (_scriptAlreadyPresent()) return;
  _inFlight ??= _inject(apiKey);
  return _inFlight!;
}

Future<void> _inject(String apiKey) async {
  if (apiKey.isEmpty) return;
  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..async = true
    ..defer = true
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&loading=async';
  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(StateError('Could not load Google Maps JavaScript API'));
    }
  });
  html.document.head!.append(script);
  return completer.future;
}
