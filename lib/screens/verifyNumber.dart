import 'dart:async';

import 'package:WhatsApp/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import '../constants/color_constants.dart';
import '../services/dialog_snackbar.dart';
import './login_screen.dart';
import './home_screen.dart';
import './profile_screen.dart';

class VerifyNumber extends StatefulWidget {
  static const routeName = '/verifyNumber';
  const VerifyNumber({Key? key}) : super(key: key);

  @override
  State<VerifyNumber> createState() => _VerifyNumberState();
}

class _VerifyNumberState extends State<VerifyNumber> {
  String phoneNumber = '';
  String countryCode = '';
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  bool visible = true;
  var receivedID = '';
  FirebaseAuth auth = FirebaseAuth.instance;

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        setState(() {
          visible = false;
        });
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    phoneNumber = arg['phoneNumber'];
    countryCode = arg['countryCode'];
    phoneLogin(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    countdownTimer!.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void phoneLogin(BuildContext context) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: countryCode + phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then(
            (value) {
              print('Logged In Successfully');
              Navigator.of(context).pushNamedAndRemoveUntil(
                  HomeScreen.routeName, (route) => false);
            },
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            setState(() {
              DialogAndSnackbar.showSnackBar(
                  title: 'Invalid phone number !', context: context);
            });
          } else {
            setState(() {
              DialogAndSnackbar.showSnackBar(
                  title: '${e.code}', context: context);
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          receivedID = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          receivedID = verificationId;
        },
      );
    } catch (e) {
    } finally {}
  }

  Future<void> verifyOTPCode(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: receivedID,
      smsCode: otp,
    );
    String? name;
    await auth.signInWithCredential(credential).then((value) async {
      print('looged in suu');
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference doc =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await doc.get().then((DocumentSnapshot doc) async {
        if (doc.exists) {
          // await FirebaseServices.updateDeviceToken();
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              ProfileScreen.routeName, (route) => false, arguments: {
            'phoneNumber': phoneNumber,
            'countryCode': countryCode
          });
        }
      });
    }).catchError((error) {
      DialogAndSnackbar.showSnackBar(title: 'Wrong OTP !', context: context);
      Navigator.of(context).pop();
      print('error $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    // DialogAndSnackbar.showCircularProgress(context, 'please wait');

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
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'Waiting to automatically detect an SMS sent to\n',
                  style: const TextStyle(
                      color: Colors.black, fontSize: 14, height: 1.5),
                  children: [
                    TextSpan(
                      text: '${countryCode} $phoneNumber ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Wrong number?',
                      style: const TextStyle(color: Colors.blue, fontSize: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginScreen.routeName, (route) => false);
                        },
                    ),
                  ]),
            ),
          ),
          OtpTextField(
            numberOfFields: 6,
            borderColor: ColorConstants.appMainColor,
            focusedBorderColor: ColorConstants.appMainColor,
            disabledBorderColor: ColorConstants.appMainColor,
            enabledBorderColor: ColorConstants.appMainColor,
            showFieldAsBox: false,
            fieldWidth: 20,
            borderWidth: 2.0,
            //runs when a code is typed in
            onCodeChanged: (String code) {
              //handle validation or checks here if necessary
            },
            //runs when every textfield is filled
            onSubmit: (String verificationCode) {
              print('verification id ;$receivedID');
              DialogAndSnackbar.showCircularProgress(context, 'Verifying...');
              verifyOTPCode(verificationCode);
            },
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Enter 6-digit code',
            style: TextStyle(
                color: ColorConstants.dialogMobileNumberColor, fontSize: 14),
          ),
          const SizedBox(
            height: 15,
          ),
          visible
              ? Text(
                  'Did not receive code?',
                  style: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : InkWell(
                  onTap: () {
                    phoneLogin(context);
                    setState(() {
                      myDuration = const Duration(minutes: 2);
                      visible = true;
                      countdownTimer = Timer.periodic(
                          const Duration(seconds: 1), (_) => setCountDown());
                    });
                  },
                  child: const Text(
                    'Did not receive code?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(
            height: 6,
          ),
          Visibility(
            visible: visible,
            child: Text(
              'You may request a new code in $minutes:$seconds',
              style: TextStyle(
                  color: ColorConstants.dialogMobileNumberColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
