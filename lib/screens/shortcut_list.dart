import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssh/ssh.dart';
import 'package:ssh_client_shortcut/services/databaseGetter.dart';

import 'add_shortcut.dart';
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
  DataShortcut dataShortcut = new DataShortcut();
  String _result = '';
  List _array;

  @override
  Widget build(BuildContext context) {
    dataShortcut.autoRefresh(setState, widget.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add an SSH command',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddShortcut(new Shortcut.noId("", "", widget.id))),
              );
            },
          ),
        ],
      ),
      body: getShortCutList(),
    );
  }

  Widget getShortCutList() {
    if (dataShortcut.shortcutList.length == 0) {
      return Center(
        child: Text(
          'NO SCORES AVAILABLE',
          style: TextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: dataShortcut.shortcutList.length,
        itemBuilder: (BuildContext context, position) {
          position = position;
          dataShortcut.updateListView(setState, widget.id);
          return Column(
            children: [

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.adjust_outlined,
                    size: 46,
                  ),
                  dense: true,
                  title: Text(dataShortcut.shortcutList[position].name),
                  subtitle: Text(
                      '~\$ ${dataShortcut.shortcutList[position].command}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        dataShortcut.delete(
                            context,
                            dataShortcut.shortcutList[position],
                            setState,
                            widget.id);
                        dataShortcut.shortcutList.removeAt(position);
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
          print(await client.writeToShell("export DISPLAY=:1\n"));
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
}