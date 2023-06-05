import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

import '../models/message.dart';
import '../services/client.dart';

class ServerChat extends StatefulWidget {
  Client client;

  ServerChat({super.key, required this.client});

  @override
  State<ServerChat> createState() => _ServerChatState();
}

class _ServerChatState extends State<ServerChat> {
  Client client = Client();
  RSAPrivateKey? privateKey;
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    _initClient();
    super.initState();
  }

  _initClient() async {
    client = widget.client;
    client.message(
      client.name ?? 'Server',
      type: MessageType.initial,
    );

    setState(() {
      client.messages;
    });

    client.subscription!.onData(
      (data) {
        final rawMessage = String.fromCharCodes(data);

        Message message = Message.fromString(decrypt(rawMessage, privateKey!));

        if (message.type == MessageType.initial) {
          setState(() {
            client.serverName = message.text;
          });
        } else {
          client.messages.add(message);

          setState(() {
            client.messages;
          });
        }
        scrollController.animateTo(
          scrollController.position.maxScrollExtent * 1.5,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      },
    );
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
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
              physics: const BouncingScrollPhysics(),
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
            )),
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
                        curve: Curves.linear,
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
