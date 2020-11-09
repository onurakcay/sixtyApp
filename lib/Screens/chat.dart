import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
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
  CountDownController _generaltimerController = CountDownController();
  // bool _isPause = false;
  // bool _isLocked = true;
  bool _isYourTurn = true;
  var isFalse;

  @override
  @override
  Widget build(BuildContext context) {
    MyUserClass _currentUser = widget.currentUser;
    MyUserClass _chattingUser = widget.chattingUser;
    bool _isChatted = widget.isChatted;
    int stop = 0;
    if (_isChatted == null) {
      _isChatted = false;
    }
    print(_isChatted);
    final _userModel = Provider.of<UserModel>(context);
    _isChatted = false;
    return Scaffold(
      appBar: AppBar(
        title: _isChatted
            ? Text(_chattingUser.userName)
            : Text(_chattingUser.userName),
        actions: [
          Visibility(
            visible: false,
            child: generalTimerCountdown(_isChatted),
          ),
          !_isChatted
              ? timerCountdown(_isChatted)
              : profilePicture(_chattingUser),
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
                int messageCounter = allMessages.length;
                return ListView.builder(
                  reverse: true,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    print("from me : " + allMessages.first.fromMe.toString());
                    print("stop?: " + stop.toString());
                    print("All Messages from me: " +
                        allMessages.first.fromMe.toString() +
                        "Stop: " +
                        stop.toString());
                    isFalse = !allMessages.first.fromMe;
                    if (!isFalse && stop == 0) {
                      isFalse = true;
                      print("All Messages: " +
                          allMessages.first.message.toString());
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _isYourTurn = true;
                        });
                      });
                    }

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
                      hintText: "Mesaj Gönderrrrrr",
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
                      print("isyoutrturn: " +
                          _isYourTurn.toString() +
                          " isChatted: " +
                          _isChatted.toString());
                      if (_isYourTurn && !_isChatted) {
                        _timerController.restart();
                        _isYourTurn = false;
                      }
                      var isMatch = _isChatted ? true : false;
                      var _messageToSent = _messageController.text;
                      if (_messageController.text.trim().length > 0) {
                        _messageController.clear();
                        Message _saveMessage = Message(
                            from: _currentUser.userID,
                            to: _chattingUser.userID,
                            fromMe: true,
                            message: _messageToSent);
                        var sonuc = await _userModel.saveMessage(
                            _saveMessage, _currentUser, isMatch);
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
      // _timerController.restart();
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
        onComplete: () async {
          // Here, do whatever you want
          bool result = await PlatformBasedAlertDialog(
            title: "Üzgünüz",
            content:
                "60 saniye süresince mesajlaşmadığınız için eşleşmeniz bozuldu.",
            okButtonText: "Tamam",
          ).goster(context);
          print("RESULT: " + result.toString());
          if (result) {
            Navigator.pop(context);
          }
        },
      );
    }
  }

  generalTimerCountdown(bool isChatted) {
    final _userModel = Provider.of<UserModel>(context);
    MyUserClass _currentUser = widget.currentUser;
    MyUserClass _chattingUser = widget.chattingUser;
    if (!isChatted) {
      return CircularCountDownTimer(
        // Countdown duration in Seconds
        duration: 20,

        // Controller to control (i.e Pause, Resume, Restart) the Countdown
        controller: _generaltimerController,

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
        onComplete: () async {
          // Here, do whatever you want
          bool matchResult =
              await _userModel.matchWith(_chattingUser, _currentUser, true);
          if (matchResult) {
            bool result = await PlatformBasedAlertDialog(
              title: "Tebrikler Eşleşme Başarılı",
              content:
                  "Başarıyla eşleştin. Konuşmalarım sekmesinden daha sonra da konuşabilirsin.",
              okButtonText: "Tamam",
            ).goster(context);
            print("RESULT: " + result.toString());
            if (result) {
              Navigator.pop(context);
            }
          } else {
            bool result = await PlatformBasedAlertDialog(
              title: "Üzgünüz",
              content: "Bir şeyler ters gitti.",
              okButtonText: "Tamam",
            ).goster(context);
            print("RESULT: " + result.toString());
            if (result) {
              Navigator.pop(context);
            }
          }
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
