import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Image.asset(
          'images/community_img.png',
          width: 400,
          height: 130,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Introducing communities',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Text(
            'Easily organise your related groups and send announcements. Now, your communities, like neighbourhoods'
            'or schools, can have their own space.',
            textAlign: TextAlign.center,
            style: TextStyle(
                height: 1.5,
                fontSize: 15,
                color: ColorConstants.communityColor),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.only(
                left: 50,
                right: 50,
                top: 12,
                bottom: 12,
              ),
              child: const Text('Start your community'),
            ))
      ],
    );
  }
}
