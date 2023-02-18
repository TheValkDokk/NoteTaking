import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_ui/animated_firestore_grid.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:notetaking/app/modules/home/views/widgets/input.dart';
import 'package:notetaking/app/modules/note/views/widget/fab.dart';
import 'package:notetaking/static.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/note_controller.dart';

class NoteView extends GetView<NoteController> {
  const NoteView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final String docId = controller.docId;
    final String label = controller.docLabel;
    final docItems = appController.db
        .collection('notes')
        .doc(docId)
        .collection('items')
        .where("isDeleted", isEqualTo: false);
    final TextEditingController txt = TextEditingController();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Get.height * .1),
        child: NoteAppbar(controller: controller, txt: txt, label: label),
      ),
      body: Obx(
        () {
          bool showTitle = controller.showTitle.value;
          String searchItem = controller.searchItem.value;
          String searchValue = controller.searchValue.value;
          if (GetPlatform.isAndroid) {
            return FirestoreAnimatedList(
              query: docItems,
              itemBuilder: (
                context,
                snapshot,
                animation,
                index,
              ) {
                if ((searchValue.isNotEmpty && searchItem.isNotEmpty)) {
                  try {
                    if ((snapshot!.data()![searchItem] as String)
                        .toLowerCase()
                        .contains(searchValue.toLowerCase())) {
                      return FadeTransition(
                        opacity: animation,
                        child: itemRender(snapshot, showTitle, context, docId),
                      );
                    } else {
                      return Container();
                    }
                  } catch (e) {
                    return Container();
                  }
                } else {
                  return FadeTransition(
                    opacity: animation,
                    child: itemRender(snapshot!, showTitle, context, docId),
                  );
                }
              },
            );
          } else {
            return FirestoreAnimatedGrid(
              query: docItems,
              crossAxisCount: controller.gridItemCount.value,
              mainAxisSpacing: 1,
              childAspectRatio: 1,
              crossAxisSpacing: 4.0,
              itemBuilder: (
                context,
                snapshot,
                animation,
                index,
              ) {
                if ((searchValue.isNotEmpty && searchItem.isNotEmpty)) {
                  try {
                    if ((snapshot!.data()![searchItem] as String)
                        .toLowerCase()
                        .contains(searchValue.toLowerCase())) {
                      return FadeTransition(
                        opacity: animation,
                        child: itemRender(snapshot, showTitle, context, docId),
                      );
                    } else {
                      return FadeTransition(
                        opacity: animation,
                        child: Opacity(
                            opacity: .2,
                            child: itemRender(
                                snapshot, showTitle, context, docId)),
                      );
                    }
                  } catch (e) {
                    return Container();
                  }
                } else {
                  return FadeTransition(
                    opacity: animation,
                    child: itemRender(snapshot!, showTitle, context, docId),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: ExpandableFab(
        distance: 100,
        children: [
          ActionButton(
            onPressed: () => Get.toNamed('/addnoteitem', parameters: {
              'noteId': docId,
            }),
            icon: const Icon(Icons.add),
          ),
          ActionButton(
            onPressed: () {
              // Get.put(AddNoteController());
              Get.toNamed('/add-note', parameters: {"docId": docId});
            },
            icon: const Icon(Icons.add_chart_rounded),
          ),
          ActionButton(
            onPressed: () => controller.toggleShowTitle(),
            icon: const Icon(Icons.title),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.toNamed('/addnoteitem');
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget itemRender(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    bool showTitle,
    BuildContext c,
    String noteId,
  ) {
    Color? color;
    try {
      color = Color(int.parse(
          "0xFF${snapshot.data()!['color-for-item-pleaseidontknowhowtopreventsomeonefindthiskey']}"));
    } catch (e) {
      Get.log("");
    }
    return InkWell(
      onDoubleTap: GetPlatform.isWeb
          ? () async {
              Get.defaultDialog(
                title: "Open on Phone",
                middleText: "Open this on Phone?",
                onConfirm: () async {
                  await appController.db
                      .collection('commands')
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .set({
                    'cmd': '/addnoteitem?docId=${snapshot.id}&noteId=$noteId',
                    'isActive': true,
                  }).then((value) => Get.back());
                },
                onCancel: () {},
              );
            }
          : null,
      onLongPress: () {
        Get.defaultDialog(
          title: "Delete",
          middleText: "You sure you want to delete this?",
          onConfirm: () {
            controller.removeItem(snapshot.id);
          },
          onCancel: () {},
        );
      },
      onTap: () => Get.toNamed('/addnoteitem', parameters: {
        "docId": snapshot.id,
        "noteId": noteId,
      }),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: color,
            border: Border.all(
              color: Get.isDarkMode
                  ? Get.context!.theme.indicatorColor
                  : Get.context!.theme.primaryColor,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.colSetting.map((element) {
              Color? color;
              if (snapshot.data()!["color-for-textnote"] != null) {
                color = Color(
                    int.parse("0xFF${snapshot.data()!["color-for-textnote"]}"));
              } else {
                color = null;
              }
              return renderText(element.name, snapshot.data()![element.name],
                  showTitle, c, color);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget renderText(
      String title, String? v, bool showTitle, BuildContext c, Color? color) {
    if (v == null) {
      return Container();
    } else if (showTitle) {
      if (controller.isPhoneNumber(v)) {
        return InkWell(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$title: ', style: TextStyle(color: color)),
            TextSpan(
              text: v,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ])),
          onTap: () {
            launchUrlString('tel:$v');
          },
          onLongPress: () async {
            await Clipboard.setData(ClipboardData(text: v));
          },
        );
      }
      return SelectableText(
        "$title: $v",
        style: TextStyle(color: color),
      );
    } else {
      return SelectableText(v, style: TextStyle(color: color));
    }
  }
}

class NoteAppbar extends StatelessWidget {
  const NoteAppbar({
    super.key,
    required this.controller,
    required this.txt,
    required this.label,
  });

  final NoteController controller;
  final TextEditingController txt;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedSwitcherFlip.flipX(
        duration: const Duration(milliseconds: 500),
        child: controller.isSearch.value
            ? AppBar(
                key: UniqueKey(),
                title: Input(
                  inputController: txt,
                  onChanged: (v) {
                    controller.searchValue.value = v;
                  },
                ),
                actions: [IconSearchBtn(controller: controller)],
                leading: IconButton(
                    onPressed: () {
                      controller.isSearch.value = false;
                      controller.searchValue.value = "";
                      controller.searchItem.value = "";
                    },
                    icon: const Icon(Icons.close)),
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => Get.offAllNamed('/home'),
                ),
                key: UniqueKey(),
                title: Text(label),
                actions: [
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          controller
                              .setGridCount(controller.gridItemCount.value + 1);
                        },
                        icon: const Icon(Icons.remove)),
                    IconButton(
                        onPressed: () {
                          controller
                              .setGridCount(controller.gridItemCount.value - 1);
                        },
                        icon: const Icon(Icons.add)),
                  ]),
                  IconButton(
                    onPressed: () => controller.isSearch.value = true,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
      );
    });
  }
}

class IconSearchBtn extends StatefulWidget {
  const IconSearchBtn({
    super.key,
    required this.controller,
  });

  final NoteController controller;

  @override
  State<IconSearchBtn> createState() => _IconSearchBtnState();
}

class _IconSearchBtnState extends State<IconSearchBtn> {
  var val = "";
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: val.isNotEmpty ? val : widget.controller.colSetting[0].name,
      // Callback that sets the selected popup menu item.
      onSelected: (value) {
        widget.controller.searchItem.value = value;
        setState(() {
          val = value;
        });
      },
      itemBuilder: (BuildContext context) => widget.controller.colSetting
          .map(
            (e) => PopupMenuItem(
              value: e.name,
              child: Text(e.name),
            ),
          )
          .toList(),
    );
  }
}
