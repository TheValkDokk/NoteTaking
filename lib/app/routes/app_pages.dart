// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/AddNote/bindings/add_note_binding.dart';
import '../modules/AddNote/views/add_note_view.dart';
import '../modules/NoteItemDetail/bindings/note_item_detail_binding.dart';
import '../modules/NoteItemDetail/views/note_item_detail_view.dart';
import '../modules/addnoteitem/bindings/addnoteitem_binding.dart';
import '../modules/addnoteitem/views/addnoteitem_view.dart';
import '../modules/colorpicker/bindings/colorpicker_binding.dart';
import '../modules/colorpicker/views/colorpicker_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/note/bindings/note_binding.dart';
import '../modules/note/views/note_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NOTE,
      page: () => const NoteView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: _Paths.ADDNOTEITEM,
      page: () => const AddnoteitemView(),
      binding: AddnoteitemBinding(),
    ),
    GetPage(
      name: _Paths.NOTE_ITEM_DETAIL,
      page: () => const NoteItemDetailView(),
      binding: NoteItemDetailBinding(),
    ),
    GetPage(
      name: _Paths.COLORPICKER,
      page: () => const ColorpickerView(),
      binding: ColorpickerBinding(),
    ),
    GetPage(
      name: _Paths.ADD_NOTE,
      page: () => const AddNoteView(),
      binding: AddNoteBinding(),
    ),
  ];
}
