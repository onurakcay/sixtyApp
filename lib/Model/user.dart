import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyUserClass {
  final String userID;
  String email, userName, profileURL, name, surname, gender, interest;
  DateTime createdAt, updatedAt;
  int level, age;
  MyUserClass({@required this.userID, @required this.email});

  Map<String, dynamic> toMap(
      String gender, String interest, String age, String userName) {
    Random rnd = new Random();

    return {
      'userID': userID,
      'email': email,
      'userName': userName ?? 'user' + rnd.nextInt(999999 - 10000).toString(),
      'profileURL': profileURL == null && gender == 'male'
          ? 'https://p1.hiclipart.com/preview/444/382/414/frost-pro-for-os-x-icon-set-now-free-contacts-male-profile-png-clipart.jpg'
          : profileURL == null && gender == 'female'
              ? 'https://cdn1.iconfinder.com/data/icons/social-messaging-productivity-1-1/128/gender-female2-512.png'
              : profileURL == null && gender == 'other'
                  ? 'https://cdn.onlinewebfonts.com/svg/img_266351.png'
                  : profileURL,
      'name': name ?? '',
      'surname': surname ?? '',
      'age': int.parse(age) ?? null,
      'interest': interest ?? null,
      'level': level ?? 1,
      'gender': gender ?? '',
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  MyUserClass.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profileURL = map['profileURL'],
        name = map['name'],
        surname = map['surname'],
        age = map['age'],
        level = map['level'],
        interest = map['interest'],
        gender = map['gender'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate() ?? null;

  MyUserClass.idveResim(
      {@required this.userID,
      @required this.profileURL,
      @required this.userName});

  @override
  String toString() {
    return 'MyUserClass{userID: $userID, email: $email, userName: $userName, profileURL: $profileURL, name: $name, surname: $surname, gender: $gender, createdAt: $createdAt, updatedAt: $updatedAt, level: $level, age: $age, interest: $interest}';
  }
}
