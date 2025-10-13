import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final channel = IOWebSocketChannel.connect('ws://178.63.171.244:5000');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('تصویر از VPS')),
        body: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final bytes = snapshot.data as Uint8List;
              return Image.memory(bytes);
            } else {
              return Center(child: Text('در انتظار تصویر...'));
            }
          },
        ),
      ),
    );
  }
}
