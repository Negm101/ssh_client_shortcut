/// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:ssh_client_shortcut/models/shortcut.dart';
import 'package:ssh_client_shortcut/screens/device_list.dart';
import 'package:ssh_client_shortcut/screens/shortcut_list.dart';
import 'package:ssh_client_shortcut/services/databaseGetter.dart';

import 'screens/add_shortcut.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: DeviceList(),
    );
  }
}


