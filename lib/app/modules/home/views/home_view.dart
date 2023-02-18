import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notetaking/app/controller/app_controller.dart';
import 'package:notetaking/app/data/ads.dart';
import 'package:notetaking/static.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    if (GetPlatform.isAndroid) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd.load();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final notesQuery = FirebaseFirestore.instance
        .collection('notes')
        .where("createdBy", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .where(
          'isDeleted',
          isEqualTo: false,
        );
    appController.isDark.value = Get.isDarkMode;
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ProfileScreen(
            providers: [
              appController.googleProvider,
            ],
            actions: [
              SignedOutAction((context) {
                Get.toNamed('/login');
              }),
            ],
            children: [
              GetX<AppController>(
                builder: (controller) => ListTile(
                  leading: Icon(appController.isDark.value
                      ? Icons.light_mode
                      : Icons.dark_mode_outlined),
                  title: Text(appController.isDark.value
                      ? "Switch to Light Mode"
                      : "Switch to Dark Mode"),
                  onTap: () {
                    Get.changeThemeMode(
                        Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                    appController.isDark.value = !Get.isDarkMode;
                  },
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/add-note'),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FirestoreListView<Map<String, dynamic>>(
                query: notesQuery,
                itemBuilder: (context, snapshot) {
                  Map<String, dynamic> notes = snapshot.data();
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Get.isDarkMode
                                  ? context.theme.indicatorColor
                                  : context.theme.primaryColor)),
                      child: ListTile(
                        title: Text(
                          notes['label'],
                          style: const TextStyle(fontSize: 25),
                        ),
                        leading: const Icon(Icons.note),
                        onTap: () {
                          Get.toNamed('/note', parameters: {
                            "docId": snapshot.id,
                            "label": notes['label'],
                          });
                        },
                        onLongPress: () {
                          Get.defaultDialog(
                            middleText:
                                "You sure you want to delete this Note?",
                            title: "Delete",
                            onConfirm: () {
                              appController.db
                                  .collection('notes')
                                  .doc(snapshot.id)
                                  .update({"isDeleted": true}).then(
                                      (value) => Get.back());
                            },
                            onCancel: () {},
                          );
                        },
                        // subtitle: Text(notes['createdAt']),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
