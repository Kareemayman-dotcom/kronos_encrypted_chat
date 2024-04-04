import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kronos_encrypted_chat/chat_page.dart';
import 'package:kronos_encrypted_chat/discovery_page.dart';
import 'package:kronos_encrypted_chat/select_bonded_page_device.dart';
import 'package:sizer/sizer.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    // _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  int _selectedMode = 1; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1e2029),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Kronos'),
      ),
      body: Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Kronos",
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.white60,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: SizedBox(
                      height: 12.h,
                      child: Image.asset(
                        'assets/gaurdemoji.png',
                        color: Color(0xff1e2029),
                        colorBlendMode: BlendMode.difference,
                      ),
                    ),
                  )
                ],
              )),
          Container(
            child: ListView(
              children: <Widget>[
                Divider(),
                ListTile(
                    title: const Text(
                  'General',
                  style: TextStyle(color: Colors.white),
                )),
                SwitchListTile(
                  title: const Text(
                    'Enable Bluetooth',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value) {
                    // Do the request and update with the true value then
                    future() async {
                      // async lambda seems to not working
                      if (value)
                        await FlutterBluetoothSerial.instance.requestEnable();
                      else
                        await FlutterBluetoothSerial.instance.requestDisable();
                    }

                    future().then((_) {
                      setState(() {});
                    });
                  },
                ),
                ListTile(
                  title: const Text(
                    'Connect to your device',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(_bluetoothState.toString()),
                  trailing: ElevatedButton(
                    child: const Text('Settings'),
                    onPressed: () {
                      FlutterBluetoothSerial.instance.openSettings();
                    },
                  ),
                ),
                // ListTile(
                //   title: const Text(
                //     'Local adapter address',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   subtitle: Text(_address),
                // ),
                // ListTile(
                //   title: const Text(
                //     'Local adapter name',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   subtitle: Text(_name),
                //   onLongPress: null,
                // ),
                // ListTile(
                //   title: _discoverableTimeoutSecondsLeft == 0
                //       ? const Text(
                //           "Discoverable",
                //           style: TextStyle(color: Colors.white),
                //         )
                //       : Text(
                //           style: TextStyle(color: Color.fromARGB(255, 58, 57, 57)),
                //           "Discoverable for ${_discoverableTimeoutSecondsLeft}s",
                //         ),
                //   // subtitle: const Text("PsychoX-Luna"),
                //   trailing: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Checkbox(
                //         value: _discoverableTimeoutSecondsLeft != 0,
                //         onChanged: null,
                //       ),
                //       IconButton(
                //         icon: const Icon(Icons.edit),
                //         onPressed: null,
                //       ),
                //       IconButton(
                //         icon: const Icon(Icons.refresh),
                //         onPressed: () async {
                //           print('Discoverable requested');
                //           final int timeout = (await FlutterBluetoothSerial.instance
                //               .requestDiscoverable(60))!;
                //           if (timeout < 0) {
                //             print('Discoverable mode denied');
                //           } else {
                //             print(
                //                 'Discoverable mode acquired for $timeout seconds');
                //           }
                //           setState(() {
                //             _discoverableTimeoutTimer?.cancel();
                //             _discoverableTimeoutSecondsLeft = timeout;
                //             _discoverableTimeoutTimer =
                //                 Timer.periodic(Duration(seconds: 1), (Timer timer) {
                //               setState(() {
                //                 if (_discoverableTimeoutSecondsLeft < 0) {
                //                   FlutterBluetoothSerial.instance.isDiscoverable
                //                       .then((isDiscoverable) {
                //                     if (isDiscoverable ?? false) {
                //                       print(
                //                           "Discoverable after timeout... might be infinity timeout :F");
                //                       _discoverableTimeoutSecondsLeft += 1;
                //                     }
                //                   });
                //                   timer.cancel();
                //                   _discoverableTimeoutSecondsLeft = 0;
                //                 } else {
                //                   _discoverableTimeoutSecondsLeft -= 1;
                //                 }
                //               });
                //             });
                //           });
                //         },
                //       )
                //     ],
                //   ),
                // ),
                Divider(),
                ListTile(
                    title: const Text(
                  'Connection and chat security',
                  style: TextStyle(color: Colors.white),
                )),
                SwitchListTile(
                  
          title: const Text('Ceaser Cipher',style: TextStyle(color: Colors.white)),
          value: _selectedMode == 1,
          onChanged: (value) {
            setState(() {
              _selectedMode = value ? 1 : 0; 
            });
          },
        ),
        SwitchListTile(
          
          title: const Text('Vigenère Cipher',style: TextStyle(color: Colors.white)),
          value: _selectedMode == 2,
          onChanged: (value) {
            setState(() {
              _selectedMode = value ? 2 : 0; 
            });
          },
        ),
        SwitchListTile(
          
          title: const Text('Rail Fence Cipher',style: TextStyle(color: Colors.white)),
          value: _selectedMode == 3,
          onChanged: (value) {
            setState(() {
              _selectedMode = value ? 3 : 0; 
            });}),
                ListTile(
                  title: ElevatedButton(
                      child: const Text('Explore discovered devices'),
                      onPressed: () async {
                        final BluetoothDevice? selectedDevice =
                            await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DiscoveryPage();
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          print('Discovery -> selected ' +
                              selectedDevice.address);
                        } else {
                          print('Discovery -> no device selected');
                        }
                      }),
                ),
                ListTile(
                  title: ElevatedButton(
                    child: const Text('Connect to paired device to chat'),
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SelectBondedDevicePage(
                                checkAvailability: false);
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print('Connect -> selected ' + selectedDevice.address);
                        _startChat(context, selectedDevice);
                      } else {
                        print('Connect -> no device selected');
                      }
                    },
                  ),
                ),
                // Divider(),
                // ListTile(title: const Text('Multiple connections example')),
                // ListTile(
                //   title: ElevatedButton(
                //     // child: ((_collectingTask?.inProgress ?? false)
                //     //     ? const Text('Disconnect and stop background collecting')
                //     //     : const Text('Connect to start background collecting')),
                //     child: Text('Connect to start background collecting'),
                //     onPressed: () async {
                //       // if (_collectingTask?.inProgress ?? false) {
                //       //   await _collectingTask!.cancel();
                //       //   setState(() {
                //       //     /* Update for `_collectingTask.inProgress` */
                //       //   });
                //       // } else {
                //       //   // final BluetoothDevice? selectedDevice =
                //       //   //     await Navigator.of(context).push(
                //       //   //   MaterialPageRoute(
                //       //   //     builder: (context) {
                //       //   //       return SelectBondedDevicePage(
                //       //   //           checkAvailability: false);
                //       //   //     },
                //       //   //   ),
                //       //   // );

                //       //   // if (selectedDevice != null) {
                //       //   //   await _startBackgroundTask(context, selectedDevice);
                //       //   //   setState(() {
                //       //   //     /* Update for `_collectingTask.inProgress` */
                //       //   //   });
                //       //   // }
                //       // }
                //     },
                //   ),
                // ),
                // ListTile(
                //   title: ElevatedButton(
                //     child: const Text('View background collected data'),
                //     onPressed: () {},
                //     // onPressed: (_collectingTask != null)
                //     //     ? () {
                //     //         // Navigator.of(context).push(
                //     //         //   MaterialPageRoute(
                //     //         //     builder: (context) {
                //     //         //       return ScopedModel<BackgroundCollectingTask>(
                //     //         //         model: _collectingTask!,
                //     //         //         child: BackgroundCollectedPage(),
                //     //         //       );
                //     //         //     },
                //     //         //   ),
                //     //         // );
                //     //       }
                //     //     : null,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server, chatMode: _selectedMode,);
        },
      ),
    );
  }

  // Future<void> _startBackgroundTask(
  //   BuildContext context,
  //   BluetoothDevice server,
  // ) async {
  //   try {
  //     _collectingTask = await BackgroundCollectingTask.connect(server);
  //     await _collectingTask!.start();
  //   } catch (ex) {
  //     _collectingTask?.cancel();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error occured while connecting'),
  //           content: Text("${ex.toString()}"),
  //           actions: <Widget>[
  //             new TextButton(
  //               child: new Text("Close"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }
}
