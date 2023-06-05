import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_x/screens/server_chat.dart';
import 'package:share_x/utils/info_box.dart';

import '../models/message.dart';
import '../services/client.dart';
import '../services/server.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  Server? server;

  @override
  void initState() {
    super.initState();
    _initServer();
  }

  void _initServer() async {
    String ip = await NetworkInfo().getWifiIP() ?? '192.168.43.1';
    print(ip);

    try {
      ServerSocket serverSocket =
          await ServerSocket.bind(ip, 6969, shared: true);

      server = Server(instance: serverSocket);
      setState(() {
        server;
      });

      server!.instance.listen(
        (Socket client) async {
          Client? c;

          setState(
            () {
              server!.clients.add(
                c = Client(instance: client),
              );
            },
          );

          c!.keyPair = await c!.getKeyPair();

          c!.subscription = c!.instance!.listen(
            (data) {
              final rawMessage = String.fromCharCodes(data);
              Message message = Message.fromJson(json.decode(rawMessage));

              if (message.type == MessageType.initial) {
                c!.name = message.text;

                c!.message(
                  server!.name ?? 'Server',
                  type: MessageType.initial,
                );
              } else {
                setState(() {
                  c!.messages.add(message);
                });
              }
            },
          );
        },
      );
    } on SocketException catch (e) {
      Navigator.pop(context);
      InfoBox(
        "Open Wifi or Hotspot",
        context: context,
        infoCategory: InfoCategory.error,
      );
    }
  }

  @override
  void dispose() {
    server!.instance.close();
    server = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server'),
        actions: [
          IconButton(
            onPressed: () => _shareQr(context),
            icon: const Icon(Icons.qr_code),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  _shareQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(25),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImage(
                size: 200,
                data: server!.qrData(),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Server Name: ${server?.name ?? '<Anonymous>'}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Server IP: ${server?.address}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Server Port: ${server?.port}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildBody() {
    return server != null && server!.clients.isNotEmpty
        ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: server!.clients.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Client client = server!.clients[index];

                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(server!.name ?? "AnonyMusk"),
                        tileColor: Colors.deepPurple[200],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServerChat(client: client),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const Center(
            child: Text(
              "No Clients Connected",
            ),
          );
  }
}
