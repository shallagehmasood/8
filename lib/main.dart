import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(WebSocketTestApp());

class WebSocketTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تست وب‌سوکت',
      theme: ThemeData.dark(),
      home: WebSocketScreen(),
    );
  }
}

class WebSocketScreen extends StatefulWidget {
  @override
  _WebSocketScreenState createState() => _WebSocketScreenState();
}

class _WebSocketScreenState extends State<WebSocketScreen> {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  String receivedMessage = 'منتظر پیام...';

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
      Uri.parse('ws://178.63.171.244:5000'), // برای شبیه‌ساز اندروید
    );

    channel.stream.listen((message) {
      setState(() {
        receivedMessage = message;
      });
    }, onError: (error) {
      setState(() {
        receivedMessage = 'خطا در اتصال: $error';
      });
    }, onDone: () {
      setState(() {
        receivedMessage = 'اتصال بسته شد';
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ارتباط با سرور وب‌سوکت')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'پیام دریافتی:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              receivedMessage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(height: 40),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'ارسال پیام به سرور',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('ارسال'),
            ),
          ],
        ),
      ),
    );
  }
}
