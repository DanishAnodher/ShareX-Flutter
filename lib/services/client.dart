import 'dart:async';
import 'dart:io';

import 'package:pointycastle/asymmetric/api.dart';
import 'package:share_x/models/message.dart';

import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;

class Client {
  String? name;
  String? serverName;
  RSAPublicKey? public_key;
  Socket? instance;

  StreamSubscription? subscription;

  List<Message> messages = [];

  String get address => instance!.address.address;
  int get port => instance!.port;

  String get remoteAddress => instance!.remoteAddress.address;
  int get remotePort => instance!.remotePort;

  Future<crypto.AsymmetricKeyPair>? futureKeyPair;
  crypto.AsymmetricKeyPair? keyPair;

  Client({this.name, this.instance});

  Future<void> connect(String ip, int port) async {
    if (instance != null) {
      return;
    }

    instance = await Socket.connect(ip, port);
  }

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  void message(String message, {MessageType type = MessageType.regular}) async {
    Message msg = Message(
      message,
      status: MessageStatus.sent,
      type: type,
    );

    messages.add(msg);
    instance!.write(encrypt(msg.toString(), public_key!));
  }

  void close() {
    instance!.close();
  }

  void dispose() {
    instance!.close();
    instance = null;
  }
}
