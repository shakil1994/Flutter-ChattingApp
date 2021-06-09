// @dart=2.9
import 'dart:math';

import 'package:chat_app/const/const.dart';
import 'package:chat_app/screen/register_screen.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:page_transition/page_transition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  runApp(ProviderScope(child: MyApp(app: app)));
}

class MyApp extends StatelessWidget {
  FirebaseApp app;

  MyApp({this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return PageTransition(
                child: RegisterScreen(app: app), type: PageTransitionType.fade,
            settings: settings);
            break;

          default: return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final FirebaseApp app;

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  DatabaseReference _peopleRef, _chatListRef;
  FirebaseDatabase database;

  bool isUserInit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    database = FirebaseDatabase(app: widget.app);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      processLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: isUserInit ? Center(child: Text('${widget.app.name}'),) : Center(child: CircularProgressIndicator(),),
    );
  }

  void processLogin(BuildContext context) async {
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    /** If not login */
    if (user == null) {
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()])
          .then((fbUser) async =>
      {
        /** refresh state */
        await _checkLoginState(context)
      })
          .catchError((e) {
        if (e is PlatformException) {
          if (e.code == FirebaseAuthUi.kUserCancelledError) {
            showOnlySnackBar(context, 'User cancelled login');
          } else {
            showOnlySnackBar(context, '${e.message ?? 'Unk Error'}');
          }
        }
      });
    }
    /** Already login */
    else {
      await _checkLoginState(context);
    }
  }

  Future<FirebaseAuth.User> _checkLoginState(BuildContext context) async {
    if (FirebaseAuth.FirebaseAuth.instance.currentUser != null) {
      /** Already Login, get Token */
      FirebaseAuth.FirebaseAuth.instance.currentUser
          .getIdToken()
          .then((token) async =>
      {
        _peopleRef = database.reference().child(PEOPLE_REF),
        _chatListRef = database
            .reference()
            .child(CHATLIST_REF)
            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid),

        /** Load Information */
        _peopleRef
            .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
            .once()
            .then((snapshot) =>
        {
          if (snapshot != null && snapshot.value != null)
            {
              setState(() {
                isUserInit = true;
              })
            }
          else
            {Navigator.pushNamed(context, "/register")}
        })
      });
    }

    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }
}
