import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notetaking/app/data/field_translate.dart';
import 'package:notetaking/app/data/inputfield.dart';
import 'package:notetaking/static.dart';

class AddNoteController extends GetxController {
  String docId = "";

  bool isEdit = true;

  RxList<FieldTranslate> settings = <FieldTranslate>[].obs;
  RxMap<String, dynamic> mapSetting = <String, dynamic>{}.obs;
  final TextEditingController noteCtl = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    if (isEdit) {
      mapSetting.bindStream(appController.db
          .collection('notes')
          .doc(docId)
          .snapshots()
          .map(mapSettingStream));
    } else {
      addTextField();
    }
  }

  @override
  void onInit() {
    super.onInit();
    try {
      docId = Get.parameters["docId"]!;
    } catch (e) {
      isEdit = false;
    }
  }

  Map<String, dynamic> mapSettingStream(
      DocumentSnapshot<Map<String, dynamic>> e) {
    log(e.data()!['columnSetting'].toString());
    translateField(e.data()!['columnSetting']);
    addTextFieldWithSetting(e.data()!['columnSetting']);
    noteCtl.text = e.data()!['label'];
    return e.data()!;
  }

  final List<Field> availableFields = [
    Field(name: 'Name', inputType: 'text'),
    Field(name: 'Phone', inputType: 'phone'),
    Field(name: 'Age', inputType: 'number'),
    Field(name: 'Note', inputType: 'multiline'),
    Field(name: 'Date', inputType: 'date'),
    Field(name: 'Money', inputType: 'money'),
  ];

  RxList<Field> fields = <Field>[].obs;

  RxList<TextEditingController> textControllers = <TextEditingController>[].obs;
  RxList<int> fieldIndexList = <int>[].obs;

  void addTextField() {
    fields.add(availableFields[0]);
    final controller = TextEditingController();
    textControllers.add(controller);
    fieldIndexList.add(0);
  }

  void addTextFieldWithSetting(List colSetting) {
    for (int i = 0; i < settings.length; i++) {
      final controller = TextEditingController();
      controller.text = settings[i].name;
      final fieldIndex = availableFields
          .indexWhere((element) => element.inputType == colSetting[i]['type']);
      fields.add(availableFields[fieldIndex]);
      fieldIndexList.add(fieldIndex);
      textControllers.add(controller);
    }
  }

  void onFieldChanged(int index, int fieldIndex) {
    fields[fieldIndex] = availableFields[index];
  }

  void removeTextField(int index) {
    fields.removeAt(index);
    textControllers.removeAt(index);
  }

  void translateField(List colSetting) {
    settings.clear();
    for (var i in colSetting) {
      String name = i['label'];
      dynamic type = TextInputType.text;
      switch (i['type']) {
        case "phone":
          type = TextInputType.phone;
          break;
        case "number":
          type = TextInputType.number;
          break;
        case "multiline":
          type = TextInputType.multiline;
          break;
        case "money":
          type = "money";
          break;
        case "date":
          type = "date";
          break;
        default:
          type = TextInputType.text;
          break;
      }
      settings.add(FieldTranslate(name, type));
    }
  }

  void saveNote(BuildContext c, FocusNode noteFocus) async {
    final fieldNames =
        textControllers.map((controller) => controller.text.trim()).toList();
    final validFieldNames =
        fieldNames.where((name) => name.isNotEmpty).toList();
    if (noteCtl.text.trim().isEmpty) {
      showDialog(
        context: c,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please name your note'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                noteFocus.requestFocus();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (validFieldNames.isEmpty) {
      // show an error message if no fields were added or all field names are empty
      showDialog(
        context: c,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Please add at least one field with a valid name.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    List<Map<String, dynamic>> temp = [];
    try {
      for (int i = 0; i < textControllers.length; i++) {
        temp.add({
          "label": validFieldNames[i],
          "type": fields[i].inputType,
        });
      }

      if (isEdit) {
        Map<String, dynamic> map = {
          'label': noteCtl.text,
          "isDeleted": false,
          "lastUpdate": Timestamp.now(),
          "columnSetting": temp,
        };
        Get.defaultDialog(
          title: "Please Wait",
          content: const CircularProgressIndicator.adaptive(),
        );
        await _updateNoteToFirebase(map);
        Get.back();
        Get.back();
        Get.snackbar("", "Note Updated");
      } else {
        Map<String, dynamic> map = {
          'label': noteCtl.text,
          'createdBy': FirebaseAuth.instance.currentUser!.email,
          "isDeleted": false,
          "createAt": Timestamp.now(),
          "lastUpdate": Timestamp.now(),
          "columnSetting": temp,
          "showTitle": true,
          'gridCount': 3,
        };
        Get.defaultDialog(
          title: "Please Wait",
          content: const CircularProgressIndicator.adaptive(),
        );

        await _saveNoteToFirebase(map);
        Get.back();
        Get.back();
        Get.snackbar("", "New Note Added");
      }
    } catch (e) {
      showDialog(
        context: c,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Please fill remaining empty field with a valid name.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future _saveNoteToFirebase(Map<String, dynamic> map) async {
    await appController.db.collection("notes").add(map);
  }

  Future _updateNoteToFirebase(Map<String, dynamic> map) async {
    await appController.db
        .collection("notes")
        .doc(docId)
        .set(map, SetOptions(merge: true));
  }
}
