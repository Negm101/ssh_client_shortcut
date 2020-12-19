import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssh_client_shortcut/models/device.dart';
import 'package:ssh_client_shortcut/models/shortcut.dart';

import '../services/database.dart';



class AddDevice extends StatefulWidget {
  final Device device;

  AddDevice(this.device);

  @override
  State<StatefulWidget> createState() {
    return _AddDeviceState(this.device);
  }
}

class _AddDeviceState extends State<AddDevice> {
  _AddDeviceState(this.device);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _nickNameController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _ipAddressController = new TextEditingController();
  int _state = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  Device device;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: Text(
            'Add Score (real)',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
            )
          ]),
      body: body(),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.blue,
          child: FlatButton(
            child: Text(
              'ADD',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                _save();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget body() {
    return new Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: getWidthSize(0.05), right: getWidthSize(0.05)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Nick Name",
                        counterText: '',
                      ),
                      autocorrect: false,
                      controller: _nickNameController,
                      onChanged: (String value) {
                        setNickName();
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
                        setUserName();
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
                        setIpAddress();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: new TextField(
                      decoration: const InputDecoration(
                          labelText: "Password",
                          errorMaxLines: 1),
                      autocorrect: false,
                      obscureText: true,
                      controller: _passwordController,
                      onChanged: (String value) {
                        setPassword();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  double getWidthSize(double factor) {
    return MediaQuery.of(context).size.width * factor;
  }

  double getHeightSize(double factor) {
    return MediaQuery.of(context).size.height * factor;
  }
  void setNickName(){
    device.nickName = _nickNameController.text;
  }
  void setPassword(){
    device.password = _passwordController.text;
  }
  void setUserName(){
  device.userName =  _userNameController.text;
  }
  void setIpAddress(){
    device.ipAddress =  _ipAddressController.text;
  }
  void _save() async {
    if(_formKey.currentState.validate()){
      await databaseHelper.insertDevice(device);
      Navigator.pop(context);
    }
    else {
      debugPrint('error');
    }
  }

}



