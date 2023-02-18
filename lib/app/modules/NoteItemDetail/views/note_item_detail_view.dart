import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/note_item_detail_controller.dart';

class NoteItemDetailView extends GetView<NoteItemDetailController> {
  const NoteItemDetailView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteItemDetailView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NoteItemDetailView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
