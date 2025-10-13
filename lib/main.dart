import 'package:flutter/material.dart';
import 'package:websocketchannel/websocketchannel.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
final channel = WebSocketChannel.connect(
  Uri.parse('ws://178.63.171.244:5000'),
);

  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ارسال پیام به سرور')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              final message = jsonEncode({"message": "hello"});
              channel.sink.add(message);
              print("📤 Sent: $message");
            },
            child: Text("ارسال پیام"),
          ),
        ),
      ),
    );
  }
}
