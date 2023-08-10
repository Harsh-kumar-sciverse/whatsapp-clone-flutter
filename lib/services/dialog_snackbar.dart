import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class DialogAndSnackbar {
  static void showPhoneNumberDialog(BuildContext context, String phoneNumber,
      String countryCode, VoidCallback function) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Text(
              'You entered the phone number:',
              style: TextStyle(
                  color: ColorConstants.dialogHeadingColor,
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 15,
                ),
                Text(
                  '${countryCode} ${phoneNumber}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ColorConstants.dialogMobileNumberColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Is this OK, or would you like to edit the number?',
                  style: TextStyle(
                    color: ColorConstants.dialogHeadingColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            contentPadding: EdgeInsets.only(left: 20, right: 20),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('EDIT'),
              ),
              TextButton(
                onPressed: () {
                  function();
                },
                child: Text('OK'),
              )
            ],
          );
        });
  }

  static void showSnackBar({
    required String title,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(
          milliseconds: 1000,
        ),
        backgroundColor: ColorConstants.appMainColor,
        content: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }

  static void showCircularProgress(BuildContext context, String text) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              // height: 100,
              width: MediaQuery.of(context).size.width - 40,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: ColorConstants.appMainColor,
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    Text(
                      '$text ...',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
