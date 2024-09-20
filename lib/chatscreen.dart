import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(
    id: "0",
    firstName: "User",
  );

  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "ask me",
    profileImage: "assets/images/download.jpeg", // Replace with the actual path to your image
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ASK ME"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: []),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    _getGeminiResponse(chatMessage);
  }

  void _getGeminiResponse(ChatMessage chatMessage) {
    try {
      String question = chatMessage.text;
      
      gemini.streamGenerateContent(question).listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        if (messages.isNotEmpty && messages.first.user == geminiUser) {
          ChatMessage lastMessage = messages.removeAt(0);
          lastMessage = ChatMessage(
            user: geminiUser,
            createdAt: lastMessage.createdAt,
            text: lastMessage.text + response,
          );
          setState(() {
            messages = [lastMessage, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
