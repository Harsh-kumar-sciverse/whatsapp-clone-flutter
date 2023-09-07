import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'models/user_model.dart';
import 'models/chatMessage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/user_state.dart';
import 'screens/chats_screen.dart';
import 'firebase_options.dart';
import 'constants/color_constants.dart';
import 'screens/verifyNumber.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'widget/no_internet.dart';
import 'screens/profile_screen.dart';
import 'screens/select_contact.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/firebase_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  //   androidProvider: AndroidProvider.playIntegrity,
  // );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor:
        ColorConstants.appMainColor, // navigation bar color
    statusBarColor: ColorConstants.appMainColor, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  ConnectivityResult _connectionStatus = ConnectivityResult.mobile;

  final Connectivity _connectivity = Connectivity();
  Timer? _timer;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await FirebaseServices.updateLastSeen();
      print('''ddd''');
    });
    super.initState();
    print('init state in main.dart');
    WidgetsBinding.instance.addObserver(this);

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print('app life cycle');
    if (state == AppLifecycleState.resumed) {
      //TODO: set status to online here in firestore

      if (FirebaseServices.firebaseUser != null) {
        await FirebaseServices.updateLastSeen();
        _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
          await FirebaseServices.updateLastSeen();
          print('''ddddd''');
        });
        await FirebaseServices.updateUserOnline(true)
            .then((value) => print('updates online'))
            .catchError((error) {
          print('error $error');
        });
      }
    } else {
      //TODO: set status to offline here in firestore
      if (FirebaseServices.firebaseUser != null) {
        FirebaseServices.updateUserOnline(false);
      }
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('disposed');
    _connectivitySubscription.cancel();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (FirebaseServices.firebaseUser != null) {
      await FirebaseServices.updateLastSeen();
      await FirebaseServices.updateUserOnline(true)
          .then((value) => print('updates online'))
          .catchError((error) {
        print('error $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == ConnectivityResult.none) {
      print('connection state in main.dart $_connectionStatus');
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: NoInternet(),
        ),
      );
    }

    return MultiProvider(
      providers: [
        StreamProvider<List<UserModel>>(
          create: (context) => UserModel().users,
          initialData: [],
          catchError: (context, error) {
            return [];
          },
        ),
        StreamProvider<List<ChatMessage>>(
          create: (context) => ChatMessage().chatMessages,
          initialData: [],
          lazy: true,
          catchError: (context, error) {
            return [];
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Whatsapp',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor: ColorConstants.appMainColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: ColorConstants.appMainColor,
              )),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all(ColorConstants.appMainColor))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(ColorConstants.appMainColor),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(
              color: Colors.grey,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorConstants.appMainColor),
            ),
          ),
        ),
        home: UserState(),
        routes: {
          ChatsScreen.routeName: (_) => ChatsScreen(),
          VerifyNumber.routeName: (_) => VerifyNumber(),
          LoginScreen.routeName: (_) => LoginScreen(),
          HomeScreen.routeName: (_) => HomeScreen(),
          ProfileScreen.routeName: (_) => ProfileScreen(),
          SelectContact.routeName: (_) => SelectContact(),
          ChatScreen.routeName: (_) => ChatScreen()
        },
      ),
    );
  }
}
