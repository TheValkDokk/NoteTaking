import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notetaking/static.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  GoogleProvider googleProvider = GoogleProvider(
    clientId: dotenv.env['GoogleClientId']!,
  );

  RxBool isDark = false.obs;
  RxString goCommand = ''.obs;

  @override
  void onReady() {
    super.onReady();
    if (GetPlatform.isAndroid) {
      goCommand.bindStream(appController.db
          .collection('commands')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .snapshots()
          .map(snapshotCommand));

      ever(goCommand, exeCommand);
    }
  }

  Future exeCommand(String cmd) async {
    await appController.db
        .collection('commands')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set({'isActive': false}, SetOptions(merge: true));
    Get.toNamed(cmd);
  }

  String snapshotCommand(DocumentSnapshot<Map<String, dynamic>> element) {
    if (element.data() == null) {
      return '';
    } else {
      try {
        if (element.data()!['cmd'] == null ||
            element.data()!['cmd'].isEmpty ||
            element.data()!['isActive'] == null ||
            element.data()!['isActive'] == false) {
          return '';
        } else {
          return element.data()!['cmd'];
        }
      } catch (e) {
        return '';
      }
    }
  }

  final db = FirebaseFirestore.instance;

  String convertCurrency(num number) {
    var formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    return formatter.format(number);
  }
}
