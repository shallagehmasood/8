import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ImageViewer(),
  ));
}

final channel = IOWebSocketChannel.connect('ws://178.63.171.244:5000');

class ImageViewer extends StatefulWidget {
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  List<String> imageList = [];
  Uint8List? imageData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['type'] == 'list') {
          setState(() {
            imageList = List<String>.from(data['images']);
          });
        } else if (data['type'] == 'image') {
          setState(() {
            imageData = base64Decode(data['data']);
            isLoading = false;
          });
        }
      } catch (e) {
        print('خطا در دریافت داده: $e');
      }
    });
  }

  void requestImage(String name) {
    setState(() {
      isLoading = true;
      imageData = null;
    });
    channel.sink.add(jsonEncode({"request": name}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تصاویر دریافتی")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (imageList.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageList.map((name) {
                  return ElevatedButton(
                    onPressed: () => requestImage(name),
                    child: Text(name),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            if (imageData != null)
              Expanded(
                child: Image.memory(imageData!),
              ),
          ],
        ),
      ),
    );
  }
}
