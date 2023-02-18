import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconswitcher/iconswitcher.dart';
import 'package:motion/motion.dart';

import '../controllers/colorpicker_controller.dart';

class ColorpickerView extends GetView<ColorpickerController> {
  const ColorpickerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Color'),
        centerTitle: true,
        actions: [
          IconSwitcher(
            backgroundColor: context.theme.hintColor,
            icon1: Icons.image,
            icon2: Icons.text_fields_sharp,
            color1: controller.itemColor.value,
            color2: controller.textColor.value,
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 50,
            marginTop: 0,
            onChange: (v) {
              controller.curSelect.value = v;
            },
          )
        ],
      ),
      body: Column(
        children: [
          ColorPicker(
            pickersEnabled: const {
              ColorPickerType.wheel: true,
              ColorPickerType.accent: false,
            },
            color: controller.itemColor.value,
            onColorChanged: (value) {
              controller.curSelect.value
                  ? controller.itemColor.value = value
                  : controller.textColor.value = value;
            },
            wheelDiameter: Get.height * .4,
          ),
          Expanded(
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.all(30),
                child: Motion(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: controller.itemColor.value,
                    ),
                    width: Get.width * .8,
                    height: Get.height * .4,
                    child: Center(
                      child: Text(
                        "Example Text",
                        style: TextStyle(
                          color: controller.textColor.value,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: () {
              controller.saveToFireBase();
            },
            child: const Text("Save"),
          ),
        ),
      ),
    );
  }
}
