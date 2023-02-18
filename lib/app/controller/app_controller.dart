import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  GoogleProvider googleProvider = GoogleProvider(
    clientId: dotenv.env['GoogleClientId']!,
  );

  RxBool isDark = false.obs;

  final db = FirebaseFirestore.instance;

  String convertCurrency(num number) {
    var formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    return formatter.format(number);
  }
}
