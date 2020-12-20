import 'dart:async';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ssh_client_shortcut/screens/shortcut_list.dart';
import 'package:ssh_client_shortcut/services/colors.dart';
import 'package:ssh_client_shortcut/services/database.dart';
import 'package:ssh_client_shortcut/services/databaseGetter.dart';
import 'package:ssh_client_shortcut/models/device.dart';
import 'package:ssh/ssh.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class DeviceList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeviceListState();
  }
}

class _DeviceListState extends State<DeviceList> {
  TextEditingController _nickNameController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _ipAddressController = new TextEditingController();
  RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  PanelController panelController = new PanelController();
  DataDevice dataDevice = new DataDevice();
  bool _isFabVisible = true;
  int testButtonStatus = 0;

  @override
  Widget build(BuildContext context) {
    const Radius radius = Radius.circular(50);
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    dataDevice.autoRefresh(setState);
    return ColorfulSafeArea(
      color: secColor.withOpacity(0.8),
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Stack(
          //alignment: Alignment.topCenter,
          children: [
            getDeviceCutList(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: deviceHeight / 12,
                  //width: deviceWidth,
                  decoration: BoxDecoration(
                    color: secColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: radius, bottomRight: radius),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Center(
                      child: Text(
                    'My Devices',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[350]),
                  )),
                ),
                SlidingUpPanel(
                  controller: panelController,
                  onPanelClosed: () {
                    FocusScope.of(context).unfocus();
                    clearTextControllers();
                  },
                  maxHeight: deviceHeight / 2,
                  borderRadius:
                      BorderRadius.only(topLeft: radius, topRight: radius),
                  panel: textFields(context),
                  color: secColor,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget slidingPanelHeader() {
    return Center(
        child: Text(
      'Add Device',
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[350]),
    ));
  }

  Widget getDeviceCutList() {
    if (dataDevice.deviceList.length == 0) {
      //panelController.animatePanelToPosition(1);
      return Center(
        child: Text(
          'NOTHING HERE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: dataDevice.deviceList.length,
        itemBuilder: (BuildContext context, position) {
          position = position;
          dataDevice.updateListView(setState);
          Color textColor = Colors.grey[150];
          return Column(
            children: [
              Card(
                color: backColor,
                margin: getTopMargin(position),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.adjust_outlined,
                    size: 46,
                    color: textColor,
                  ),
                  title: Text(
                    dataDevice.deviceList[position].nickName,
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    '${dataDevice.deviceList[position].userName}@${dataDevice.deviceList[position].ipAddress}',
                    style: TextStyle(color: textColor),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: textColor,
                    ),
                    onPressed: () {
                      _showDialog(position);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShortcutList(
                                id: dataDevice.deviceList[position].id,
                                userName:
                                    dataDevice.deviceList[position].userName,
                                ipAddress:
                                    dataDevice.deviceList[position].ipAddress,
                                password:
                                    dataDevice.deviceList[position].password,
                              )),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  EdgeInsets getTopMargin(int index) {
    if (index == 0) {
      return EdgeInsets.fromLTRB(18, 100, 18, 5);
    }
    return EdgeInsets.fromLTRB(18, 5, 18, 5);
  }

  Widget getTestButton() {
    if (testButtonStatus == 0) {
      return Center(
        child: Text(
          "Test",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    if (testButtonStatus == 1) {
      return Center(
          child: SizedBox(
              width: 21, height: 21, child: CircularProgressIndicator()));
    }
    if (testButtonStatus == 2) {
      return Center(
        child: Icon(Icons.check),
      );
    }
    if (testButtonStatus == -1) {
      return Center(
        child: Icon(Icons.close),
      );
    }
  }

  Widget textFields(BuildContext context) {
    const Radius radius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 8,
                    margin: EdgeInsets.only(bottom: 16),
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                  slidingPanelHeader()
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: new TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nick Name",
                    counterText: '',
                  ),
                  autocorrect: false,
                  controller: _nickNameController,
                  onChanged: (String value) {
                    //setNickName(device);
                  },
                ),
              ),
              Container(
                child: new TextFormField(
                  decoration: const InputDecoration(
                    labelText: "User Name",
                    counterText: '',
                  ),
                  autocorrect: false,
                  controller: _userNameController,
                  onChanged: (String value) {
                    //setUserName(device);
                  },
                ),
              ),
              Container(
                child: new TextFormField(
                  decoration: const InputDecoration(
                    labelText: "IP Address",
                    counterText: '',
                  ),
                  autocorrect: false,
                  controller: _ipAddressController,
                  onChanged: (String value) {
                    //setIpAddress(device);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: new TextField(
                  decoration: const InputDecoration(
                      labelText: "Password", errorMaxLines: 1),
                  autocorrect: false,
                  obscureText: true,
                  controller: _passwordController,
                  onChanged: (String value) {
                    //setPassword(device);
                  },
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                    minWidth: MediaQuery.of(context).size.width / 2.6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity(horizontal: 4, vertical: 4),
                    color: backColor,
                    onPressed: () {
                      save();
                      dataDevice.updateListView(setState);
                      setState(() {
                        panelController.close();
                      });
                    },
                    child: Center(
                      child: Text(
                        "Save",
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                FlatButton(
                    minWidth: MediaQuery.of(context).size.width / 2.6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity(horizontal: 4, vertical: 4),
                    color: backColor,
                    onPressed: () async {
                      setState(() {
                        testButtonStatus = 0;
                        testButtonStatus = 1;
                      });
                      var client = new SSHClient(
                        host: _ipAddressController.text,
                        port: 22,
                        username: _userNameController.text,
                        passwordOrKey: _passwordController.text,
                      );


                      try {
                        String result = await client.connect();
                        if (result == "session_connected") {
                          setState(() {
                            testButtonStatus = 2;
                          });
                        }
                      } on PlatformException catch (e) {
                        testButtonStatus = -1;
                        print('Error: ${e.code}\nError Message: ${e.message}');
                      }

                    },
                    child: getTestButton()),
              ],
            ),
          )
        ],
      ),
    );
  }

  void save() async {
    Device device = new Device.noId(
        _nickNameController.text,
        _userNameController.text,
        _passwordController.text,
        _ipAddressController.text);
    await databaseHelper.insertDevice(device);
    setState(() {
      testButtonStatus = 0;
    });
    print("saved");
  }

  void clearTextControllers() {
    _nickNameController.clear();
    _userNameController.clear();
    _passwordController.clear();
    _ipAddressController.clear();
  }

  void _showDialog(int position) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: secColor,
          title: new Text(
            "Are You Sure",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: new Text(
            "This will delete the device and its commands",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                style: TextStyle(color: Colors.grey[100]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Delete",
                style: TextStyle(color: Colors.red[300]),
              ),
              onPressed: () {
                _delete(position);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.success();
    });
  }

  void _delete(int position) {
    dataDevice.delete(context, dataDevice.deviceList[position], setState);
    dataDevice.deviceList.removeAt(position);
  }
}

/*

*/
