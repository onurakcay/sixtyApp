import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/chat.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class KullanicilarTab extends StatefulWidget {
  @override
  _KullanicilarTabState createState() => _KullanicilarTabState();
}

class _KullanicilarTabState extends State<KullanicilarTab> {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Kullanicilar"),
      ),
      body: FutureBuilder<List<MyUserClass>>(
        future: _userModel.getAllUser(_userModel),
        builder: (context, sonuc) {
          if (sonuc.hasData) {
            var tumKullanicilar = sonuc.data;
            if (tumKullanicilar.length > 0) {
              print("TUM KULLANICILAR: " + tumKullanicilar.length.toString());
              return RefreshIndicator(
                onRefresh: _refreshUsers,
                child: ListView.builder(
                  itemCount: tumKullanicilar.length,
                  itemBuilder: (context, index) {
                    var currentUserIndex = sonuc.data[index];

                    print("Çeklilen Kullanıcı " + currentUserIndex.userID);
                    print("Aktif Kullanıcı " + _userModel.user.userID);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(CupertinoPageRoute(
                                builder: (context) => Sohbet(
                                      currentUser: _userModel.user,
                                      chattingUser: currentUserIndex,
                                    )));
                      },
                      child: _userModel.user.userID != currentUserIndex.userID
                          ? ListTile(
                              title: Text(currentUserIndex.userName),
                              subtitle: Text(currentUserIndex.email),
                              leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      currentUserIndex.profileURL)),
                            )
                          : Container(),
                    );
                  },
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _refreshUsers,
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
                            child: Text('Henüz kayıtlı kullanıcı yok.'),
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.refresh_rounded),
                            label: Text("Yeniden Dene"),
                            onPressed: _refreshUsers,
                            textColor: Colors.black54,
                          )
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height - 150,
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<Null> _refreshUsers() async {
    setState(() {});

    return null;
  }
}
