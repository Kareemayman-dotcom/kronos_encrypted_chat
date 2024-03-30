import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kronos_encrypted_chat/ceaser_cipher.dart';
import 'package:kronos_encrypted_chat/message_model.dart';
import 'package:sizer/sizer.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

// class _Message {
//   int whom;
//   String text;

//   _Message(this.whom, this.text);
// }

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection? connection;

  List<Message> messages = List<Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  void getKey() {
    // int result = (pow(int.parse(messages[1].content), randomNum) % 17).toInt();
    int result = int.parse(messages[1].content) * randomNum;
    print(" this is anas first message${int.parse(messages[1].content)}");
    finalComKey = result >= 26 ? 25 : result;
    cc = CaesarCipher(finalComKey);
  }

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  late CaesarCipher cc;
  bool isDisconnecting = false;
  bool firstSend = true;
  bool firstReceive = true;
  late int randomNum;
  late int finalComKey;
  bool cyphered = true;
  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      randomNum = Random().nextInt(9) + 2;
      connection = _connection;
      sendresult();
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  int sharedkeygen() {
    // int result = (((pow(3, randomNum)) % 17)).toInt();
    int result = randomNum;
    return result;
  }

  void sendresult() {
    _sendMessage("${sharedkeygen()}");
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(cyphered == true
                    ? _message.Ciphered.trim()
                    : _message.content.trim()),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      backgroundColor: const Color(0xff1e2029),
      appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: (isConnecting
              ? Text(
                  'Connecting chat to ' + serverName + '...',
                  style: const TextStyle(color: Colors.white),
                )
              : isConnected
                  ? Text(
                      'Live chat with ' + serverName,
                      style: const TextStyle(color: Colors.white),
                    )
                  : Text('Chat log with ' + serverName))),
      body: Stack(
        children: [
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Kronos",
                style: TextStyle(
                  fontSize: 28.sp,
                  color: Colors.white60,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: SizedBox(
                  height: 12.h,
                  child: Image.asset(
                    'assets/gaurdemoji.png',
                    color: const Color(0xff1e2029),
                    colorBlendMode: BlendMode.difference,
                  ),
                ),
              )
            ],
          )),
          SafeArea(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: ListView(
                      padding: const EdgeInsets.all(12.0),
                      controller: listScrollController,
                      children: list),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius:
                                  BorderRadiusDirectional.circular(25)),
                          margin: const EdgeInsets.only(left: 16.0),
                          child: TextField(
                            style: const TextStyle(fontSize: 15.0),
                            controller: textEditingController,
                            decoration: InputDecoration.collapsed(
                              hintText: isConnecting
                                  ? 'Wait until connected...'
                                  : isConnected
                                      ? 'Type your message...'
                                      : 'Chat got disconnected',
                              hintStyle: const TextStyle(color: Colors.black),
                            ),
                            enabled: isConnected,
                            // enabled: true,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: isConnected
                                ? () => _sendMessage(textEditingController.text)
                                : null),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  cyphered = !cyphered;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 5.w, top: 2.h),
                height: 35.sp,
                width: 35.sp,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                    cyphered == true ? Icons.visibility_off : Icons.visibility),
                // color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (firstReceive) {
      if (~index != 0) {
        setState(() {
          messages.add(
            Message(
              Ciphered: backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : _messageBuffer + dataString.substring(0, index),
              whom: 1,
              content: backspacesCounter > 0
                  ? _messageBuffer.substring(
                      0, _messageBuffer.length - backspacesCounter)
                  : _messageBuffer + dataString.substring(0, index),
            ),
          );
          _messageBuffer = dataString.substring(index);
        });
      } else {
        _messageBuffer = (backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString);
      }
      firstReceive = false;
      getKey();

      print("this is the final key$finalComKey");
      print("This is the random $randomNum");
    } else {
      if (~index != 0) {
        setState(() {
          messages.add(
            Message(
                Ciphered: backspacesCounter > 0
                    ? _messageBuffer.substring(
                        0, _messageBuffer.length - backspacesCounter)
                    : _messageBuffer + dataString.substring(0, index),
                whom: 1,
                content: cc.decrypt(
                  backspacesCounter > 0
                      ? _messageBuffer.substring(
                          0, _messageBuffer.length - backspacesCounter)
                      : _messageBuffer + dataString.substring(0, index),
                )),
          );
          _messageBuffer = dataString.substring(index);
        });
      } else {
        _messageBuffer = (backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString);
      }
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    if (firstSend) {
      if (text.length > 0) {
        try {
          connection!.output
              .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
          await connection!.output.allSent;

          setState(() {
            messages.add(Message(
              content: text,
              whom: clientID,
              Ciphered: text,
            ));
          });

          Future.delayed(const Duration(milliseconds: 333)).then((_) {
            listScrollController.animateTo(
                listScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 333),
                curve: Curves.easeOut);
          });
        } catch (e) {
          // Ignore error, but notify state
          print("he text got broken in envryption");
          setState(() {});
        } finally {
          firstSend = false;
        }
      }
    } else {
      if (text.length > 0) {
        try {
          connection!.output
              .add(Uint8List.fromList(utf8.encode(cc.encrypt(text) + "\r\n")));
          await connection!.output.allSent;
          print(cc.encrypt(text));
          setState(() {
            messages.add(Message(
              content: text,
              whom: clientID,
              Ciphered: cc.encrypt(text),
            ));
          });

          Future.delayed(const Duration(milliseconds: 333)).then((_) {
            listScrollController.animateTo(
                listScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 333),
                curve: Curves.easeOut);
          });
        } catch (e) {
          // Ignore error, but notify state
          print("he text got broken in envryption");
          setState(() {});
        }
      }
    }
  }
}
