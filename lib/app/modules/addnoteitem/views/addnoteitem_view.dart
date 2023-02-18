import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:notetaking/app/data/field_translate.dart';
import 'package:notetaking/app/modules/home/views/widgets/input.dart';
import 'package:notetaking/static.dart';

import '../controllers/addnoteitem_controller.dart';

class AddnoteitemView extends GetView<AddnoteitemController> {
  const AddnoteitemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Get.previousRoute == ''
            ? IconButton(
                onPressed: () => Get.offAllNamed('/home'),
                icon: const Icon(Icons.home))
            : null,
        title: controller.isCreate
            ? const Text('Add Item')
            : const Text("Note Item"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(
              '/colorpicker',
              parameters: {
                "docId": controller.docId,
                "itemColor": controller.itemColor,
                "textColor": controller.textColor,
                "noteId": controller.noteId,
              },
            ),
            icon: const Icon(Icons.color_lens),
          ),
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Delete",
                middleText: "You sure you want to delete this?",
                onConfirm: () {
                  controller.removeItem();
                },
                onCancel: () {},
              );
            },
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.colSetting.isNotEmpty) {
              return Expanded(
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      final item = controller.fieldSetting[index];
                      return ListTile(
                        onTap: () {},
                        title: Text(item.name),
                        subtitle: renderInput(item, index),
                      );
                    },
                    itemCount: controller.fieldSetting.length),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: () {
              controller.saveItem(context);
            },
            child: controller.isCreate ? const Text('Add') : const Text("Save"),
          ),
        ),
      ),
    );
  }

  Widget renderInput(FieldTranslate item, int index) {
    switch (item.type) {
      case "money":
        return inputMoneyGenerate(controller.ctrlList[index], item,
            controller.focusList[index], index);
      case "date":
        return inputWithDate(controller.ctrlList[index], item);
      default:
        return inputGenerate(controller.ctrlList[index], item,
            controller.focusList[index], index);
    }
  }

  Widget inputGenerate(TextEditingController ctrl, FieldTranslate item,
      FocusNode focus, int index) {
    return Input(
      focus: focus,
      inputController: ctrl,
      hint: item.name,
      inputType: item.type,
      onSubmit: (p0) {
        if (index != controller.focusList.length) {
          controller.focusList[index + 1].requestFocus();
        } else {
          controller.focusList[index].unfocus();
        }
      },
    );
  }

  Widget inputMoneyGenerate(TextEditingController ctrl, FieldTranslate item,
      FocusNode focus, int index) {
    return Input(
      focus: focus,
      inputController: ctrl,
      inputType: TextInputType.number,
      hint: "Money",
      onSubmit: (p0) {
        ctrl.text = appController.convertCurrency(num.parse(ctrl.text));
        if (index != controller.focusList.length) {
          controller.focusList[index + 1].requestFocus();
        } else {
          controller.focusList[index].unfocus();
        }
      },
    );
  }

  Obx inputWithDate(TextEditingController ctrl, FieldTranslate item) {
    return Obx(() {
      if (controller.excluValueIndex == controller.excluValue.length) {
        controller.excluValueIndex = 0;
      }

      final index = controller.excluValueIndex;
      String date = controller.excluValue[index];
      ++controller.excluValueIndex;
      ctrl.text = date;
      return GestureDetector(
        onTap: () async {
          final value = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(DateTime.now().year - 50),
              lastDate: DateTime(DateTime.now().year + 50));
          controller.setDate(
              "${value!.day}/${value.month}/${value.year}", index);
        },
        child: Input(
          inputController: ctrl,
          enabled: false,
        ),
      );
    });
  }
}
