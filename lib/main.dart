import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EchoTest(channel: channel),
    );
  }
}

class EchoTest extends StatefulWidget {
  final WebSocketChannel channel;
  EchoTest({required this.channel});

  @override
  _EchoTestState createState() => _EchoTestState();
}

class _EchoTestState extends State<EchoTest> {
  final _controller = TextEditingController();
  String? _received;

  @override
  void initState() {
    super.initState();
    widget.channel.stream.listen((message) {
      setState(() {
        _received = message;
      });
    }, onError: (error) {
      setState(() {
        _received = 'خطا: $error';
      });
    }, onDone: () {
      setState(() {
        _received = 'اتصال بسته شد';
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Echo WebSocket Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'پیام برای ارسال'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('ارسال'),
            ),
            SizedBox(height: 20),
            Text('پاسخ دریافتی:'),
            Text(_received ?? 'هنوز پاسخی دریافت نشده'),
          ],
        ),
      ),
    );
  }
}
