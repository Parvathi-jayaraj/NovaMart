import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate Unique Chat ID
  // String generateChatId({
  //   required String buyerId,
  //   required String sellerId,
  //   required String productId,
  // }) {
  //   return '${buyerId}_${sellerId}_$productId';
  // }

  String generateChatId({
  required String buyerId,
  required String sellerId,
  required String productId,
}) {
  List<String> ids = [buyerId, sellerId];

  ids.sort();

  return '${ids[0]}_${ids[1]}_$productId';
}

  // Send Message
  Future<void> sendMessage({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    String chatId = generateChatId(
      buyerId: buyerId,
      sellerId: sellerId,
      productId: productId,
    );

    MessageModel newMessage = MessageModel(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    // Save Message
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());


    await _firestore.collection('chats').doc(chatId).set({
  'participants': [buyerId, sellerId],
  'buyerId': buyerId,
  'sellerId': sellerId,
  'productId': productId,
  'lastMessage': message,
  'lastMessageTime': Timestamp.now(),
});
  }

  // Get Messages Realtime Stream
  Stream<QuerySnapshot> getMessages({
    required String buyerId,
    required String sellerId,
    required String productId,
  }) {
    String chatId = generateChatId(
      buyerId: buyerId,
      sellerId: sellerId,
      productId: productId,
    );

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}