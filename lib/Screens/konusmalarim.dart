import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/chat.dart';

import 'package:sixtyseconds/viewModel/userModel.dart';
import 'package:skeleton_text/skeleton_text.dart';

class KonusmalarimTab extends StatefulWidget {
  @override
  _KonusmalarimTabState createState() => _KonusmalarimTabState();
}

class _KonusmalarimTabState extends State<KonusmalarimTab> {
  List<Chat> _allChats;
  bool _isLoading = false;
  bool _hasMore = true;
  int _itemsPerFetch = 7;
  Chat _lastFetchedChat;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getChat();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position == 0) {
          print("en tepedeyiz");
        } else {
          getChat();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Konusmalarim"),
      ),
      body: _allChats == null
          ? Center(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.white70),
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SkeletonAnimation(
                                child: Container(
                                  width: 70.0,
                                  height: 70.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, bottom: 5.0),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        height: 15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: SkeletonAnimation(
                                        child: Container(
                                          width: 60,
                                          height: 13,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.grey[300]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          : _allChats.length > 0
              ? _createChatList()
              : RefreshIndicator(
                  onRefresh: _refreshMyChats,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                                "https://media.tenor.com/images/c378b26f65d993c886d9c6fc29b6dcdf/tenor.gif"),
                            Container(
                              margin: EdgeInsets.only(top: 24),
                              child: Text('Henüz kimseyle konuşmuyorsun.'),
                            ),
                            FlatButton.icon(
                              icon: Icon(Icons.refresh_rounded),
                              label: Text("Yeniden Dene"),
                              onPressed: _refreshMyChats,
                              textColor: Colors.black54,
                            )
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height - 150,
                    ),
                  ),
                ),
    );
  }

  getChat() async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (!_hasMore) {
      print("Nanay");
      return;
    }
    if (_isLoading == true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    List<Chat> _chats = await _userModel.getAllChatsWithPagination(
        _userModel, _lastFetchedChat, _itemsPerFetch);

    if (_allChats == null) {
      _allChats = [];
      _allChats.addAll(_chats);
    } else {
      _allChats.addAll(_chats);
    }

    if (_chats.length < _itemsPerFetch) {
      _hasMore = false;
    }

    _lastFetchedChat = _allChats.last;

    setState(() {
      _isLoading = false;
    });
  }

  _createChatList() {
    UserModel _userModel = Provider.of<UserModel>(context, listen: false);
    return RefreshIndicator(
      onRefresh: _refreshMyChats,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index == _allChats.length) {
            return _newElementsWaitIndicator();
          }
          var currentChat = _allChats[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) => Sohbet(
                            currentUser: _userModel.user,
                            chattingUser: MyUserClass.idveResim(
                                userID: currentChat.talking_to,
                                profileURL: currentChat.chattingProfilePicture,
                                userName: currentChat.chattingUsername),
                          )));
            },
            child: Card(
              child: ListTile(
                title: Text(currentChat.chattingUsername),
                isThreeLine: true,
                subtitle: Text(currentChat.last_sent_message.length > 20
                    ? currentChat.last_sent_message.replaceRange(
                            20, currentChat.last_sent_message.length, '...') +
                        " • " +
                        currentChat.aradakiFark.toString()
                    : currentChat.last_sent_message +
                        " • " +
                        currentChat.aradakiFark.toString()),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(primaryColor),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        NetworkImage(currentChat.chattingProfilePicture),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: _allChats.length + 1,
      ),
    );
  }

  _newElementsWaitIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: Center(
          child: Opacity(
            opacity: _isLoading ? 1 : 0,
            child: _isLoading ? CircularProgressIndicator() : null,
          ),
        ),
      ),
    );
  }

  Future<Null> _refreshMyChats() async {
    setState(() {});
    return null;
  }
}
