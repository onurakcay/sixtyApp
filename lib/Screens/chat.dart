import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class Sohbet extends StatefulWidget {
  final MyUserClass currentUser;
  final MyUserClass chattingUser;

  Sohbet({this.currentUser, this.chattingUser});

  @override
  _SohbetState createState() => _SohbetState();
}

class _SohbetState extends State<Sohbet> {
  var _messageController = TextEditingController();
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    MyUserClass _currentUser = widget.currentUser;
    MyUserClass _chattingUser = widget.chattingUser;
    final _userModel = Provider.of<UserModel>(context);
    print("CHATTING USER " + _chattingUser.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(_chattingUser.userName),
        actions: [
          FullScreenWidget(
            child: Hero(
              tag: "customTag",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.05),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(_chattingUser.profileURL),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _userModel.getMessages(
                  _currentUser.userID, _chattingUser.userID),
              builder: (context, streamMessageList) {
                if (!streamMessageList.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Message> allMessages = streamMessageList.data;
                return ListView.builder(
                  reverse: true,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    return _generateChatBaloon(allMessages[index]);
                  },
                  itemCount: allMessages.length,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    cursorColor: Colors.blueGrey,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Mesaj Gönder",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Colors.pink,
                    child: Icon(
                      Icons.send,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      var _messageToSent = _messageController.text;
                      if (_messageController.text.trim().length > 0) {
                        _messageController.clear();
                        Message _saveMessage = Message(
                            from: _currentUser.userID,
                            to: _chattingUser.userID,
                            fromMe: true,
                            message: _messageToSent);
                        var sonuc = await _userModel.saveMessage(_saveMessage);
                        if (sonuc) {
                          _controller.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _generateChatBaloon(Message printedMessage) {
    Color _recivedMessageBaloonColor = Color(primaryColor);
    Color _sentMessageBaloonColor = Colors.blueGrey;
    var _isMyMessage = printedMessage.fromMe;
    var _valueOfTimeMinute = "";
    try {
      _valueOfTimeMinute = _showTimeMinute(printedMessage.date);
    } catch (e) {
      print("Hata var: " + e);
    }

    if (_isMyMessage) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _sentMessageBaloonColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        printedMessage.message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      _valueOfTimeMinute,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.chattingUser.profileURL),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _recivedMessageBaloonColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              printedMessage.message,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            _valueOfTimeMinute,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  String _showTimeMinute(Timestamp date) {
    var _formatter = DateFormat.Hm();
    var _formattedDate = _formatter.format(date.toDate());

    return _formattedDate;
  }
}
