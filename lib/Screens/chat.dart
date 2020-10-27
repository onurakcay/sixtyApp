import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
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
  final bool isChatted;

  Sohbet({this.currentUser, this.chattingUser, this.isChatted});

  @override
  _SohbetState createState() => _SohbetState();
}

class _SohbetState extends State<Sohbet> {
  var _messageController = TextEditingController();
  final _controller = ScrollController();
  CountDownController _timerController = CountDownController();
  bool _isPause = false;
  bool _isLocked = true;
  bool _isYourTurn = true;

  @override
  @override
  Widget build(BuildContext context) {
    MyUserClass _currentUser = widget.currentUser;
    MyUserClass _chattingUser = widget.chattingUser;
    bool _isChatted = widget.isChatted;
    if (_isChatted == null) {
      _isChatted = false;
    }
    print(_isChatted);
    final _userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isChatted
            ? _chattingUser.userName
            : _isYourTurn
                ? "Senin Sıran"
                : "Onun Sırası"),
        actions: [
          !_isChatted
              ? timerCountdown(_isChatted)
              : profilePicture(_chattingUser)
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
                    enableInteractiveSelection:
                        false, // will disable paste operation

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

                      if (_isYourTurn  && _isChatted==false) {
                        _timerController.restart();
                      }
                      setState(() {
                        _isYourTurn = false;
                      });

                      var _messageToSent = _messageController.text;
                      if (_messageController.text.trim().length > 0) {
                        _messageController.clear();
                        Message _saveMessage = Message(
                            from: _currentUser.userID,
                            to: _chattingUser.userID,
                            fromMe: true,
                            message: _messageToSent);
                        var sonuc = await _userModel.saveMessage(
                            _saveMessage, _currentUser);
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
                // CircleAvatar(
                //   backgroundImage: NetworkImage(widget.chattingUser.profileURL),
                // ),
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

  timerCountdown(bool isChatted) {
    if (!isChatted) {
      return CircularCountDownTimer(
        // Countdown duration in Seconds
        duration: 60,

        // Controller to control (i.e Pause, Resume, Restart) the Countdown
        controller: _timerController,

        // Width of the Countdown Widget
        width: 80,

        // Height of the Countdown Widget
        height: MediaQuery.of(context).size.height / 2,

        // Default Color for Countdown Timer
        color: Colors.white,

        // Filling Color for Countdown Timer
        fillColor: Colors.purpleAccent,

        // Background Color for Countdown Widget
        backgroundColor: null,

        // Border Thickness of the Countdown Circle
        strokeWidth: 5.0,

        // Text Style for Countdown Text
        textStyle: TextStyle(
            fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),

        // true for reverse countdown (max to 0), false for forward countdown (0 to max)
        isReverse: true,

        // true for reverse animation, false for forward animation
        isReverseAnimation: true,

        // Optional [bool] to hide the [Text] in this widget.
        isTimerTextShown: true,

        // Function which will execute when the Countdown Ends
        onComplete: () {
          // Here, do whatever you want
          print('Countdown Ended');
        },
      );
    }
  }

  profilePicture(MyUserClass chattingUser) {
    var container = Container(
      margin: EdgeInsets.only(right: 30),
      child: CircleAvatar(
        backgroundImage: NetworkImage(chattingUser.profileURL),
      ),
    );
    return container;
  }
}
