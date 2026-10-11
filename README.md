# Innerloom

A daily emotional ritual with Future Self.

Android is the production target. Chrome is supported for development.

## Internal alpha

The upload keystore stays off git. `android/key.properties` and `*.jks` are already ignored.

1. Create the keystore once, at `android/app/upload-keystore.jks`:

```
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy `android/key.properties.example` to `android/key.properties` and replace both passwords. `storeFile` is relative to `android/app/`.

3. Build the sideload apk:

```
flutter build apk --release
```

The apk is `build/app/outputs/flutter-apk/app-release.apk`.

Release builds require that keystore and `android/key.properties`. If either is missing, the release build fails. Debug builds are unchanged.
