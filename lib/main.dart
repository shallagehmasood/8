import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

final channel = IOWebSocketChannel.connect('ws://178.63.171.244:5000');

class ImageViewer extends StatefulWidget {
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  List<String> imageList = [];
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'list') {
        setState(() {
          imageList = List<String>.from(data['images']);
        });
      } else if (data['type'] == 'image') {
        setState(() {
          imageData = base64Decode(data['data']);
        });
      }
    });
  }

  void requestImage(String name) {
    channel.sink.add(jsonEncode({"request": name}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تصاویر دریافتی")),
      body: Column(
        children: [
          if (imageList.isNotEmpty)
            Wrap(
              children: imageList.map((name) {
                return ElevatedButton(
                  onPressed: () => requestImage(name),
                  child: Text(name),
                );
              }).toList(),
            ),
          if (imageData != null) Expanded(child: Image.memory(imageData!)),
        ],
      ),
    );
  }
}
