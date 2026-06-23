import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'package:byxex_match/core/services/byxex_push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await ByxexPushService().init();
  runApp(const ByxexMatchApp());
}
