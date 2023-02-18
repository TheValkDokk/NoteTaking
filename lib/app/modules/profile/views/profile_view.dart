import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:notetaking/static.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      providers: [
        appController.googleProvider,
      ],
      actions: [
        SignedOutAction((context) {
          Get.toNamed('/sign-in');
        }),
      ],
    );
  }
}
