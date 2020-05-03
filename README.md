# flutter-dp3t

> Exposes the [DP3T SDK](https://github.com/DP-3T/dp3t-sdk-ios) API in Flutter.

Heavily inspired by [this React-native homologous library](https://github.com/fmauquie/react-native-dp3t-sdk).

## Status

Pre-alpha. Requires some manual setup to work. Not tested yet. Can change without notice. PRs are welcome!

The [iOS SDK][ios sdk] and [Android SDK][android sdk] themselves are in alpha state.


## Install

We will publish this package in the future, but for now, you must install it locally:

```bash
$ git clone git@github.com:pgte/flutter-dp3t.git
```

Add `dependencies.dp3t` to your `pubspec.yaml` file:

```yaml
dependencies:
  dp3t:
    path: <path to the locally-installed flutter-dp3t package>
```

### Minimum deployment targets:

* iOS 11.0
* Android: Minimum SDK version: 23. Target version: 29


## Initialization

Both iOS and Android require some native code to initialize the DP3T SDK. Here is an example from the embedded example app:

* [iOS initialization](example/ios/Runner/AppDelegate.swift)
* [Android initialization](example/android/app/src/main/kotlin/me/pgte/dp3t_example/MainActivity.kt)

For these both, you will have to declare the dependency on the original SDK.

## Permissions

Both in iOS and Android you need to declare the permissions required for DP3T to work. Please look for them in the original SDKs:

* [iOS][ios sdk]
* [Android][android sdk]

## Example app:

See [the included example app](example).

To run the example app from the terminal:

```bash
$ cd example
$ flutter run
```

## Known issues in the SDK

* The error handling differs a lot between the iOS and the Andriod versions of the DP3T SDK. iOS halts the app on almost all the errors, while the Andriod version seems to handle them more properly.
* iOS needs initializing after resetting, while the Android versions does not.
* It doesn't look like the `jwtPublicKey` initialization argument is being used in the Android version.


## Use

> For the semantic of each API call, please consult the official DP3T documentation.

Import:


```dart
import 'package:dp3t/dp3t.dart';
```

## API


### Future<void> initializeManually({String appId, String reportBaseUrl, String bucketBaseUrl, String jwtPublicKey})

Example:

```dart
await Dp3t.initializeManually({
  appId: "some app id",
  reportBaseUrl: "http://example.com",
  bucketBaseUrl: "http://example.com",
  jwtPublicKey: jwtPublicKey}) // Base64-encoded JWT
```

### Future<void> initializeWithDiscovery({ String appId, bool dev })

Example:

```dart
Dp3t.initializeWithDiscovery({
  appId: "some app id", // used for discovery
  dev: true // true if in the development environment
})
```


### Future<void> reset()

Example:

```dart
await Dp3t.reset()
```


### Future<void> startTracing()

Example:

```dart
await Dp3t.startTracing()
```


### Future<void> stopTracing()

Example:

```dart
await Dp3t.stopTracing()
```

### Future<Map> status()

Example:

```dart
status = await Dp3t.status()
```

The status map is an object with the following shape:

```dart
{
  "tracingState",
  "numberOfHandshakes",
  "numberOfContacts",
  "healthStatus",
  "errors": Array<String>,
  "nativeErrors": Array<String>,
  "matchedContacts": Array<
    {
      "id",
      "reportDate"
    }
  >,
  "lastSyncDate",
  "nativeErrorArg",
  "nativeStatusArg"
}
```

### Future<void> iWasExposed({DateTime onset, String authentication})

Example:

```dart
await iWasExposed({onset: DateTime.now(), authentication: authenticationString })
```

## License

See [LICENSE](./LICENSE)

[ios sdk]: https://github.com/DP-3T/dp3t-sdk-ios
[android sdk]: https://github.com/DP-3T/dp3t-sdk-android
