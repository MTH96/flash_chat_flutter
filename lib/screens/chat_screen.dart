import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
User user = _auth.currentUser;

class ChatScreen extends StatefulWidget {
  static String id = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String msg;
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        msg = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore
                          .collection('messages')
                          .add({'text': msg, 'sender': user.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs;
        List<MessageBubble> messageWidgets = [];

        for (var message in messages.reversed) {
          final messageSender = message.data()['sender'];
          final messageText = message.data()['text'];
          messageWidgets.add(MessageBubble(
              message: messageText,
              sender: messageSender,
              isCurrentUser: user.email == messageSender));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String sender;
  final bool isCurrentUser;
  MessageBubble({this.message, this.sender, this.isCurrentUser});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          isCurrentUser ? 'me' : sender,
          style: TextStyle(color: Colors.grey, fontSize: 12.0),
        ),
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
            topLeft: isCurrentUser ? Radius.circular(30.0) : Radius.zero,
            topRight: !isCurrentUser ? Radius.circular(30.0) : Radius.zero,
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color:
                    isCurrentUser ? Colors.lightBlueAccent : Colors.greenAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topLeft: isCurrentUser ? Radius.circular(30.0) : Radius.zero,
                  topRight:
                      !isCurrentUser ? Radius.circular(30.0) : Radius.zero,
                )),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
        )
      ],
    );
  }
}
