import 'package:get/get.dart';

import '../controllers/note_item_detail_controller.dart';

class NoteItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteItemDetailController>(
      () => NoteItemDetailController(),
    );
  }
}
