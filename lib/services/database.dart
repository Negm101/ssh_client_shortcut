import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:ssh_client_shortcut/models/device.dart';
import 'package:ssh_client_shortcut/models/shortcut.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  Shortcut shortcut = Shortcut.db();
  Device device = Device.db();

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'LOG';

    var sshDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    return sshDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
    """
    create table ${shortcut.tableName}( 
              ${shortcut.dbId} integer primary key autoincrement,
              ${shortcut.dbName} varchar(26),
              ${shortcut.dbCommand} text,
              ${shortcut.dbDeviceId} int
    );
    """
    );
    
    await db.execute(
    """
    create table ${device.tableName}( 
              ${device.dbId} integer primary key autoincrement,
              ${device.dbNickName} varchar(26),
              ${device.dbUserName} text,
              ${device.dbPassword} text,
              ${device.dbIpAddress} text
    );
    """
    );
  }

  Future<List<Map<String, dynamic>>> getShortcutMapList() async {
    Database db = await this.database;
    var result = await db.query(shortcut.tableName, orderBy: '${shortcut.dbId} ASC');
    return result;
  }
  Future<List<Map<String, dynamic>>> getDeviceMapList() async {
    Database db = await this.database;
    var result = await db.query(device.tableName, orderBy: '${device.dbId} ASC');
    return result;
  }
  
  Future<int> insertShortcut(Shortcut shortcut) async {
    Database db = await this.database;
    var result = await db.insert(shortcut.tableName, shortcut.toMap());
    return result;
  }
  Future<int> insertDevice(Device device) async {
    Database db = await this.database;
    var result = await db.insert(device.tableName, device.toMap());
    return result;
  }

  Future<int> updateShortcut(Shortcut shortcut) async{
    var db = await this.database;
    var result = await db.update(shortcut.tableName, shortcut.toMap(), where: '${shortcut.dbId} = ?', whereArgs: [shortcut.id]);
    return result;
  }
  Future<int> updateDevice(Device device) async{
    var db = await this.database;
    var result = await db.update(device.tableName, device.toMap(), where: '${device.dbId} = ?', whereArgs: [device.id]);
    return result;
  }


  Future<int> deleteShortcut(int id) async {
    var db  = await this.database;
    var result = await db.rawDelete('DELETE FROM ${shortcut.tableName} WHERE ${shortcut.dbId} = $id');
    return result;
  }
  Future<int> deleteDevice(int id) async {
    var db  = await this.database;
    var result = await db.rawDelete('DELETE FROM ${device.tableName} WHERE ${device.dbId} = $id');
    return result;
  }

  Future<int> getCountShortcut() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from ${shortcut.tableName}');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
  Future<int> getCountDevice() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from ${device.tableName}');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<List<Shortcut>> getShortcutList(int deviceId) async {
    Database db = await this.database;
    var shortcutMapList = await db.query(shortcut.tableName, orderBy: '${shortcut.dbId} ASC', where: '${shortcut.dbDeviceId} = ?', whereArgs: [deviceId]); // Get 'Map List' from database
    int count = shortcutMapList.length;         // Count the number of map entries in db table

    List<Shortcut> shortcutList = List<Shortcut>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      shortcutList.add(Shortcut.fromMapObject(shortcutMapList[i]));
    }

    return shortcutList;
  }
  Future<List<Device>> getDeviceList() async {
    Database db = await this.database;
    var deviceMapList = await db.query(device.tableName, orderBy: '${device.dbId} ASC'); // Get 'Map List' from database
    int count = deviceMapList.length;         // Count the number of map entries in db table

    List<Device> deviceList = List<Device>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      deviceList.add(Device.fromMapObject(deviceMapList[i]));
    }

    return deviceList;
  }
}