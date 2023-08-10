import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import './home_screen.dart';
import './login_screen.dart';

class UserState extends StatefulWidget {
  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        // ignore: missing_return
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.appMainColor,
                ),
              ),
            );
          }
          if (userSnapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Error Occurred...',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }
          if (userSnapshot.connectionState == ConnectionState.active) {
            if (userSnapshot.hasData) {
              return HomeScreen();
            } else {
              print('The user didn\'t login yet in user_state.dart');

              return LoginScreen();
            }
          }
          return const Scaffold(
            body: Center(
              child: Text(
                'Error Occurred...',
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        });
  }
}
