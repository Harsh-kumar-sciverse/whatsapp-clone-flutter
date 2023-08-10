import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  String? message;
  String? senderId;
  Timestamp? time;
  String? messageStatus;
  String? messageType;
  String? receiverId;
  String? messageId;
  final List<String>? toFromUser;
  bool? isRepliedMessage;
  String? repliedMessageId;
  String? repliedMessageSenderId;
  String? repliedMessage;
  String? repliedMessageType;

  ChatMessage(
      {this.message,
      this.senderId,
      this.messageStatus,
      this.time,
      this.messageType,
      this.receiverId,
      this.toFromUser,
      this.isRepliedMessage,
      this.repliedMessage,
      this.repliedMessageId,
      this.repliedMessageSenderId,
      this.repliedMessageType,
      this.messageId});

  Stream<List<ChatMessage>> get chatMessages {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? _user = _auth.currentUser;
    var _uid = _user?.uid;
    return FirebaseFirestore.instance
        .collection('messages')
        .where('toFromUser', arrayContains: _uid)
        .orderBy('time', descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot documentSnapshot) => ChatMessage(
                  message: documentSnapshot.get('message'),
                  senderId: documentSnapshot.get('senderId'),
                  messageStatus: documentSnapshot.get('messageStatus'),
                  time: documentSnapshot.get('time'),
                  messageType: documentSnapshot.get('messageType'),
                  receiverId: documentSnapshot.get('receiverId'),
                  messageId: documentSnapshot.get('messageId'),
                  isRepliedMessage: documentSnapshot.get('isRepliedMessage'),
                  repliedMessage: documentSnapshot.get('repliedMessage'),
                  repliedMessageId: documentSnapshot.get('repliedMessageId'),
                  repliedMessageSenderId:
                      documentSnapshot.get('repliedMessageSenderId'),
                  repliedMessageType:
                      documentSnapshot.get('repliedMessageType'),
                ))
            .toList());
  }
}
