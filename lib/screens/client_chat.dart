import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:share_x/models/message.dart';
import 'package:share_x/services/client.dart';

class ClientChat extends StatefulWidget {
  String ip;
  int port;

  ClientChat({super.key, required this.ip, required this.port});

  @override
  State<ClientChat> createState() => _ClientChatState();
}

class _ClientChatState extends State<ClientChat> {
  Client client = Client();

  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  RSAPrivateKey? privateKey;

  @override
  void initState() {
    _initClient();

    super.initState();
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
  }

  _initClient() async {
    await client.connect(widget.ip, widget.port);
    client.message(
      client.name ?? 'Client',
      type: MessageType.initial,
    );

    client.instance!.listen(
      (data) {
        final rawMessage = String.fromCharCodes(data);
        Message message = Message.fromString(decrypt(rawMessage, privateKey!));

        if (message.type == MessageType.initial) {
          setState(() {
            client.serverName = message.text;
          });
        } else {
          setState(() {
            client.messages.add(message);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: client.messages.length,
                itemBuilder: (context, index) {
                  Message msg = client.messages[index];

                  return Align(
                    alignment: msg.status == MessageStatus.sent
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg.status == MessageStatus.sent
                            ? Colors.pink[200]
                            : Colors.purple[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        msg.text!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple.shade400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  hintText: 'Type Message',
                  suffixIcon: IconButton(
                    onPressed: () {
                      client.message(messageController.text);
                      setState(() {
                        client.messages;
                      });
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent * 1.03,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                      messageController.clear();
                      print(client.messages);
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
