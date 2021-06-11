// @dart=2.9

import 'package:chat_app/const/const.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:chat_app/screen/register_screen.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:page_transition/page_transition.dart';

import 'firebase_utils/firebase_utils.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return PageTransition(
                child: RegisterScreen(
                    app: app,
                    user:
                        FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);
            break;

          case '/detail':
            return PageTransition(
                child: DetailScreen(
                    app: app,
                    user:
                    FirebaseAuth.FirebaseAuth.instance.currentUser ?? null),
                type: PageTransitionType.fade,
                settings: settings);
            break;

          default:
            return null;
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

  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.chat), text: "Chat"),
    Tab(icon: Icon(Icons.people), text: "Friend")
  ];

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);

    database = FirebaseDatabase(app: widget.app);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      processLogin(this.context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        bottom: new TabBar(
            isScrollable: false,
            unselectedLabelColor: Colors.black45,
            labelColor: Colors.white,
            tabs: tabs,
            controller: _tabController),
      ),
      body: isUserInit
          ? TabBarView(
              controller: _tabController,
              children: tabs.map((Tab tab) {
                if (tab.text == 'Chat') {
                  return loadChatList(database, _chatListRef);
                } else {
                  return loadPeople(database, _peopleRef);
                }
              }).toList())
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void processLogin(BuildContext context) async {
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    /** If not login */
    if (user == null) {
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()])
          .then((fbUser) async => {
                /** refresh state */
                await _checkLoginState(this.context)
              })
          .catchError((e) {
            if (e is PlatformException) {
              if (e.code == FirebaseAuthUi.kUserCancelledError) {
                showOnlySnackBar(this.context, 'User cancelled login');
              } else {
                showOnlySnackBar(this.context, '${e.message ?? 'Unk Error'}');
              }
            }
          });
    }
    /** Already login */
    else {
      await _checkLoginState(this.context);
    }
  }

  Future<FirebaseAuth.User> _checkLoginState(BuildContext context) async {
    if (FirebaseAuth.FirebaseAuth.instance.currentUser != null) {
      /** Already Login, get Token */
      FirebaseAuth.FirebaseAuth.instance.currentUser
          .getIdToken()
          .then((token) async => {
                _peopleRef = database.reference().child(PEOPLE_REF),
                _chatListRef = database
                    .reference()
                    .child(CHATLIST_REF)
                    .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid),

                /** Load Information */
                _peopleRef
                    .child(FirebaseAuth.FirebaseAuth.instance.currentUser.uid)
                    .once()
                    .then((snapshot) => {
                          if (snapshot != null && snapshot.value != null)
                            {
                              setState(() {
                                isUserInit = true;
                              })
                            }
                          else
                            {
                              setState(() {
                                isUserInit = true;
                              }),
                              Navigator.pushNamed(this.context, "/register")
                            }
                        })
              });
    }

    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }
}
