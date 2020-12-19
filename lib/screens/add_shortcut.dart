import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssh_client_shortcut/models/shortcut.dart';

import '../services/database.dart';


class AddShortcut extends StatefulWidget {
  final Shortcut shortcut;

  AddShortcut(this.shortcut);

  @override
  State<StatefulWidget> createState() {
    return _AddShortcutState(this.shortcut);
  }
}

class _AddShortcutState extends State<AddShortcut> {
  _AddShortcutState(this.shortcut);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _commandController = new TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  Shortcut shortcut;

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
                        labelText: "Name",
                        counterText: '',
                      ),
                      autocorrect: false,
                      controller: _nameController,
                      onChanged: (String value) {
                        setName();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: new TextField(
                      decoration: const InputDecoration(
                          labelText: "Command",
                          hintText: 'type command here',
                          errorMaxLines: 1),
                      autocorrect: false,
                      maxLength: 32,
                      controller: _commandController,
                      onChanged: (String value) {
                        setNote();
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
  void setName(){
    shortcut.name = _nameController.text;
  }
  void setNote(){
    shortcut.command = _commandController.text;
  }
  void _save() async {
    if(_formKey.currentState.validate()){
      await databaseHelper.insertShortcut(shortcut);
      _print();
      Navigator.pop(context);
    }
    else {
      debugPrint('error');
    }
  }
  void _print(){
    debugPrint("name: " + shortcut.name + "\ncommand" + shortcut.command + "\ndeviceId: " + shortcut.deviceId.toString());
  }
}