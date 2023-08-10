import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/color_constants.dart';
import '../models/chatMessage.dart';
import '../models/user_model.dart';
import '../widget/community_tab.dart';
import '../widget/chats_widget.dart';
import './select_contact.dart';
import '../services/firebase_services.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: ColorConstants.appMainColor,
        //or set color with: Color(0xFF0000FF)
        statusBarIconBrightness: Brightness.light));

    return SafeArea(
      child: DefaultTabController(
        length: 4,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('WhatsApp'),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.search_sharp)),
              IconButton(
                  onPressed: () async {
                    FirebaseServices.signOut();
                  },
                  icon: const Icon(Icons.more_vert)),
            ],
            backgroundColor: ColorConstants.appMainColor,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: ColorConstants.appMainColor,
              // statusBarIconBrightness: Brightness.dark,
            ),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.groups,
                    size: 28,
                  ),
                ),
                Tab(
                    icon: Text(
                  'Chats',
                  style: TextStyle(fontSize: 16),
                )),
                Tab(
                    icon: Text(
                  'Status',
                  style: TextStyle(fontSize: 16),
                )),
                Tab(
                    icon: Text(
                  'Calls',
                  style: TextStyle(fontSize: 16),
                )),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const CommunityTab(),
              Consumer<List<ChatMessage>>(
                  builder: (context, chatMessages, child) {
                List<String> list = [];

                chatMessages.forEach((element) {
                  list.add(element.senderId!);
                  list.add(element.receiverId!);
                });
                List<String> uniqueIds = list.toSet().toList();

                return Consumer<List<UserModel>>(
                    builder: (context, usersList, chat) {
                  return ListView.builder(
                      itemCount: uniqueIds.length,
                      itemBuilder: (context, index) {
                        UserModel user = usersList.firstWhere(
                            (element) => element.uid == uniqueIds[index]);

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ChatScreen.routeName,
                                arguments: {'userId': user.uid!});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 10),
                            child: ChatsWidget(
                              messageFromYou: true,
                              userName: user.uid == FirebaseServices.uid
                                  ? '${user!.name} (You)'
                                  : user.name!,
                              messageStatus: 'delivered',
                              lastMessageText: '',
                              lastMessageTime: Timestamp.now(),
                              lastMessageType: 'text',
                              userImage:
                                  'https://media.istockphoto.com/id/1298261537/vector/blank-man-profile-head-icon-placeholder.jpg?s=612x612&w=0&k=20&c=CeT1RVWZzQDay4t54ookMaFsdi7ZHVFg2Y5v7hxigCA=',
                            ),
                          ),
                        );
                      });
                });
              }),
              Icon(Icons.directions_bike),
              Icon(Icons.directions_bike),
            ],
          ),
          floatingActionButton: CircleAvatar(
            backgroundColor: ColorConstants.floatingButtonColor,
            radius: 30,
            child: IconButton(
              icon: const Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(SelectContact.routeName);
              },
            ),
          ),
        ),
      ),
    );
  }
}
