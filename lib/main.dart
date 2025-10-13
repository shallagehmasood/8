import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() => runApp(FileWatcherApp());

class FileWatcherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فایل‌های جدید',
      theme: ThemeData.dark(),
      home: FileListScreen(),
    );
  }
}

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  late WebSocketChannel channel;
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
      Uri.parse('ws://178.63.171.244:5000'), // برای شبیه‌ساز اندروید
    );

    channel.stream.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'new_file') {
        setState(() {
          files.add(data['name']);
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فایل‌های جدید')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text(files[index]),
          );
        },
      ),
    );
  }
}
