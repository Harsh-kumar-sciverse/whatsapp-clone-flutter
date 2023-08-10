import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../constants/color_constants.dart';
import '../services/firebase_services.dart';
import './chat_screen.dart';

class SelectContact extends StatefulWidget {
  static const routeName = '/SelectContact';
  const SelectContact({Key? key}) : super(key: key);

  @override
  State<SelectContact> createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  final userId = FirebaseServices.firebaseUser!.uid;

  @override
  Widget build(BuildContext context) {
    print('userId $userId');
    return Consumer<List<UserModel>>(builder: (context, users, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.appMainColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_outlined),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search_sharp)),
            IconButton(
                onPressed: () async {}, icon: const Icon(Icons.more_vert)),
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Contact',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                '${users.length - 1} contacts',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstants.totalContactColor,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorConstants.selectContactBackColor,
                    child: const Icon(
                      Icons.supervisor_account_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    'New group',
                    style: TextStyle(
                      color: ColorConstants.lastChatTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorConstants.selectContactBackColor,
                    child: const Icon(
                      Icons.groups,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    'New community',
                    style: TextStyle(
                      color: ColorConstants.lastChatTitleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'Contacts on WhatsApp',
                style: TextStyle(
                  color: ColorConstants.dialogHeadingColor,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(ChatScreen.routeName,
                              arguments: {'userId': users[index].uid});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    ColorConstants.circleAvatarBackColor,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userId == users[index].uid
                                        ? users[index].name! + ' (You)'
                                        : users[index].name!,
                                    style: TextStyle(
                                      color: ColorConstants.lastChatTitleColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    userId == users[index].uid
                                        ? 'Message yourself'
                                        : users[index].about!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: ColorConstants
                                          .dialogMobileNumberColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      );
    });
  }
}
