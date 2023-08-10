import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/firebase_services.dart';
import '../constants/color_constants.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatLayout extends StatefulWidget {
  const ChatLayout(
      {Key? key,
      required this.message,
      required this.senderId,
      required this.receiverId,
      required this.messageType,
      required this.time,
      required this.messageStatus,
      required this.messageId,
      required this.swipedMessageSenderName,
      required this.swipedMessageType,
      required this.swipedMessage,
      required this.isSwipedMessage})
      : super(key: key);

  final String message;
  final String senderId;
  final Timestamp time;
  final String messageStatus;
  final String messageType;
  final String receiverId;
  final String messageId;
  final String swipedMessageSenderName;
  final String swipedMessageType;
  final String swipedMessage;
  final bool isSwipedMessage;

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  @override
  Widget build(BuildContext context) {
    String formatTimestamp() {
      final timestampDate = widget.time.toDate();
      final now = DateTime.now();
      final today =
          DateTime(timestampDate.year, timestampDate.month, timestampDate.day);
      final todayTime = DateTime(now.year, now.month, now.day);
      final yesterdayTime = DateTime(now.year, now.month, now.day - 1);

      String formattedTime = DateFormat.jm().format(widget.time.toDate());

      if (today == todayTime) {
        return formattedTime.toLowerCase();
      } else if (today == yesterdayTime) {
        return formattedTime.toLowerCase();
      }

      var format = DateFormat('d-MMMM-y'); // <- use skeleton here
      return formattedTime.toLowerCase();
    }

    Widget lastMessage() {
      if (widget.senderId != FirebaseServices.firebaseUser!.uid) {
        return Container();
      } else {
        if (widget.messageStatus == 'seen') {
          return Image.asset(
            'icons/double-tick.png',
            height: 15,
          );
        } else if (widget.messageStatus == 'delivered') {
          return Image.asset(
            'icons/double-tick-grey.png',
            height: 15,
          );
        } else {
          return Icon(
            Icons.done,
            color: ColorConstants.singleTickColor,
            size: 17,
          );
        }
      }
    }

    if (widget.messageType == 'emoji') {
      return Row(
        mainAxisAlignment: widget.senderId == FirebaseServices.firebaseUser!.uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Lottie.network(
            widget.message,
            height: 150,
            animate: true,
          ),
        ],
      );
    }
    if (widget.messageType == 'text') {
      return Align(
        alignment: widget.senderId == FirebaseServices.firebaseUser!.uid
            ? Alignment.topRight
            : Alignment.topLeft,
        child: Padding(
          padding: widget.senderId == FirebaseServices.firebaseUser!.uid
              ? const EdgeInsets.only(left: 50, right: 10, bottom: 3)
              : const EdgeInsets.only(left: 10, right: 50, bottom: 3),
          child: widget.isSwipedMessage
              ? Card(
                  color: widget.senderId == FirebaseServices.firebaseUser!.uid
                      ? ColorConstants.chatBubbleSenderColor
                      : Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: widget.senderId ==
                                  FirebaseServices.firebaseUser!.uid
                              ? ColorConstants.replyBackColor
                              : ColorConstants.replyBackColorForOther,
                          gradient: widget.senderId ==
                                  FirebaseServices.firebaseUser!.uid
                              ? LinearGradient(stops: const [
                                  0.02,
                                  0.02,
                                ], colors: [
                                  ColorConstants.replyBorderColor,
                                  ColorConstants.replyBackColor,
                                ])
                              : LinearGradient(stops: const [
                                  0.02,
                                  0.02,
                                ], colors: [
                                  ColorConstants.replyBorderColor,
                                  ColorConstants.replyBackColorForOther,
                                ]),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 5,
                            top: 5,
                            bottom: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.swipedMessageSenderName,
                                style: TextStyle(
                                  color: ColorConstants.replyBorderColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              widget.swipedMessageType == 'emoji'
                                  ? const Icon(
                                      Icons.image,
                                      size: 10,
                                    )
                                  : Text(
                                      widget.swipedMessage,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            ColorConstants.dialogHeadingColor,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  //real message
                                  TextSpan(
                                    text: widget.message + "      ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorConstants.lastChatTitleColor,
                                    ),
                                  ),

                                  //fake additionalInfo as placeholder
                                  TextSpan(
                                      text: formatTimestamp(),
                                      style: const TextStyle(
                                          color: Colors.transparent)),
                                ],
                              ),
                            ),
                          ),

                          //real additionalInfo
                          Positioned(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatTimestamp(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ColorConstants.dialogHeadingColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                lastMessage()
                              ],
                            ),
                            right: 8.0,
                            bottom: 4.0,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              : Card(
                  color: widget.senderId == FirebaseServices.firebaseUser!.uid
                      ? ColorConstants.chatBubbleSenderColor
                      : Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              //real message
                              TextSpan(
                                text: widget.message + "      ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ColorConstants.lastChatTitleColor,
                                ),
                              ),

                              //fake additionalInfo as placeholder
                              TextSpan(
                                  text: formatTimestamp(),
                                  style: const TextStyle(
                                      color: Colors.transparent)),
                            ],
                          ),
                        ),
                      ),

                      //real additionalInfo
                      Positioned(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatTimestamp(),
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorConstants.dialogHeadingColor,
                              ),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            lastMessage()
                          ],
                        ),
                        right: 8.0,
                        bottom: 4.0,
                      )
                    ],
                  ),
                ),
        ),
      );

      //   Align(
      //   alignment: widget.senderId == FirebaseServices.firebaseUser!.uid
      //       ? Alignment.topRight
      //       : Alignment.topLeft,
      //   child: Padding(
      //     padding:
      //         const EdgeInsets.only(left: 50, right: 10, top: 10, bottom: 10),
      //     child: Container(
      //       // height: 100,
      //       decoration: BoxDecoration(
      //         color: ColorConstants.chatBubbleSenderColor,
      //         borderRadius: BorderRadius.only(
      //           bottomLeft: const Radius.circular(12),
      //           bottomRight: const Radius.circular(12),
      //           topLeft: widget.senderId == FirebaseServices.firebaseUser!.uid
      //               ? const Radius.circular(12)
      //               : const Radius.circular(0),
      //           topRight: widget.senderId == FirebaseServices.firebaseUser!.uid
      //               ? const Radius.circular(0)
      //               : const Radius.circular(12),
      //         ),
      //       ),
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Stack(
      //           // crossAxisAlignment: CrossAxisAlignment.start,
      //           // mainAxisAlignment: MainAxisAlignment.start,
      //           children: [
      //             Text(
      //               '${widget.message}   ',
      //               style: TextStyle(
      //                 fontSize: 16,
      //                 color: ColorConstants.lastChatTitleColor,
      //               ),
      //             ),
      //             Text(formatTimestamp(),
      //                 style:
      //                     TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
      //             Positioned(
      //               right: 8.0,
      //               bottom: 4.0,
      //               child: Container(
      //                 color: Colors.red,
      //                 // alignment: Alignment.topRight,
      //                 child: Row(
      //                   mainAxisSize: MainAxisSize.min,
      //                   mainAxisAlignment: MainAxisAlignment.end,
      //                   // crossAxisAlignment: CrossAxisAlignment.end,
      //                   children: [
      //                     Text(
      //                       formatTimestamp(),
      //                       style: TextStyle(
      //                         fontSize: 12,
      //                         color: ColorConstants.dialogHeadingColor,
      //                       ),
      //                     ),
      //                     const SizedBox(
      //                       width: 2,
      //                     ),
      //                     lastMessage()
      //                   ],
      //                 ),
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    }

    return Container();
  }
}
