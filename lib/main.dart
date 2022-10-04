// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_reminder/notifications.dart';
import 'package:flutter_reminder/screens/home_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var launchDetails = Notifications.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String? payload;
  const MyApp({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ADHD Reminder',
        home: Scaffold(
          appBar: HomeScreenAppBar(),
          body: HomeScreen(payload: payload),
        )
    );
  }
}

class HomeScreenAppBar extends StatelessWidget with PreferredSizeWidget {
  const HomeScreenAppBar({Key? key}) : super(key: key);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      title: const Text("ADHD Reminder"),
      actions: [
        IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => {}, // TODO: Open settings screen.
            tooltip: "Menu"
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
