import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notetaking/static.dart';

class ColorpickerController extends GetxController {
  Rx<Color> itemColor = const Color(0xffefefef).obs;
  Rx<Color> textColor = const Color(0xffefefef).obs;
  RxBool curSelect = true.obs;

  String noteId = "";
  String docId = "";

  @override
  void onInit() {
    super.onInit();
    docId = Get.parameters['docId']!;
    noteId = Get.parameters['noteId']!;
    if (Get.parameters['textColor']!.isNotEmpty) {
      textColor.value = Color(int.parse("0xFF${Get.parameters['textColor']}"));
    }
    if (Get.parameters['itemColor']!.isNotEmpty) {
      itemColor.value = Color(int.parse("0xFF${Get.parameters['itemColor']}"));
    }
  }

  Future saveToFireBase() async {
    Map<String, dynamic> map = {
      "color-for-item-pleaseidontknowhowtopreventsomeonefindthiskey":
          itemColor.value.hex,
      'color-for-textnote': textColor.value.hex,
    };
    await appController.db
        .collection('notes')
        .doc(noteId)
        .collection('items')
        .doc(docId)
        .set(map, SetOptions(merge: true))
        .then(
      (value) {
        if (Get.previousRoute == '') {
          Get.offAllNamed('addnoteitem', parameters: {
            "docId": docId,
            "noteId": noteId,
          });
        } else {
          Get.back();
        }
      },
    );
  }
}
