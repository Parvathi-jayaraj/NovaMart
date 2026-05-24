

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================
  // GENERATE CHAT ID
  // =========================
  String generateChatId({

    required String buyerId,
    required String sellerId,
    required String productId,

  }) {

    List<String> ids = [
      buyerId,
      sellerId,
    ];

    ids.sort();

    return
        '${ids[0]}_${ids[1]}_$productId';
  }

  // =========================
  // SEND MESSAGE
  // =========================
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

    // =========================
    // FETCH USER DATA
    // =========================
    final buyerDoc =
        await _firestore
            .collection('users')
            .doc(buyerId)
            .get();

    final sellerDoc =
        await _firestore
            .collection('users')
            .doc(sellerId)
            .get();

    final buyerName =
        buyerDoc['name'];

    final sellerName =
        sellerDoc['name'];

    // =========================
    // CREATE MESSAGE MODEL
    // =========================
    MessageModel newMessage =
        MessageModel(

      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    // =========================
    // SAVE MESSAGE
    // =========================
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());

    // =========================
    // CREATE / UPDATE CHAT DOC
    // =========================
    await _firestore
        .collection('chats')
        .doc(chatId)
        .set({

      'participants': [
        buyerId,
        sellerId,
      ],

      'buyerId': buyerId,
      'sellerId': sellerId,

      'buyerName': buyerName,
      'sellerName': sellerName,

      'productId': productId,

      'lastMessage': message,

      'lastMessageTime':
          Timestamp.now(),

    });
  }

  // =========================
  // GET MESSAGES
  // =========================
  Stream<QuerySnapshot>
      getMessages({

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