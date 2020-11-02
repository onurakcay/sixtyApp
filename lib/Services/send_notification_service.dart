import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  Future<bool> sendNotification(
      Message notificationToSend, MyUserClass sentUser, String token) async {
    String endURL = "https://fcm.googleapis.com/fcm/send";
    String firebaseKey =
        "AAAA_0RAreQ:APA91bEiut9PoyjAyJY4biyZB4oG05ZJmF4qD8Q-9psLSQi98tgcn7foMkUh53k2N2UZD-rJW_YRPB_Yv-2aMCja6zkhRBE_mwwNStPk8EdDcetG_zBYLLtv5rPi7uJ92_rTr8pSGJwF";
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "key=$firebaseKey"
    };
    String json =
        '{"to":"$token","data":{"message":"${notificationToSend.message}","title":"${sentUser.userName} sana bir mesaj gönderdi","profilURL":"${sentUser.profileURL}","gonderenUserID":"${sentUser.userID}"}}';

    http.Response response =
        await http.post(endURL, headers: header, body: json);
    if (response.statusCode == 200) {
      print("islem başarılı");
    } else {
      print("islem basarisiz " + response.statusCode.toString());
      print("jsonumuuz: " + json);
    }
    return null;
  }
}
