import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlDh74-HThh7yu9p74xLHlreIwp27nQY4', // Replace this with your web API key
    appId: '1:298670393818:web:762d28a065a209ddc318e3', // Replace this with your web app ID
    messagingSenderId: '298670393818', // Replace this with your messaging sender ID
    projectId: 'smartparking-79613', // Replace this with your project ID
    authDomain: 'smartparking-79613.firebaseapp.com', // Replace this with your auth domain
    storageBucket: 'smartparking-79613.appspot.com', // Replace this with your storage bucket
    measurementId: 'G-9CWC7VGKRN', // Replace this with your measurement ID (if you have one)
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBSf3WMZrelNYH3gXrUg1XPmENrsAafFA', // Replace this with your Android API key
    appId: '1:298670393818:android:5854d75440a773d4c318e3', // Replace this with your Android app ID
    messagingSenderId: '298670393818', // Replace this with your messaging sender ID
    projectId: 'smartparking-79613', // Replace this with your project ID
    storageBucket: 'smartparking-79613.appspot.com', // Replace this with your storage bucket
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTAapHpS6ujwHeXTRUuEqgUW9MYfw-g-k', // Replace this with your iOS API key
    appId: '1:298670393818:ios:71e1fa13b6ede27fc318e3', // Replace this with your iOS app ID
    messagingSenderId: '298670393818', // Replace this with your messaging sender ID
    projectId: 'smartparking-79613', // Replace this with your project ID
    storageBucket: 'smartparking-79613.appspot.com', // Replace this with your storage bucket
    iosBundleId: 'com.KMEC.smartparking', // Replace this with your iOS bundle ID
  );
}