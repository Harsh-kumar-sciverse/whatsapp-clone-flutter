import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  Timestamp? lastSeen;
  String? profilePhoto;
  String? about;
  bool? isBlocked;
  String? countryCode;
  String? phoneNumber;
  String? name;
  String? uid;
  Timestamp? joinedDate;
  Map<String, dynamic>? typingStatus;
  String? deviceToken;
  bool? isOnline;

  UserModel({
    this.phoneNumber,
    this.countryCode,
    this.name,
    this.joinedDate,
    this.about,
    this.isBlocked,
    this.lastSeen,
    this.profilePhoto,
    this.uid,
    this.typingStatus,
    this.deviceToken,
    this.isOnline,
  });
  Stream<List<UserModel>> get users {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? _user = _auth.currentUser;
    var _uid = _user?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) => UserModel(
                phoneNumber: documentSnapshot.get('phoneNumber'),
                countryCode: documentSnapshot.get('countryCode'),
                name: documentSnapshot.get('name'),
                joinedDate: documentSnapshot.get('joinedDate'),
                about: documentSnapshot.get('about'),
                isBlocked: documentSnapshot.get('isBlocked'),
                lastSeen: documentSnapshot.get('lastSeen'),
                profilePhoto: documentSnapshot.get(
                  'ProfilePhoto',
                ),
                uid: documentSnapshot.get('uid'),
                isOnline: documentSnapshot.get('isOnline'),
                typingStatus: documentSnapshot.get('typingStatus'),
                deviceToken: documentSnapshot.get('deviceToken')))
            .toList());
  }
}
