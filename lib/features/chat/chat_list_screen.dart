import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where(
              'participants',
              arrayContains: currentUser!.uid,
            )
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No chats yet'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final chat =
                  snapshot.data!.docs[index];

              Map<String, dynamic> data =
                  chat.data() as Map<String, dynamic>;

              List participants =
                  data['participants'];

              String otherUserId =
                  participants.firstWhere(
                (id) => id != currentUser!.uid,
              );

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                title: Text(otherUserId),

                subtitle:
                    Text(data['lastMessage'] ?? ''),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),

                onTap: () {

                  // String chatId = chat.id;

                  // List<String> parts =
                  //     chatId.split('_');

                  // String buyerId = parts[0];
                  // String sellerId = parts[1];

                  String buyerId = data['buyerId'];
String sellerId = data['sellerId'];

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        buyerId: buyerId,
                        sellerId: sellerId,
                        productId: data['productId'],

                        otherUserName:
                            otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}