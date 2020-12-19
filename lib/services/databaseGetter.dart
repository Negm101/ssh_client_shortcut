import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssh_client_shortcut/models/shortcut.dart';
import 'database.dart';
import '../models/device.dart';


class DataShortcut {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Shortcut title = new Shortcut.db();
  List<Shortcut> shortcutList;
  int count = 0;
  
  void autoRefresh(Function setState, int deviceId) {
    if (shortcutList == null) {
      shortcutList = List<Shortcut>();
      updateListView(setState, deviceId);
    }
  }
  
  // when calling this function wrap it in a setState
  void updateListView(Function setState, int deviceId) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Shortcut>> shortcutListFuture = databaseHelper.getShortcutList(deviceId);
      shortcutListFuture.then((shortcutList) {
        setState(() {
          this.shortcutList = shortcutList;
          this.count = shortcutList.length;
        });
      });
    });
  }

  void delete(BuildContext context, Shortcut score, Function setState, int deviceId) async {
    int result = await databaseHelper.deleteShortcut(score.id);
    if (result != 0) {
      updateListView(setState, deviceId);
    }
  }

/*void deleteAll(Function setState) async{
    int result = await databaseHelper.deleteAllFrom(title.dbTableName);
    if (result != 0) {
      updateListView(setState);
    }
  }*/

/*void updateListViewSortBy(Function setState, String sortBy) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Shortcut>> noteListFuture = databaseHelper.getScoreIListRealSortBy(sortBy);
      noteListFuture.then((scoreIList) {
        setState(() {
          this.scoreList = scoreIList;
          this.count = scoreIList.length;
        });
      });
    });
  }*/
}

class DataDevice {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Device title = new Device.db();
  List<Device> deviceList;
  int count = 0;

  void autoRefresh(Function setState) {
    if (deviceList == null) {
      deviceList = List<Device>();
      updateListView(setState);
    }
  }

  void updateListView(Function setState) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Device>> deviceListFuture = databaseHelper.getDeviceList();
      deviceListFuture.then((deviceList) {
        setState(() {
          this.deviceList = deviceList;
          this.count = deviceList.length;
        });
      });
    });
  }

  void delete(BuildContext context, Device device, Function setState) async {
    int result = await databaseHelper.deleteDevice(device.id);
    if (result != 0) {
      updateListView(setState);
    }
  }
}
