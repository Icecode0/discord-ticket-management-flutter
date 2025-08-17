import 'package:flutter/material.dart';
import 'package:newdawn/login.dart';
import 'package:newdawn/dashboard.dart';
import "package:newdawn/globals.dart" as globals;
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();

  runApp(
    MaterialApp.router(
      routerConfig: globals.router,
    ),
  );
}