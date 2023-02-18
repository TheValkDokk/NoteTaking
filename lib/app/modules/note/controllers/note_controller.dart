import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:notetaking/app/data/inputfield.dart';
import 'package:notetaking/static.dart';

class NoteController extends GetxController {
  String docId = "";
  String docLabel = "";

  RxList<Field> colSetting = <Field>[].obs;
  RxBool showTitle = false.obs;

  RxString searchValue = "".obs;
  RxString searchItem = "".obs;
  RxBool isSearch = false.obs;

  RxInt gridItemCount = 3.obs;

  @override
  void onInit() {
    super.onInit();
    docId = Get.parameters['docId']!;
    docLabel = Get.parameters['label']!;
    colSetting.bindStream(appController.db
        .collection("notes")
        .doc(docId)
        .snapshots()
        .map(snapshotSetting));
    showTitle.bindStream(appController.db
        .collection("notes")
        .doc(docId)
        .snapshots()
        .map(snapshotBool));
    if (GetPlatform.isWeb) {
      gridItemCount.bindStream(appController.db
          .collection("notes")
          .doc(docId)
          .snapshots()
          .map(snapshotGridCount));
    }
  }

  void setGridCount(int i) async {
    await appController.db.collection('notes').doc(docId).set({
      'gridCount': i,
    }, SetOptions(merge: true));
  }

  bool snapshotBool(DocumentSnapshot<Map<String, dynamic>> element) {
    return element.data()?['showTitle'];
  }

  int snapshotGridCount(DocumentSnapshot<Map<String, dynamic>> element) {
    return element.data()?['gridCount'];
  }

  List<Field> snapshotSetting(DocumentSnapshot<Map<String, dynamic>> element) {
    return element
            .data()?['columnSetting']
            ?.map<Field>((item) => Field.fromMap(item))
            ?.toList() ??
        [];
  }

  bool isPhoneNumber(String input) {
    // Remove any non-digit characters from the input
    String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if the resulting string is 10 or 11 digits long
    return digitsOnly.length == 10 || digitsOnly.length == 11;
  }

  void toggleShowTitle() async {
    await appController.db
        .collection('notes')
        .doc(docId)
        .set({'showTitle': !showTitle.value}, SetOptions(merge: true));
  }

  void optionMenu(String option) {
    switch (option) {
      case "toggleTitle":
        toggleShowTitle();
        break;
      default:
    }
  }

  Future removeItem(String itemId) async {
    await appController.db
        .collection('notes')
        .doc(docId)
        .collection('items')
        .doc(itemId)
        .set({"isDeleted": true}, SetOptions(merge: true)).then((value) {
      Get.back();
    });
  }
}
