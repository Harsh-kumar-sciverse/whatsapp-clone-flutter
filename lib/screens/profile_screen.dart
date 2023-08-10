import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/dialog_snackbar.dart';
import './home_screen.dart';
import '../services/firebase_services.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/ProfileScreen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  String phoneNumber = '';
  String countryCode = '';
  String deviceToken = '';
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    phoneNumber = arg['phoneNumber'];
    countryCode = arg['countryCode'];
  }

  @override
  void initState() {
    FirebaseServices.getDeviceToken().then((value) {
      if (value != null) {
        deviceToken = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Verify your number',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              'Please provide your name and an optional profile photo',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 14, color: ColorConstants.dialogMobileNumberColor),
            ),
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              backgroundColor: ColorConstants.cameraBackgroundColor,
              radius: 50,
              child: Icon(
                Icons.camera_alt,
                color: ColorConstants.cameraIconColor,
                size: 50,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: nameController,
              style: TextStyle(
                  color: ColorConstants.appMainColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              cursorColor: ColorConstants.appMainColor,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: const UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorConstants.appMainColor, width: 1.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: ColorConstants.appMainColor, width: 1.0),
                ),
                filled: true,
                hintText: 'Type your name here',
                hintStyle: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              onSaved: (value) {
                // _emailAddress = value!;
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    DialogAndSnackbar.showSnackBar(
                        title: 'Enter your name', context: context);
                  } else {
                    DialogAndSnackbar.showCircularProgress(
                        context, 'Please wait...');
                    String uid = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .set({
                      'name': nameController.text.trim(),
                      'isBlocked': false,
                      'joinedDate': Timestamp.now(),
                      'about': 'Hey there I am using WhatsApp !',
                      'phoneNumber': phoneNumber,
                      'countryCode': countryCode,
                      'ProfilePhoto': '',
                      'uid': uid,
                      'lastSeen': Timestamp.now(),
                      'typingStatus': {'isTyping': false, 'typingTo': ''},
                      'deviceToken': deviceToken,
                      'isOnline': true,
                    }).then((value) {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        HomeScreen.routeName,
                        (route) => false,
                      );
                    }).catchError((error) {
                      DialogAndSnackbar.showSnackBar(
                          title: 'Error occurred!', context: context);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
                child: const Text('NEXT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
