import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'settings_page.dart'; // صفحه تنظیمات

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String userId = "786540582"; // شناسه تستی

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تصاویر لحظه‌ای',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImagePage(userId: userId),
    );
  }
}

class ImagePage extends StatefulWidget {
  final String userId;
  ImagePage({required this.userId});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late WebSocketChannel channel;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    fetchInitialImages();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('ws://178.63.171.244:3000'));
    channel.sink.add(widget.userId);
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final url = data["image"];
      setState(() {
        imageUrls.insert(0, url);
      });
    });
  }

  Future<void> fetchInitialImages() async {
    try {
      final res = await http.get(Uri.parse(
          'http://178.63.171.244:5000/get-ready-images?userId=${widget.userId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          imageUrls = List<String>.from(data["images"].reversed);
        });
      }
    } catch (e) {
      print("خطا در دریافت تصاویر اولیه: $e");
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تصاویر لحظه‌ای'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(userId: widget.userId),
                ),
              );
            },
          )
        ],
      ),
      body: imageUrls.isEmpty
          ? Center(child: Text("هیچ تصویری موجود نیست"))
          : ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final url = imageUrls[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(url),
                );
              },
            ),
    );
  }
}
