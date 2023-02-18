import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:notetaking/app/modules/AddNote/controllers/add_note_controller.dart';
import 'package:notetaking/app/modules/home/views/widgets/input.dart';
import 'package:slide_switcher/slide_switcher.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({Key? key}) : super(key: key);

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final FocusNode noteFocus = FocusNode();

  AddNoteController addNoteController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: addNoteController.isEdit
            ? const Text("Edit Note Setting")
            : const Text('Add Note'),
      ),
      body: Column(
        children: [
          Input(
            inputController: addNoteController.noteCtl,
            title: addNoteController.isEdit ? null : "Note Label",
            hint: addNoteController.isEdit ? "Note Label" : null,
            focus: noteFocus,
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: addNoteController.textControllers.value.length,
                itemBuilder: (context, index) {
                  final controller = addNoteController.textControllers[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Input(
                                inputController: controller,
                                title: addNoteController.isEdit
                                    ? null
                                    : "Column Name: ${index + 1}",
                                hint: addNoteController.isEdit
                                    ? addNoteController.fields[index].name
                                    : null,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                addNoteController.removeTextField(index);
                              },
                              icon: const Icon(Icons.delete_forever_sharp),
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SlideSwitcher(
                          initialIndex:
                              addNoteController.fieldIndexList.isNotEmpty
                                  ? addNoteController.fieldIndexList[index]
                                  : 0,
                          onSelect: (i) =>
                              addNoteController.onFieldChanged(i, index),
                          containerHeight: Get.height * .05,
                          containerWight: Get.width * .9,
                          containerColor: context.theme.highlightColor,
                          slidersColors: [context.theme.secondaryHeaderColor],
                          children: addNoteController.availableFields
                              .map((e) => Text(e.name))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNoteController.addTextField,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: () => addNoteController.saveNote(context, noteFocus),
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }
}
