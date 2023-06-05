import 'dart:convert';
import 'dart:io';

import 'package:pointycastle/asymmetric/api.dart';

import 'client.dart';

import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;

class Server {
  String? name;
  ServerSocket instance;

  RSAPublicKey? public_key;

  String get address => instance.address.address;
  int get port => instance.port;

  List<Client> clients = [];

  Future<crypto.AsymmetricKeyPair>? futureKeyPair;
  crypto.AsymmetricKeyPair? keyPair;

  Server({required this.instance, this.name});

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  String qrData() {
    return json.encode({
      'ip': address,
      'port': port,
    });
  }
}
