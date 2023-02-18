import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:notetaking/app/controller/app_controller.dart';
import 'package:notetaking/static.dart';

class LoginView extends GetView<AppController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        appController.googleProvider,
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Get.offNamed('/home');
        }),
      ],
      showAuthActionSwitch: true,
      subtitleBuilder: (context, action) {
        return const Text("Welcome to NoteTaking");
      },
    );
  }
}
