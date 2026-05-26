import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;
final currentUserId =
    FirebaseAuth
        .instance
        .currentUser!
        .uid;
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


              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                //title: Text(otherUserId),
                title: Text(

  currentUserId == chat['buyerId']

      ? chat['sellerName']

      : chat['buyerName'],
),

                subtitle:
                    Text(data['lastMessage'] ?? ''),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),

                onTap: () {

                  

                  String buyerId = data['buyerId'];
String sellerId = data['sellerId'];

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverName:

    currentUserId == data['buyerId']

        ? data['sellerName']

        : data['buyerName'],
                        buyerId: buyerId,
                        sellerId: sellerId,
                        productId: data['productId'],

                        
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