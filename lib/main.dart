import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://178.63.171.244:5000'),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketDemo(channel: channel),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  final WebSocketChannel channel;

  WebSocketDemo({required this.channel});

  @override
  _WebSocketDemoState createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  Uint8List? imageData;

  void sendRequest() {
    final message = jsonEncode({"request": "hello.png"});
    widget.channel.sink.add(message);
    print("📤 Sent: $message");
  }

  @override
  void initState() {
    super.initState();
    widget.channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      if (decoded['type'] == 'image') {
        setState(() {
          imageData = base64Decode(decoded['data']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ارتباط با سرور')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: sendRequest,
            child: Text("درخواست تصویر"),
          ),
          if (imageData != null)
            Expanded(child: Image.memory(imageData!)),
        ],
      ),
    );
  }
}
