import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../constants/color_constants.dart';
import 'package:flutter/material.dart';

class ChatsWidget extends StatelessWidget {
  final bool messageFromYou;
  final String userName;
  final String messageStatus;
  final String lastMessageText;
  final Timestamp lastMessageTime;
  final String lastMessageType;
  final String userImage;
  const ChatsWidget({
    Key? key,
    required this.messageFromYou,
    required this.userName,
    required this.messageStatus,
    required this.lastMessageText,
    required this.lastMessageTime,
    required this.lastMessageType,
    required this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formatTimestamp() {
      final timestampDate = lastMessageTime.toDate();
      final now = DateTime.now();
      final today =
          DateTime(timestampDate.year, timestampDate.month, timestampDate.day);
      final todayTime = DateTime(now.year, now.month, now.day);
      final yesterdayTime = DateTime(now.year, now.month, now.day - 1);

      String formattedTime = DateFormat.jm().format(lastMessageTime.toDate());

      if (today == todayTime) {
        return '${formattedTime.toLowerCase()}';
      } else if (today == yesterdayTime) {
        return 'yesterday';
      }

      var format = DateFormat('d-MMMM-y'); // <- use skeleton here
      return format.format(lastMessageTime.toDate());
    }

    Widget lastMessage(String message) {
      if (!messageFromYou) {
        return Row(
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ColorConstants.dialogMobileNumberColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      } else {
        if (messageStatus == 'seen') {
          return Row(
            children: [
              Image.asset(
                'icons/double-tick.png',
                height: 15,
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        } else if (messageStatus == 'delivered') {
          return Row(
            children: [
              Image.asset(
                'icons/double-tick-grey.png',
                height: 15,
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: Text(
                  lastMessageText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Icon(
                Icons.done,
                color: ColorConstants.singleTickColor,
                size: 17,
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                // width: 200,
                child: Text(
                  lastMessageText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        }
      }
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(userImage),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      color: ColorConstants.lastChatTitleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formatTimestamp(),
                    style: TextStyle(
                      color: ColorConstants.dialogMobileNumberColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              lastMessage(lastMessageText)
            ],
          ),
        )
      ],
    );
  }
}
