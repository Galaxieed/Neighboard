import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/chatmessage_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/chat/chat_function.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MyChat extends StatefulWidget {
  const MyChat({super.key});

  @override
  State<MyChat> createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _globalChatController = TextEditingController();
  bool isLoading = true;
  UserModel? currentUser;
  List<ChatModel> chatModels = [];

  void getCurrentUser() async {
    try {
      currentUser =
          await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 750), () {
        setState(() {
          isLoading = false;
        });
      });
    }

    await Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void sendChat() async {
    if (currentUser != null) {
      ChatModel chatModel = ChatModel(
        chatId: DateTime.now().toIso8601String(),
        senderId: currentUser!.userId,
        senderName: currentUser!.username,
        message: _globalChatController.text,
        timestamp: formattedDate(),
      );
      await ChatFunction.sendChat(chatModel);
      _globalChatController.clear();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _globalChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currentUser == null
              ? const Center(
                  child: Text("Login First"),
                )
              : Column(
                  children: [
                    Text(
                      "Global Chat",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: _firestore.collection("chats").snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final result = snapshot.data!;
                                chatModels = result.docs
                                    .map((e) => ChatModel.fromJson(e.data()))
                                    .toList();
                                chatModels.sort(
                                    (a, b) => b.chatId.compareTo(a.chatId));
                                ChatModel chat = chatModels[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child:
                                          Text(chat.timestamp.split('| ')[1]),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        chat.senderName,
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: chat.senderId ==
                                                  currentUser!.userId
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(chat.message),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    TextField(
                      autofocus: true,
                      controller: _globalChatController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          icon: const Icon(Icons.messenger_outline_sharp),
                          suffixIcon: IconButton(
                              onPressed: () {
                                sendChat();
                              },
                              icon: const Icon(Icons.send_rounded)),
                          hintText: "Message everyone..."),
                    ),
                  ],
                ),
    );
  }
}
