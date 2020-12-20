import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ssh/ssh.dart';
import 'package:ssh_client_shortcut/services/colors.dart';
import 'package:ssh_client_shortcut/services/database.dart';
import 'package:ssh_client_shortcut/services/databaseGetter.dart';
import '../models/shortcut.dart';

class ShortcutList extends StatefulWidget {
  final int id;
  final String userName;
  final String password;
  final String ipAddress;

  ShortcutList({
    @required this.id,
    @required this.userName,
    @required this.password,
    @required this.ipAddress,
  });

  @override
  State<StatefulWidget> createState() {
    return _ShortcutListState();
  }
}

class _ShortcutListState extends State<ShortcutList> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _commandController = new TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  DataShortcut dataShortcut = new DataShortcut();
  String _result = '';
  List _array;

  @override
  Widget build(BuildContext context) {
    dataShortcut.autoRefresh(setState, widget.id);
    const Radius radius = Radius.circular(50);
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return ColorfulSafeArea(
      color: secColor.withOpacity(0.8),
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Stack(
          children: [
            getShortCutList(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: deviceHeight / 12,
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
                        '${widget.userName}@${widget.ipAddress}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[350]),
                      )),
                ),
                SlidingUpPanel(
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

  Widget getShortCutList() {
    if (dataShortcut.shortcutList.length == 0) {
      return Center(
        child: Text(
          'NOTHING HERE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: dataShortcut.shortcutList.length,
        itemBuilder: (BuildContext context, position) {
          position = position;
          dataShortcut.updateListView(setState, widget.id);
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
                  contentPadding: EdgeInsets.all(10),
                  title: Text(dataShortcut.shortcutList[position].name, style: TextStyle(color: textColor),),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: textColor,),
                    onPressed: () {
                      setState(() {
                        _delete(position);

                      });
                    },
                  ),
                  onTap: () {
                    onClickCommand(dataShortcut.shortcutList[position].command);
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }
  Future<void> onClickCommand(String command) async {
    var client = new SSHClient(
      host: widget.ipAddress,
      port: 22,
      username: widget.userName,
      passwordOrKey: widget.password,
    );
    setState(() {
      _result = "";
      _array = null;
    });

    try {
      String result = await client.connect();
      if (result == "session_connected") {
        result = await client.startShell(
            ptyType: "xterm",
            callback: (dynamic res) {
              setState(() {
                _result += res;
              });
            });

        if (result == "shell_started") {
          //print(await client.writeToShell("export DISPLAY=:1\n"));
          print(await client.writeToShell("$command \n"));
          new Future.delayed(
            const Duration(seconds: 5),
                () async => await client.closeShell(),
          );
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    print(_result);
    print(_array);
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
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: new TextFormField(
                  decoration: const InputDecoration(

                    labelText: "Name",
                    counterText: '',
                  ),
                  autocorrect: false,
                  controller: _nameController,
                ),
              ),
              TextField(
                maxLines: 8,
                controller: _commandController,
                decoration: InputDecoration(
                  hintText: "Command",
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: backColor,
              borderRadius: BorderRadius.all(radius),
            ),
            child: FlatButton(
              //color: backColor,
                onPressed: () {
                  save();
                },
                child: Center(
                  child: Text("Save"),
                )),
          )
        ],
      ),
    );
  }
  void save() async {
    Shortcut shortcut = new Shortcut.noId(_nameController.text, _commandController.text, widget.id);
    await databaseHelper.insertShortcut(shortcut);
    print("saved");
  }

  void clearTextControllers() {
    _nameController.clear();
    _commandController.clear();
  }

  Widget slidingPanelHeader() {
    return Center(
        child: Text(
          'Add Shortcut',
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[350]),
        ));
  }

  EdgeInsets getTopMargin(int index) {
    if (index == 0) {
      return EdgeInsets.fromLTRB(18, 100, 18, 5);
    }
    return EdgeInsets.fromLTRB(18, 5, 18, 5);
  }
  void _delete(int position){
    dataShortcut.delete(
        context,
        dataShortcut.shortcutList[position],
        setState,
        widget.id);
    dataShortcut.shortcutList.removeAt(position);
  }

}