class Shortcut {
  final String tableName = "shortcut";
  final String dbId = "id";
  final String dbName = "name";
  final String dbCommand = "command";
  final String dbDeviceId = "device_id";

  int id;
  String name;
  String command;
  int deviceId;
  
  Shortcut.db();
  Shortcut(this.id, this.name, this.command, this.deviceId);
  Shortcut.noId(this.name, this.command, this.deviceId);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map[dbName] = name;
    map[dbCommand] = command;
    map[dbDeviceId] = deviceId;
    return map;
  }

  // Extract a Note object from a Map object
  Shortcut.fromMapObject(Map<String, dynamic> map) {
    this.id = map[dbId];
    this.name = map[dbName];
    this.command = map[dbCommand];
    this.deviceId = map[dbDeviceId];
  }
}
