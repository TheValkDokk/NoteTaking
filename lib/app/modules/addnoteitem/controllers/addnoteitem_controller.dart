import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notetaking/app/data/field_translate.dart';
import 'package:notetaking/app/data/inputfield.dart';
import 'package:notetaking/static.dart';

class AddnoteitemController extends GetxController {
  RxList<Field> colSetting = <Field>[].obs;

  RxList<FieldTranslate> fieldSetting = <FieldTranslate>[].obs;

  List<FocusNode> focusList = [];
  List<TextEditingController> ctrlList = [];

  RxList<String> excluValue = <String>[].obs;
  int excluValueIndex = 0;

  Map<String, dynamic> currentItemMap = {};

  bool isCreate = false;

  //Use for view and update
  String docId = "";
  String noteId = "";
  // RxString dataMap = "".obs;
  RxMap<String, dynamic> dataMap = <String, dynamic>{}.obs;

  String textColor = "";
  String itemColor = "";

  @override
  void onReady() {
    super.onReady();

    if (isCreate == false) {
      dataMap.bindStream(appController.db
          .collection('notes')
          .doc(noteId)
          .collection('items')
          .doc(docId)
          .snapshots()
          .map(dataStream));
    }
  }

  Future removeItem() async {
    currentItemMap['isDeleted'] = true;
    await appController.db
        .collection('notes')
        .doc(noteId)
        .collection('items')
        .doc(docId)
        .set(currentItemMap, SetOptions(merge: true))
        .then((value) {
      Get.back();
      Get.back();
    });
  }

  @override
  void onInit() async {
    super.onInit();
    print('do something');
    try {
      noteId = Get.parameters['noteId']!;
      docId = Get.parameters['docId']!;
    } catch (e) {
      isCreate = true;
      print(e);
    }

    ever(colSetting, finishInitSetting);

    colSetting.bindStream(appController.db
        .collection("notes")
        .doc(noteId)
        .snapshots()
        .map(snapshotSetting));
    // bool isLoading = true;
    // while (isLoading) {
    //   Future.delayed(const Duration(seconds: 1));
    //   print(colSetting.toString());
    //   if (colSetting.isNotEmpty) {
    //     isLoading = false;
    //   }
    // }
  }

  void finishInitSetting(List<Field> f) {
    print("Finish: ${f.length}");
    if (f.isNotEmpty) {
      translateField();
      createDateValue();

      for (var e in fieldSetting) {
        final controller = TextEditingController();
        ctrlList.add(controller);
        final focusNode = FocusNode();
        focusList.add(focusNode);
      }
    }
  }

  List<Field> snapshotSetting(DocumentSnapshot<Map<String, dynamic>> element) {
    print("Snap: ${element.data().toString()}");
    return element
            .data()?['columnSetting']
            ?.map<Field>((item) => Field.fromMap(item))
            ?.toList() ??
        [];
  }

  Map<String, dynamic> dataStream(
      DocumentSnapshot<Map<String, dynamic>> element) {
    currentItemMap = dataMap;
    if (element.data()!['color-for-textnote'] != null) {
      textColor = element.data()!['color-for-textnote'];
    }
    if (element.data()![
            'color-for-item-pleaseidontknowhowtopreventsomeonefindthiskey'] !=
        null) {
      itemColor = element.data()![
          'color-for-item-pleaseidontknowhowtopreventsomeonefindthiskey'];
    }
    for (int i = 0; i < fieldSetting.length; i++) {
      ctrlList[i].text = element.data()![fieldSetting[i].name] ?? "";
    }
    return element.data()!;
  }

  void setDate(String value, int index) {
    excluValue[index] = value;
    update();
  }

  void createDateValue() {
    for (var i in fieldSetting) {
      if (i.type == "date") {
        excluValue.add(
            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");
      }
    }
  }

  void saveItem(BuildContext context) {
    bool isFilled = true;
    for (var element in ctrlList) {
      if (element.text.trim().isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill input'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        isFilled = false;
        break;
      }
    }
    if (isFilled) {
      AddnoteitemController ctl = Get.find();
      Map<String, dynamic> itemMap = {
        "isDeleted": false,
      };
      for (var i = 0; i < ctrlList.length; i++) {
        itemMap[ctl.fieldSetting[i].name] = ctrlList[i].text;
      }
      isCreate ? saveToFirebase(itemMap) : updateToFirebase(itemMap);
    }
  }

  Future updateToFirebase(Map<String, dynamic> map) async {
    await appController.db
        .collection("notes")
        .doc(noteId)
        .collection('items')
        .doc(docId)
        .set(map, SetOptions(merge: true))
        .then((value) {
      Get.snackbar("Updated", "Data updated");
    });
  }

  Future saveToFirebase(Map<String, dynamic> map) async {
    await appController.db
        .collection("notes")
        .doc(noteId)
        .collection('items')
        .add(map)
        .then((value) => Get.back());
  }

  void translateField() {
    fieldSetting.clear();
    for (var i in colSetting) {
      String name = i.name;
      dynamic type = TextInputType.text;
      switch (i.inputType) {
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
      fieldSetting.add(FieldTranslate(name, type));
    }
  }
}
