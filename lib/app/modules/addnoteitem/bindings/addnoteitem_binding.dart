import 'package:get/get.dart';

import '../controllers/addnoteitem_controller.dart';

class AddnoteitemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddnoteitemController>(
      () => AddnoteitemController(),
    );
  }
}
