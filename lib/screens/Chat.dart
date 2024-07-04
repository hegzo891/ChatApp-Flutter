import 'package:chatapp/widgets/NewMessages.dart';
import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance.currentUser;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.rainbow);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.onPrimaryFixed,
        title: Text("Chats", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),),
        actions: [
          TextButton(onPressed: (){
            firebaseAuth.signOut();
          }, child: Text("Log out", style: TextStyle(color: Colors.white),))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("messages").orderBy("createdAt", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong..."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages found"));
                }

                final loadedMessages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: 40,
                    left: 14,
                    right: 14
                  ),
                  reverse: true,
                  itemCount: loadedMessages.length,
                  itemBuilder: (context, index) {
                    final chatmessage = loadedMessages[index].data();
                    final nextmessage = index+1 < loadedMessages.length? loadedMessages[index+1].data() : null;
                    final currentmessageuserid = chatmessage["userid"];
                    final nextmessageuserid = nextmessage != null ? chatmessage["userid"] : null;
                    final bool nextuserissame = nextmessageuserid == currentmessageuserid;
                    if(nextuserissame){
                      return MessageBubble.next(
                        message: chatmessage["text"],
                        isMe: auth!.uid == currentmessageuserid,

                      );
                    }
                    else{
                      return MessageBubble.first(
                        message: chatmessage["text"],
                        isMe: auth!.uid == currentmessageuserid, userImage: chatmessage["imageUrl"], username: chatmessage["username"],

                      );

                    }
                  },
                );
              },
            )
            ,
          ),         NewMessages(),
        ],
      ),
    );
  }
}
