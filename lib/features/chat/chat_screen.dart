import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/chat_service.dart';
import '../../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String buyerId;
  final String sellerId;
  final String productId;
  //final String otherUserName;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    //required this.otherUserName,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController _messageController =
      TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    
        title: Text(widget.receiverName),
      ),

      body: Column(
        children: [

          // Messages Area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(
                buyerId: widget.buyerId,
                sellerId: widget.sellerId,
                productId: widget.productId,
              ),

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
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),

                  reverse: false,

                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {

                    Map<String, dynamic> data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    MessageModel message =
                        MessageModel.fromMap(data);

                    bool isMe =
                        message.senderId == currentUser!.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context)
                                      .size
                                      .width *
                                  0.75,
                        ),

                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue
                              : Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.only(
                            topLeft:
                                const Radius.circular(16),

                            topRight:
                                const Radius.circular(16),

                            bottomLeft: Radius.circular(
                                isMe ? 16 : 0),

                            bottomRight: Radius.circular(
                                isMe ? 0 : 16),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,

                          children: [

                            Text(
                              message.message,

                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Colors.black,

                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              DateFormat('hh:mm a').format(
                                message.timestamp.toDate(),
                              ),

                              style: TextStyle(
                                fontSize: 11,

                                color: isMe
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Area
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                ),
              ],
            ),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _messageController,

                    autofocus: true,

                    decoration: InputDecoration(
                      hintText: 'Type a message...',

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: () async {

                    if (_messageController.text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    await _chatService.sendMessage(
                      buyerId: widget.buyerId,
                      sellerId: widget.sellerId,
                      productId: widget.productId,

                      senderId: currentUser!.uid,

                      receiverId:
                          currentUser!.uid ==
                                  widget.buyerId
                              ? widget.sellerId
                              : widget.buyerId,

                      message:
                          _messageController.text.trim(),
                    );

                    _messageController.clear();
                  },

                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}