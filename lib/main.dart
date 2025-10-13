import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(BitcoinLiveApp());

class BitcoinLiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قیمت زنده بیت‌کوین',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: BitcoinPriceScreen(),
    );
  }
}

class BitcoinPriceScreen extends StatefulWidget {
  @override
  _BitcoinPriceScreenState createState() => _BitcoinPriceScreenState();
}

class _BitcoinPriceScreenState extends State<BitcoinPriceScreen> {
  late WebSocketChannel channel;
  String price = 'در حال دریافت...';

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@trade'),
    );

    channel.stream.listen((message) {
      final data = json.decode(message);
      final newPrice = double.parse(data['p']).toStringAsFixed(2);
      setState(() {
        price = '\$ $newPrice';
      });
    }, onError: (error) {
      setState(() {
        price = 'خطا در اتصال';
      });
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
      appBar: AppBar(title: Text('قیمت زنده بیت‌کوین')),
      body: Center(
        child: Text(
          'قیمت BTC/USDT:\n$price',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
