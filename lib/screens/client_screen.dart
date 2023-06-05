import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_x/screens/client_chat.dart';
import 'package:share_x/services/client.dart';
import 'package:share_x/utils/info_box.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple.shade400,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple.shade400,
                    width: 1,
                  ),
                ),
                hintText: 'IP Address',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: portController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple.shade400,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple.shade400,
                    width: 1,
                  ),
                ),
                hintText: 'Port',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () =>
                  _connect(ipController.text, int.parse(portController.text)),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 50),
              ),
              child: const Text('Connect'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            IconButton(
              onPressed: () => _scanQr(context),
              icon: const Icon(
                size: 30,
                color: Colors.deepPurple,
                Icons.qr_code_scanner,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _scanQr(BuildContext context) async {
    MobileScannerController mobileScannerController = MobileScannerController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(50),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              child: MobileScanner(
                controller: mobileScannerController,
                fit: BoxFit.cover,
                onDetect: (BarcodeCapture capture) async {
                  mobileScannerController.stop();
                  Future.delayed(
                    const Duration(seconds: 1),
                  );
                  mobileScannerController.dispose();
                  Navigator.pop(ctx);
                  dynamic data = json.decode(capture.barcodes.first.rawValue!);
                  _connect(data['ip'], data['port']);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _connect(String ip, int port) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientChat(ip: ip, port: port),
      ),
    );
  }
}
