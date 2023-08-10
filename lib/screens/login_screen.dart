import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../constants/color_constants.dart';
import '../services/dialog_snackbar.dart';
import './verifyNumber.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/loginScreen';
  LoginScreen({Key? key}) : super(key: key);
  String phoneNumber = '';
  String countryCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Verify your phone number',
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
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'WhatsApp will need to verify your phone number.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                child: IntlPhoneField(
                  cursorColor: ColorConstants.appMainColor,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    // border: OutlineInputBorder(
                    //   borderSide: BorderSide(),
                    // ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    // print(phone.completeNumber);
                    phoneNumber = phone.number;
                    countryCode = phone.countryCode.toString();
                    print(phoneNumber);
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: () {
                if (phoneNumber.length != 10) {
                 return;
                } else {
                  DialogAndSnackbar.showPhoneNumberDialog(
                      context, phoneNumber, countryCode, () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        VerifyNumber.routeName, (Route<dynamic> route) => false,
                        arguments: {
                          'phoneNumber': phoneNumber,
                          'countryCode': countryCode
                        });
                  });
                }
              },
              child: const Text('NEXT'),
            ),
          ),
        ],
      ),
    );
  }
}
