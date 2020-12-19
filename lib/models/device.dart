class Device {
  final String tableName = "device";
  final String dbId = "id";
  final String dbNickName = "nick_name";
  final String dbUserName = "user_name";
  final String dbPassword = "password";
  final String dbIpAddress = "ip_address";

  int id;
  String nickName;
  String userName;
  String password;
  String ipAddress;


  Device.db();
  Device(this.id, this.nickName, this.userName, this.password);
  Device.noId(this.nickName, this.userName, this.password);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map[dbNickName] = nickName;
    map[dbUserName] = userName;
    map[dbPassword] = password;
    map[dbIpAddress] = ipAddress;
    return map;
  }

  // Extract a Note object from a Map object
  Device.fromMapObject(Map<String, dynamic> map) {
    this.id = map[dbId];
    this.nickName = map[dbNickName];
    this.userName = map[dbUserName];
    this.password = map[dbPassword];
    this.ipAddress = map[dbIpAddress];
  }
}
