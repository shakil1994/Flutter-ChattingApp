// @dart=2.9
import 'dart:convert';

import 'package:chat_app/const/const.dart';
import 'package:chat_app/model/chat_message.dart';
import 'package:chat_app/state/state_manager.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailScreen extends ConsumerWidget {
  FirebaseApp app;
  User user;

  DetailScreen({this.app, this.user});

  DatabaseReference offsetRef, chatRef;
  FirebaseDatabase database;

  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, watch) {
    var friendUser = watch(chatUser).state;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${friendUser.firstName} ${friendUser.lastName}'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: friendUser.uid != null
                  ? FirebaseAnimatedList(
                      controller: _scrollController,
                      sort: (DataSnapshot a, DataSnapshot b) =>
                          b.key.compareTo(a.key),
                      reverse: true,
                      query: loadChatContent(context, app),
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        var chatContent = ChatMessage.fromJson(
                            json.decode(json.encode(snapshot.value)));

                        return SizeTransition(
                            sizeFactor: animation,
                            child: chatContent.picture
                                ? chatContent.senderId == user.uid
                                    ? bubbleImageFromUser(chatContent)
                                    : bubbleImageFromFriend(chatContent)
                                : chatContent.senderId == user.uid
                                    ? bubbleTextFromUser(chatContent)
                                    : bubbleTextFromFriend(chatContent));
                      })
                  : Center(child: CircularProgressIndicator()),
            ),
            Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.multiline,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                    controller: _textEditingController,
                  )),
                  IconButton(onPressed: () {}, icon: Icon(Icons.send))
                ]))
          ],
        ),
      )),
    );
  }

  loadChatContent(BuildContext context, FirebaseApp app) {
    database = FirebaseDatabase(app: app);
    offsetRef = database.reference().child('.info/serverTimeOffset');
    chatRef = database.reference()
    .child(CHAT_REF)
    .child(getRoomId(user.uid, context.read(chatUser).state.uid))
    .child(DETAIL_REF);

    return chatRef;

  }
}
