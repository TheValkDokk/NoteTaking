import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motion/motion.dart';
import 'package:notetaking/app/controller/app_controller.dart';
import 'package:notetaking/firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance
    ..initialize()
    ..updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: [
        '01FB1DAF5731A3F4D6EDD7A34E3C4441',
        '09CB85794AC27904206320C8283EAECF'
      ]),
    );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!GetPlatform.isWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await GetStorage.init();
  await dotenv.load();
  if (kIsWeb) {
  } else {
    await Motion.instance.initialize();
    Motion.instance.setUpdateInterval(60.fps);
  }

  Get.put(AppController());

  runApp(
    GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      title: "Note Taking",
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
    ),
  );
}
