<<<<<<< HEAD
# goodtoograb

A Flutter food-rescue style app (Discover, Browse with list/map, etc.).

## Google Maps (mobile app — Android & iOS)

You are **not** required to set anything for **web** if you only run on a phone or emulator:

- **Android:** `flutter run` on an emulator or device → set the key in `android/app/src/main/res/values/strings.xml` (`google_maps_key`). It is referenced from `AndroidManifest.xml`.
- **iOS:** run on a simulator or device → set `GMSApiKey` in `ios/Runner/Info.plist`.

The **`GOOGLE_MAPS_WEB_API_KEY` / `--dart-define`** path is **only** for `flutter run -d chrome` (or other web targets). Skip it for pure mobile development.

### Where the keys come from (same Google account for both platforms)

Google Maps is **not** “no sign-up forever free,” but Google gives a **[monthly $200 Maps platform credit](https://developers.google.com/maps/billing-and-pricing/pricing#pricing-for-the-core-services)** that covers typical development and small apps. You still need:

1. A **[Google Cloud project](https://console.cloud.google.com/projectcreate)**  
2. **[Billing enabled](https://console.cloud.google.com/billing)** on that project (required to create Maps API keys; many apps stay under the free credit)  
3. The right APIs turned on, then create **API keys** under **APIs & services → Credentials**

Official entry points:

| Step | Link |
|------|------|
| Cloud Console (home) | https://console.cloud.google.com/ |
| Get started — Maps for Android | https://developers.google.com/maps/documentation/android-sdk/get-api-key |
| Get started — Maps for iOS | https://developers.google.com/maps/documentation/ios-sdk/get-api-key |
| Pricing & $200 credit overview | https://developers.google.com/maps/billing-and-pricing/pricing |

**APIs to enable** (in [APIs & Services → Library](https://console.cloud.google.com/apis/library)) for this app:

- **Maps SDK for Android** (Android builds)
- **Maps SDK for iOS** (iOS builds)
- **Maps JavaScript API** — only if you build/run **web** and use the optional `--dart-define=GOOGLE_MAPS_WEB_API_KEY=...` flow

Then create an **API key** (or two: one restricted to Android package + SHA-1, one restricted to iOS bundle id). Paste:

- Android key string → `android/app/src/main/res/values/strings.xml` → `google_maps_key`
- iOS key string → `ios/Runner/Info.plist` → `GMSApiKey`

Replace the `YOUR_GOOGLE_MAPS_*` placeholders already in the repo.

### If you refuse Google Cloud entirely

`google_maps_flutter` **requires** Google map tiles and keys. A **fully keyless** map means switching to something like **[flutter_map](https://pub.dev/packages/flutter_map)** + **OpenStreetMap** tiles (different code than this project uses today).

## Getting Started (Flutter)

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Flutter documentation](https://docs.flutter.dev/)
=======
# Goodtoograb
>>>>>>> 1f349e1981be364ef3fb95495ddcab93544e5b1d
