// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat_app/const/const.dart';
import 'package:chat_app/model/chat_info.dart';
import 'package:chat_app/model/chat_message.dart';
import 'package:chat_app/model/user_model.dart';
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
                  IconButton(
                      onPressed: () {
                        offsetRef.once().then((DataSnapshot snapshot) {
                          var offset = snapshot.value as int;
                          var estimatedServerTimeInMs =
                              DateTime.now().millisecondsSinceEpoch + offset;

                          submitChat(context, estimatedServerTimeInMs);
                        });
                        /** Auto scroll chat layout to end  */
                        autoScroll(_scrollController);
                      },
                      icon: Icon(Icons.send))
                ]))
          ],
        ),
      )),
    );
  }

  loadChatContent(BuildContext context, FirebaseApp app) {
    database = FirebaseDatabase(app: app);
    offsetRef = database.reference().child('.info/serverTimeOffset');
    chatRef = database
        .reference()
        .child(CHAT_REF)
        .child(getRoomId(user.uid, context.read(chatUser).state.uid))
        .child(DETAIL_REF);

    return chatRef;
  }

  void submitChat(BuildContext context, int estimatedServerTimeInMs) {
    ChatMessage chatMessage = ChatMessage();
    chatMessage.name = createName(context.read(userLogged).state);
    chatMessage.content = _textEditingController.text;
    chatMessage.timeStamp = estimatedServerTimeInMs;
    chatMessage.senderId = user.uid;

    /** Image and Text */
    chatMessage.picture = false;
    submitChatToFirebase(context, chatMessage, estimatedServerTimeInMs);
  }

  void submitChatToFirebase(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    chatRef.once().then((DataSnapshot snapshot) {
      /** If user already create chat before */
      if (snapshot != null) {
        appendChat(context, chatMessage, estimatedServerTimeInMs);
      } else {
        createChat(context, chatMessage, estimatedServerTimeInMs);
      }
    });
  }

  void createChat(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    /** Create chat info */
    ChatInfo chatInfo = new ChatInfo(
        createId: user.uid,
        friendName: createName(context.read(chatUser).state),
        friendId: context.read(chatUser).state.uid,
        createName: createName(context.read(userLogged).state),
        lastMessage: chatMessage.picture ? "<Image>" : chatMessage.content);

    /** Add on Firebase */
    database.reference().child(CHATLIST_REF).child(user.uid).set(<String,
        ChatInfo>{context.read(chatUser).state.uid: chatInfo}).then((value) {
      /** After success, copy to Friend chat list */
      database
          .reference()
          .child(CHATLIST_REF)
          .child(context.read(chatUser).state.uid)
          .set(<String, ChatInfo>{user.uid: chatInfo}).then((value) {
        /** After success, add on Chat Reference */
        chatRef.push().set(<String, dynamic>{
          'uid': chatMessage.uid,
          'name': chatMessage.name,
          'content': chatMessage.content,
          'pictureLink': chatMessage.pictureLink,
          'picture': chatMessage.picture,
          'senderId': chatMessage.senderId,
          'timeStamp': chatMessage.timeStamp
        }).then((value) {
          /** Clear Text content */
          _textEditingController.text = '';

          /** Auto Scroll */
          autoScrollReverse(_scrollController);
        }).catchError(
            (e) => showOnlySnackBar(context, 'Error submit CHAT REF '));
      }).catchError((e) => showOnlySnackBar(
              context, 'Error can\'t submit Friend Chat List'));
    }).catchError(
        (e) => showOnlySnackBar(context, 'Error can\'t submit User Chat List'));
  }

  void appendChat(BuildContext context, ChatMessage chatMessage,
      int estimatedServerTimeInMs) {
    var update_data = Map<String, dynamic>();
    update_data['lastUpdate'] = estimatedServerTimeInMs;
    if (chatMessage.picture) {
      update_data['lastMessage'] = '<Image>';
    } else {
      update_data['lastMessage'] = chatMessage.content;
    }

    /** Update */
    database
        .reference()
        .child(CHATLIST_REF)
        .child(user.uid) /** You */
        .child(context.read(chatUser).state.uid) /** Friend */
        .update(update_data)
        .then((value) {
      database
          .reference()
          .child(CHATLIST_REF)
          .child(context.read(chatUser).state.uid) /** Friend */
          .child(user.uid) /** You */
          .update(update_data)
          .then((value) {
            /** Add to Chat ref */
        chatRef.push().set(<String, dynamic>{
          'uid': chatMessage.uid,
          'name': chatMessage.name,
          'content': chatMessage.content,
          'pictureLink': chatMessage.pictureLink,
          'picture': chatMessage.picture,
          'senderId': chatMessage.senderId,
          'timeStamp': chatMessage.timeStamp
        }).then((value) {
          /** Clear Text content */
          _textEditingController.text = '';

          /** Auto Scroll */
          autoScrollReverse(_scrollController);
        }).catchError(
                (e) => showOnlySnackBar(context, 'Error submit CHAT REF '));
      })
          .catchError((e) => showOnlySnackBar(
              context, 'Error can\'t update FRIEND CHAT LIST'));
    }).catchError((e) =>
            showOnlySnackBar(context, 'Error can\'t update USER CHAT LIST'));
  }
}
