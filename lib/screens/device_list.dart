import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssh_client_shortcut/screens/shortcut_list.dart';
import 'package:ssh_client_shortcut/services/databaseGetter.dart';
import 'package:ssh_client_shortcut/models/device.dart';
import 'package:ssh_client_shortcut/screens/add_device.dart';

class DeviceList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeviceListState();
  }
}

class _DeviceListState extends State<DeviceList> {
  DataDevice dataDevice = new DataDevice();

  @override
  Widget build(BuildContext context) {
    dataDevice.autoRefresh(setState);
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Device',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddDevice(new Device.noId("", "", ""))),
              );
            },
          ),
        ],
      ),
      body: getShortCutList(),
    );
  }

  Widget getShortCutList() {
    if (dataDevice.deviceList.length == 0) {
      return Center(
        child: Text(
          'NO DEVICES AVAILABLE',
          style: TextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: dataDevice.deviceList.length,
        itemBuilder: (BuildContext context, position) {
          position = position;
          dataDevice.updateListView(setState);
          return Column(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.adjust_outlined,
                    size: 46,
                  ),
                  dense: true,
                  title: Text(dataDevice.deviceList[position].nickName),
                  subtitle: Text(
                      '${dataDevice.deviceList[position].userName}@${dataDevice.deviceList[position].ipAddress}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        dataDevice.delete(
                            context, dataDevice.deviceList[position], setState);
                        dataDevice.deviceList.removeAt(position);
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShortcutList(
                                id: dataDevice.deviceList[position].id,
                                userName: dataDevice.deviceList[position].userName,
                                ipAddress: dataDevice.deviceList[position].ipAddress,
                                password: dataDevice.deviceList[position].password,
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
}
