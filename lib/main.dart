import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final channel = WebSocketChannel.connect(
    Uri.parse(
      'ws://178.63.171.244:5000',
    ), // اگر روی موبایل تست می‌کنی، آدرس IP سرور رو جایگزین کن
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('اتصال WebSocket')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.hasData
                        ? 'پیام دریافتی: ${snapshot.data}'
                        : 'در انتظار پیام...',
                  );
                },
              ),
              TextField(
                onSubmitted: (text) {
                  channel.sink.add(text);
                },
                decoration: InputDecoration(labelText: 'ارسال پیام'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
