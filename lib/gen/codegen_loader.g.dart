// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _en_US = {
  "typeAMessage": "Type a message...",
  "helloUser": "Hello, user.",
  "howCanIHelp": "How can I help you today?",
  "whatDoYouWantToKnow": "What do you want to know?",
  "deepSearch": "DeepSearch",
  "think": "Think",
  "research": "Research",
  "howTo": "How to",
  "analyze": "Analyze",
  "createImages": "Create images",
  "code": "Code"
};
static const Map<String,dynamic> _vi_VN = {
  "typeAMessage": "Nhập tin nhắn...",
  "helloUser": "Xin chào, người dùng.",
  "howCanIHelp": "Tôi có thể giúp gì cho bạn hôm nay?",
  "whatDoYouWantToKnow": "Bạn muốn biết gì?",
  "deepSearch": "Tìm kiếm sâu",
  "think": "Suy nghĩ",
  "research": "Nghiên cứu",
  "howTo": "Làm thế nào để",
  "analyze": "Phân tích",
  "createImages": "Tạo hình ảnh",
  "code": "Mã"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en_US": _en_US, "vi_VN": _vi_VN};
}
