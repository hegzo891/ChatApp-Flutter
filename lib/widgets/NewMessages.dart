import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.isEmpty) return;
    final User? user = FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance.collection("users").doc(user!.uid).get(
    );
    await FirebaseFirestore.instance
        .collection("messages")
        .add({
      "text" : enteredMessage,
      "createdAt" : Timestamp.now(),
      "userid" : user.uid,
      "username" : userdata.data()!["username"],
      "imageUrl" : userdata.data()!["imageUrl"]

    });
    FocusScope.of(context).unfocus();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
                labelText: "Enter a message",
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              ),
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

        ],
      ),
    );
  }
}
