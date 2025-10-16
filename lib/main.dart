import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Receiver',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImagePage(userId: '11111'),
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
  List<String> imageUrls = [];
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    fetchMissedImages();
  }

  void connectWebSocket() {
    channel = IOWebSocketChannel.connect('ws://178.63.171.244:3000');
    channel.sink.add(widget.userId);
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final url = data['image'];
      setState(() {
        imageUrls.add(url);
      });
    });
  }

  Future<void> fetchMissedImages() async {
    try {
      final res = await http.get(
        Uri.parse(
          'http://178.63.171.244:5000/get-ready-images?userId=${widget.userId}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final urls = List<String>.from(data['images']);
        setState(() {
          imageUrls.addAll(urls);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تصاویر دریافتی'),
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
          ),
        ],
      ),
      body: imageUrls.isEmpty
          ? Center(child: Text('هنوز تصویری دریافت نشده'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final url = imageUrls[index];
                return GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: InteractiveViewer(child: Image.network(url)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Text('خطا در بارگذاری تصویر');
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
