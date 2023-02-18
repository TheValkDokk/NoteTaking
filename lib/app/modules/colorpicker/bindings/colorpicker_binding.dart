import 'package:get/get.dart';

import '../controllers/colorpicker_controller.dart';

class ColorpickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ColorpickerController>(
      () => ColorpickerController(),
    );
  }
}
