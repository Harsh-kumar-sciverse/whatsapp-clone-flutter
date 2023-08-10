import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

import '../models/chatMessage.dart';

class FirebaseServices {
  static final firebaseUser = FirebaseAuth.instance.currentUser;
  static final uid = firebaseUser!.uid;
  static signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future sendMessage(
      {required String message,
      required String senderId,
      required String messageStatus,
      required String messageType,
      required String receiverId}) async {
    var uuid = const Uuid();
    var messageId = uuid.v4();

    await FirebaseFirestore.instance.collection('messages').doc(messageId).set({
      'message': message,
      'senderId': senderId,
      'time': Timestamp.now(),
      'messageStatus': messageStatus,
      'messageType': messageType,
      'receiverId': receiverId,
      'messageId': messageId,
      'toFromUser': [receiverId, senderId],
      'isRepliedMessage': false,
      'repliedMessageId': '',
      'repliedMessageSenderId': '',
      'repliedMessage': '',
      'repliedMessageType': ''
    });
  }

  static Future sendRepliedMessage({
    required String message,
    required String senderId,
    required String messageStatus,
    required String messageType,
    required String receiverId,
    required String repliedMessageId,
    required String repliedMessageSenderId,
    required String repliedMessage,
    required String repliedMessageType,
  }) async {
    var uuid = const Uuid();
    var messageId = uuid.v4();

    await FirebaseFirestore.instance.collection('messages').doc(messageId).set({
      'message': message,
      'senderId': senderId,
      'time': Timestamp.now(),
      'messageStatus': messageStatus,
      'messageType': messageType,
      'receiverId': receiverId,
      'messageId': messageId,
      'toFromUser': [receiverId, senderId],
      'isRepliedMessage': true,
      'repliedMessageId': repliedMessageId,
      'repliedMessageSenderId': repliedMessageSenderId,
      'repliedMessage': repliedMessage,
      'repliedMessageType': repliedMessageType,
    });
  }

  static Future<String?> getDeviceToken() async {
    String? deviceToken;
    FirebaseMessaging _firebaseMessaging =
        FirebaseMessaging.instance; // Change here
    return _firebaseMessaging.getToken();
  }

  static Future<void> updateDeviceToken() async {
    String deviceToken = '';
    await getDeviceToken().then((value) {
      if (value != null) {
        deviceToken = value;
      }
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'deviceToken': deviceToken});
  }

  static Future<void> updateTypingStatus(
      {required bool isTyping, required String typingTo}) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'typingStatus': {'isTyping': isTyping, 'typingTo': typingTo}
    });
  }

  static Future<void> updateUserOnline(bool isOnline) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isOnline': isOnline});
  }

  static Future<void> updateLastSeen() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'lastSeen': Timestamp.now()});
  }

  static Future<void> updateMessageStatus({required doc}) async {
    await FirebaseFirestore.instance.collection('messages').doc(doc).update({
      'messageStatus': 'seen',
    });
  }

  static Stream<ChatMessage> getLastMessage({required String id}) async* {
    FirebaseFirestore.instance
        .collection('messages')
        .where('toFromUser', arrayContains: uid)
        .orderBy('time', descending: false)
        .limit(1);
  }
}
