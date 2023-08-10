import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';
import '../models/user_model.dart';
import '../constants/color_constants.dart';
import '../services/firebase_services.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firebase_services.dart';
import '../models/chatMessage.dart';
import '../widget/message_bubble.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/ChatScreen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String userId = '';
  final textController = TextEditingController();
  bool emojiContainerVisibility = false;
  final ScrollController? _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  bool visible = true;
  bool _isWriting = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    userId = arg['userId'];
  }

  final selfUserId = FirebaseServices.firebaseUser!.uid;
  List<String> emojis = [
    'https://assets2.lottiefiles.com/packages/lf20_xXkYbs.json',
    'https://assets2.lottiefiles.com/packages/lf20_Mq35jq.json',
    'https://assets2.lottiefiles.com/packages/lf20_FyWhBU.json',
    'https://assets2.lottiefiles.com/packages/lf20_I54hLY.json',
    'https://assets2.lottiefiles.com/packages/lf20_d1GoCb.json',
    'https://assets2.lottiefiles.com/packages/lf20_ouxycdmg.json',
    'https://assets2.lottiefiles.com/packages/lf20_k6hrfq79.json',
    'https://assets2.lottiefiles.com/packages/lf20_lt5xlugl.json',
    'https://assets2.lottiefiles.com/packages/lf20_ig01iqrv.json',
    'https://assets2.lottiefiles.com/packages/lf20_RfD6Lb.json',
    'https://assets2.lottiefiles.com/packages/lf20_ply8ftem.json',
    'https://assets2.lottiefiles.com/packages/lf20_zv632k3i.json',
    'https://assets7.lottiefiles.com/packages/lf20_1xoQN5jlXh.json',
    'https://assets7.lottiefiles.com/packages/lf20_lt5xlugl.json',
    'https://assets7.lottiefiles.com/packages/lf20_ITOCol.json',
    'https://assets7.lottiefiles.com/packages/lf20_RfD6Lb.json',
    'https://assets1.lottiefiles.com/packages/lf20_nf8pbyd0.json',
  ];
  List<String> loveEmojis = [
    'https://assets1.lottiefiles.com/packages/lf20_iOEPwP.json',
    'https://assets1.lottiefiles.com/private_files/lf30_khpg8oqv.json',
    'https://assets1.lottiefiles.com/packages/lf20_sjrpgwkd.json',
    'https://assets7.lottiefiles.com/packages/lf20_TVlHaV.json',
    'https://assets7.lottiefiles.com/packages/lf20_mPRD2y.json',
    'https://assets7.lottiefiles.com/packages/lf20_vrdrHK.json',
    'https://assets8.lottiefiles.com/packages/lf20_9wzu5dlu.json'
  ];
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  String? swipedMessageId;
  Map<String, dynamic>? swipedMessage;
  int _desiredItemIndex = -2;
  @override
  Widget build(BuildContext context) {
    print('swiped msg id $swipedMessageId');
    return Consumer<List<UserModel>>(builder: (context, users, child) {
      UserModel user = users.firstWhere((element) {
        return element.uid == userId!;
      });

      String userStatus() {
        if (user!.isOnline == true) {
          if (user.typingStatus!['isTyping'] == true &&
              user.typingStatus!['typingTo'] == selfUserId) {
            return 'typing...';
          } else {
            return 'online';
          }
        } else {
          final timestampDate = user!.lastSeen!.toDate();
          final now = DateTime.now();
          final today = DateTime(
              timestampDate.year, timestampDate.month, timestampDate.day);
          final todayTime = DateTime(now.year, now.month, now.day);
          final yesterdayTime = DateTime(now.year, now.month, now.day - 1);

          String formattedTime = DateFormat.jm().format(timestampDate);

          if (todayTime == today) {
            final seconds = now.difference(timestampDate);
            final minutes = now.difference(timestampDate);
            final hours = now.difference(timestampDate);
            print(minutes.inMinutes);
            // final minutes = todayTime.minute;
            // final hours = todayTime.hour;
            if (seconds.inSeconds < 60) {
              return 'last seen ${seconds.inSeconds} second ago';
            } else if (minutes.inMinutes < 60 && minutes.inMinutes >= 1) {
              return 'last seen ${minutes.inMinutes} minute ago';
            } else if (minutes.inMinutes >= 60 && minutes.inMinutes <= 180) {
              return 'last seen ${hours.inHours} hour ago';
            } else {
              return 'last seen today at $formattedTime';
            }
          } else if (today == yesterdayTime) {
            return 'last seen yesterday at $formattedTime';
          } else {
            var format = DateFormat('d MMMM y'); // <- use skeleton here
            // return format.format(widget.orderDate.toDate());
            return 'last seen at ${format.format(timestampDate)}';
          }
        }
      }

      if (_isWriting == true) {
        FirebaseServices.updateTypingStatus(
            isTyping: true, typingTo: user.uid!);
      }

      return WillPopScope(
        onWillPop: () async {
          if (emojiContainerVisibility == true) {
            setState(() {
              emojiContainerVisibility = false;
            });
            return false;
          } else {
            // You can do some work here.
            // Returning true allows the pop to happen, returning false prevents it.
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: ColorConstants.chatBackgroundColor,
          appBar: AppBar(
            leadingWidth: 70,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.arrow_back),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: ColorConstants.circleAvatarBackColor,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            // actions: [
            //   user.uid == selfUserId
            //       ? Container()
            //       : IconButton(
            //           onPressed: () {}, icon: const Icon(Icons.videocam)),
            //   user.uid == selfUserId
            //       ? Container()
            //       : IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            //   IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
            // ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.uid == selfUserId
                    ? user.name! + ' (You)'
                    : user.name!),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  user.uid == selfUserId ? 'Message yourself' : userStatus(),
                  style: TextStyle(
                      color: ColorConstants.totalContactColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          bottomSheet: swipedMessage != null
              ? Container(
                  color: ColorConstants.chatBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 110,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 0,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 50,
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color:
                                            ColorConstants.replyBackgroundColor,
                                        gradient: LinearGradient(stops: const [
                                          0.02,
                                          0.02
                                        ], colors: [
                                          ColorConstants.replyBorderColor,
                                          ColorConstants.replyBackgroundColor,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  swipedMessage!['senderName'],
                                                  style: TextStyle(
                                                    color: ColorConstants
                                                        .replyBorderColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    // FocusScope.of(context)
                                                    //     .requestFocus(focus2);
                                                    setState(() {
                                                      swipedMessage = null;
                                                      if (emojiContainerVisibility ==
                                                          true) {
                                                        emojiContainerVisibility =
                                                            false;
                                                      }
                                                      // if (focus1.hasFocus) {
                                                      //   focus1.unfocus();
                                                      // }
                                                      // FocusScope.of(context)
                                                      //     .requestFocus(focus2);
                                                    });
                                                    // FocusScope.of(context)
                                                    //     .requestFocus(focus2);
                                                    // FocusScope.of(context)
                                                    //     .requestFocus(focus2);
                                                  },
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color: ColorConstants
                                                        .replyIconColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            swipedMessage!['messageType'] ==
                                                    'emoji'
                                                ? const Icon(
                                                    Icons.image,
                                                    size: 10,
                                                  )
                                                : Text(
                                                    swipedMessage!['message'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: ColorConstants
                                                          .dialogHeadingColor,
                                                      fontSize: 14,
                                                      // fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        emojiContainerVisibility == true
                                            ? IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    emojiContainerVisibility =
                                                        false;
                                                    FocusScope.of(context)
                                                        .requestFocus(focus1);
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.keyboard_alt_outlined,
                                                  color: ColorConstants
                                                      .communityColor,
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    emojiContainerVisibility =
                                                        true;
                                                  });
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                icon: Icon(
                                                  Icons.emoji_emotions_outlined,
                                                  color: ColorConstants
                                                      .communityColor,
                                                ),
                                              ),
                                        Expanded(
                                          child: TextFormField(
                                            focusNode: focus1,
                                            autofocus: true,
                                            cursorColor: ColorConstants
                                                .floatingButtonColor,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                            controller: textController,
                                            onTap: () {
                                              setState(() {
                                                FocusScope.of(context)
                                                    .requestFocus(focus1);
                                                if (emojiContainerVisibility ==
                                                    true) {
                                                  emojiContainerVisibility =
                                                      false;
                                                }
                                                FocusScope.of(context)
                                                    .requestFocus(focus1);
                                              });
                                            },
                                            onFieldSubmitted: (v) {
                                              FocusScope.of(context)
                                                  .requestFocus(focus1);
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Message',
                                              hintStyle: TextStyle(
                                                  color: ColorConstants
                                                      .dialogHeadingColor,
                                                  fontWeight: FontWeight.w400),
                                              focusedBorder: InputBorder.none,
                                            ),
                                            onChanged: (v) async {
                                              if (!_isWriting) {
                                                _isWriting = true;
                                                setState(() {});
                                                Future.delayed(
                                                        Duration(seconds: 2))
                                                    .whenComplete(() {
                                                  _isWriting = false;
                                                  FirebaseServices
                                                      .updateTypingStatus(
                                                          isTyping: false,
                                                          typingTo: '');
                                                  setState(() {});
                                                });
                                              }
                                            },
                                            onEditingComplete: () {
                                              // FirebaseServices
                                              //     .updateTypingStatus(
                                              //   isTyping: false,
                                              //   typingTo: '',
                                              // );
                                            },
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Transform.rotate(
                                              angle: 10,
                                              child: IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.attachment,
                                                    color: ColorConstants
                                                        .communityColor,
                                                  )),
                                            ),
                                            IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.camera_alt,
                                                  color: ColorConstants
                                                      .communityColor,
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  ColorConstants.selectContactBackColor,
                              child: textController.text.isEmpty
                                  ? const Icon(
                                      Icons.mic,
                                      size: 22,
                                      color: Colors.white,
                                    )
                                  : InkWell(
                                      onTap: () {
                                        if (swipedMessage != null) {
                                          FirebaseServices.sendRepliedMessage(
                                            message: textController.text,
                                            senderId: FirebaseServices
                                                .firebaseUser!.uid,
                                            messageStatus:
                                                user.uid == selfUserId
                                                    ? 'seen'
                                                    : 'sent',
                                            messageType: 'text',
                                            receiverId: user.uid!,
                                            repliedMessageId:
                                                swipedMessage!['messageId'],
                                            repliedMessageSenderId:
                                                swipedMessage!['senderId'],
                                            repliedMessage:
                                                swipedMessage!['message'],
                                            repliedMessageType:
                                                swipedMessage!['messageType'],
                                          ).then((value) {
                                            setState(() {
                                              swipedMessage = null;
                                              textController.text = '';
                                            });
                                          });
                                        } else {
                                          FirebaseServices.sendMessage(
                                            message: textController.text,
                                            senderId: FirebaseServices
                                                .firebaseUser!.uid,
                                            messageStatus:
                                                user.uid == selfUserId
                                                    ? 'seen'
                                                    : 'sent',
                                            messageType: 'text',
                                            receiverId: user.uid!,
                                          ).then((value) {
                                            setState(() {
                                              textController.text = '';
                                            });
                                          });
                                        }
                                      },
                                      child: const Icon(
                                        Icons.send,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: emojiContainerVisibility,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                              color: ColorConstants.emojiBackgroundColor,
                              border: Border(
                                  top: BorderSide(
                                color: ColorConstants.emojiBorderColor,
                                width: 1,
                              ))),
                          child: DefaultTabController(
                            length: 4,
                            child: Column(
                              children: [
                                TabBar(
                                  indicatorColor:
                                      ColorConstants.selectContactBackColor,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  unselectedLabelColor:
                                      ColorConstants.communityColor,
                                  labelColor: ColorConstants.selectedEmojiColor,
                                  tabs: const [
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.clock,
                                        size: 20,
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(
                                        Icons.emoji_emotions_outlined,
                                      ),
                                    ),
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.heart,
                                      ),
                                    ),
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.car,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: loveEmojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: loveEmojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              loveEmojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  color: ColorConstants.chatBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 0,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Row(
                                  children: [
                                    emojiContainerVisibility == true
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                emojiContainerVisibility =
                                                    false;
                                                FocusScope.of(context)
                                                    .requestFocus(focus2);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.keyboard_alt_outlined,
                                              color:
                                                  ColorConstants.communityColor,
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                emojiContainerVisibility = true;
                                              });
                                              // FocusScope.of(context).unfocus();
                                              if (focus1.hasFocus) {
                                                focus1.unfocus();
                                              } else {
                                                focus2.unfocus();
                                              }
                                            },
                                            icon: Icon(
                                              Icons.emoji_emotions_outlined,
                                              color:
                                                  ColorConstants.communityColor,
                                            ),
                                          ),
                                    Expanded(
                                      child: TextFormField(
                                        focusNode: focus2,
                                        autofocus: true,
                                        cursorColor:
                                            ColorConstants.floatingButtonColor,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        controller: textController,
                                        onTap: () {
                                          setState(() {
                                            if (emojiContainerVisibility ==
                                                true) {
                                              emojiContainerVisibility = false;
                                            }
                                            FocusScope.of(context)
                                                .requestFocus(focus2);
                                          });
                                        },
                                        onFieldSubmitted: (v) {
                                          // FocusScope.of(context)
                                          //     .requestFocus(focus);
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Message',
                                          hintStyle: TextStyle(
                                              color: ColorConstants
                                                  .dialogHeadingColor,
                                              fontWeight: FontWeight.w400),
                                          focusedBorder: InputBorder.none,
                                        ),
                                        onChanged: (v) async {
                                          if (!_isWriting) {
                                            _isWriting = true;
                                            setState(() {});
                                            Future.delayed(Duration(seconds: 2))
                                                .whenComplete(() {
                                              _isWriting = false;
                                              FirebaseServices
                                                  .updateTypingStatus(
                                                      isTyping: false,
                                                      typingTo: '');
                                              setState(() {});
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Transform.rotate(
                                          angle: 10,
                                          child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.attachment,
                                                color: ColorConstants
                                                    .communityColor,
                                              )),
                                        ),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color:
                                                  ColorConstants.communityColor,
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  ColorConstants.selectContactBackColor,
                              child: textController.text.isEmpty
                                  ? const Icon(
                                      Icons.mic,
                                      size: 22,
                                      color: Colors.white,
                                    )
                                  : InkWell(
                                      onTap: () {
                                        FirebaseServices.sendMessage(
                                          message: textController.text,
                                          senderId: FirebaseServices
                                              .firebaseUser!.uid,
                                          messageStatus: user.uid == selfUserId
                                              ? 'seen'
                                              : 'sent',
                                          messageType: 'text',
                                          receiverId: user.uid!,
                                        ).then((value) {
                                          setState(() {
                                            textController.text = '';
                                          });
                                        });
                                      },
                                      child: const Icon(
                                        Icons.send,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: emojiContainerVisibility,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                              color: ColorConstants.emojiBackgroundColor,
                              border: Border(
                                  top: BorderSide(
                                color: ColorConstants.emojiBorderColor,
                                width: 1,
                              ))),
                          child: DefaultTabController(
                            length: 4,
                            child: Column(
                              children: [
                                TabBar(
                                  indicatorColor:
                                      ColorConstants.selectContactBackColor,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  unselectedLabelColor:
                                      ColorConstants.communityColor,
                                  labelColor: ColorConstants.selectedEmojiColor,
                                  tabs: const [
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.clock,
                                        size: 20,
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(
                                        Icons.emoji_emotions_outlined,
                                      ),
                                    ),
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.heart,
                                      ),
                                    ),
                                    Tab(
                                      icon: FaIcon(
                                        FontAwesomeIcons.car,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: loveEmojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: loveEmojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              loveEmojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                      GridView.builder(
                                        itemCount: emojis.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              FirebaseServices.sendMessage(
                                                message: emojis[index],
                                                senderId: FirebaseServices
                                                    .firebaseUser!.uid,
                                                messageStatus:
                                                    user.uid == selfUserId
                                                        ? 'seen'
                                                        : 'sent',
                                                messageType: 'emoji',
                                                receiverId: user.uid!,
                                              );
                                            },
                                            child: Lottie.network(
                                              emojis[index],
                                              animate: false,
                                              repeat: false,
                                              height: 20,
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          body:
              Consumer<List<ChatMessage>>(builder: (context, messages, child) {
            List<ChatMessage> messagesList = messages
                .where((element) =>
                    (element.receiverId == user.uid &&
                        element.senderId ==
                            FirebaseServices.firebaseUser!.uid) ||
                    (element.receiverId == FirebaseServices.firebaseUser!.uid &&
                        element.senderId == user.uid))
                .toList();

            List<ChatMessage> sentMessages = messagesList
                .where((element) =>
                    element.messageStatus == 'sent' &&
                    element.senderId != FirebaseServices.firebaseUser!.uid)
                .toList();

            sentMessages.forEach((element) {
              FirebaseServices.updateMessageStatus(doc: element.messageId);
            });

            return Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  padding: EdgeInsets.only(
                      bottom: emojiContainerVisibility ? 260 : 60),
                  itemCount: messagesList.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    // int? indexx;
                    return SwipeTo(
                      key: Key(messagesList[index].messageId!),
                      child: InkWell(
                        onTap: () {
                          if (messagesList[index].isRepliedMessage == false) {
                            return;
                          } else {
                            _desiredItemIndex = messagesList.indexWhere(
                                (element) =>
                                    messagesList[index].repliedMessageId ==
                                    element.messageId);
                            setState(() {});
                            print(_desiredItemIndex);

                            if (_desiredItemIndex == -1) {
                              return;
                            } else {
                              setState(() {
                                visible = true;
                              });
                              Timer(Duration(seconds: 3), () {
                                print(
                                    "Yeah, this line is printed after 3 seconds");
                                setState(() {
                                  visible = false;
                                });
                              });
                              itemScrollController.scrollTo(
                                  index: _desiredItemIndex!,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastOutSlowIn);

                              // print('this is replied msg');
                            }
                          }
                        },
                        child: AnimatedContainer(
                          color: _desiredItemIndex == index
                              ? visible
                                  ? Colors.blue.shade200
                                  : Colors.transparent
                              : Colors.transparent,
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(seconds: 1),
                          child: ChatLayout(
                            key: Key(messagesList[index].messageId!),
                            message: messagesList[index].message!,
                            senderId: messagesList[index].senderId!,
                            receiverId: messagesList[index].receiverId!,
                            messageType: messagesList[index].messageType!,
                            time: messagesList[index].time!,
                            messageStatus: messagesList[index].messageStatus!,
                            messageId: messagesList[index].messageId!,
                            swipedMessage: messagesList[index].repliedMessage!,
                            swipedMessageSenderName:
                                messagesList[index].repliedMessageSenderId ==
                                        selfUserId
                                    ? 'You'
                                    : user!.name!,
                            swipedMessageType:
                                messagesList[index].repliedMessageType!,
                            isSwipedMessage:
                                messagesList[index].isRepliedMessage!,
                          ),
                        ),
                      ),
                      onRightSwipe: () {
                        setState(() {
                          if (emojiContainerVisibility == true) {
                            emojiContainerVisibility = false;
                          }

                          // FocusScope.of(context).requestFocus(focus);
                          swipedMessageId = messagesList[index].messageId!;
                          swipedMessage = {
                            'message': messagesList[index].message!,
                            'messageId': messagesList[index].messageId!,
                            'senderId': messagesList[index].senderId!,
                            'messageType': messagesList[index].messageType!,
                            'senderName':
                                messagesList[index].senderId! == selfUserId
                                    ? 'You'
                                    : user!.name
                          };
                          // FocusScope.of(context).requestFocus(focus1);
                          print('alabaaaa');
                          // if (swipedMessage != null) {
                          //   print('nnnn');
                          //   if (focus2.hasFocus) {
                          //     focus2.unfocus();
                          //   }
                          //   FocusScope.of(context).requestFocus(focus1);
                          // } else {
                          //   FocusScope.of(context).requestFocus(focus2);
                          // }
                        });
                      },
                    );
                  }),
            );
          }),
        ),
      );
    });
  }
}
