import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(BitcoinPriceApp());

class BitcoinPriceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Price',
      theme: ThemeData.dark(),
      home: BitcoinPriceScreen(),
    );
  }
}

class BitcoinPriceScreen extends StatefulWidget {
  @override
  _BitcoinPriceScreenState createState() => _BitcoinPriceScreenState();
}

class _BitcoinPriceScreenState extends State<BitcoinPriceScreen> {
  final channel = IOWebSocketChannel.connect(
    Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@trade'),
  );

  String price = '...';

  @override
  void initState() {
    super.initState();
    channel.stream.listen((data) {
      final match = RegExp(r'"p":"(\d+\.\d+)"').firstMatch(data);
      if (match != null) {
        setState(() {
          price = match.group(1)!;
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
      appBar: AppBar(title: Text('قیمت لحظه‌ای بیت‌کوین')),
      body: Center(
        child: Text(
          '$price USD',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
