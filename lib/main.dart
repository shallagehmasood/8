import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() => runApp(MyApp());

final symbols = [
  'EURUSD', 'XAUUSD', 'GBPUSD', 'USDJPY', 'USDCHF',
  'AUDUSD', 'AUDJPY', 'CADJPY', 'EURJPY', 'BTCUSD',
  'ETHUSD', 'ADAUSD', 'DowJones', 'NASDAQ', 'S&P500',
];

final timeframes = [
  'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M10', 'M12', 'M15', 'M20',
  'M30', 'H1', 'H2', 'H3', 'H4', 'H6', 'H8', 'H12', 'D1', 'W1', 'MN'
];

String userId = "user123";

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, bool> selections = {};
  Map<String, String> directions = {};
  List<String> imageUrls = [];
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    fetchSettings();
    connectWebSocket();
  }

  Future<void> fetchSettings() async {
    final res = await http.get(Uri.parse('http://178.63.171.244:5000/get-settings?userId=$userId'));
    final data = jsonDecode(res.body);
    setState(() {
      selections = Map<String, bool>.from(data);
      for (var s in symbols) {
        directions[s] = data['$s:direction'] ?? 'BUY/SELL';
      }
    });
  }

  Future<void> sendSetting(String key, dynamic value) async {
    await http.post(
      Uri.parse('http://YOUR_SERVER_IP:5000/set-setting'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"userId": userId, "key": key, "value": value}),
    );
    setState(() {
      if (value is bool) selections[key] = value;
      if (value is String) directions[key.split(":")[0]] = value;
    });
  }

  void connectWebSocket() {
    channel = IOWebSocketChannel.connect('ws://178.63.171.244:3000');
    channel.sink.add(userId);
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final url = data['image'];
      setState(() {
        imageUrls.add(url);
      });
    });
  }

  Widget buildToggle(String key) {
    return CheckboxListTile(
      title: Text(key),
      value: selections[key] ?? false,
      onChanged: (val) => sendSetting(key, val),
    );
  }

  Widget buildDirectionSelector(String symbol) {
    final selected = directions[symbol] ?? 'BUY/SELL';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['BUY', 'SELL', 'BUY/SELL'].map((option) {
        return Expanded(
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selected,
            onChanged: (val) => sendSetting('$symbol:direction', val!),
          ),
        );
      }).toList(),
    );
  }

  Widget buildSymbolSection(String symbol) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(symbol, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildToggle(symbol),
            ...timeframes.map((tf) => buildToggle('$symbol:$tf')),
            SizedBox(height: 8),
            buildDirectionSelector(symbol),
          ],
        ),
      ),
    );
  }

  Widget buildImageGallery(List<String> urls) {
    if (urls.isEmpty) return Text('تصویری موجود نیست');
    return Column(
      children: urls.map((url) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(url),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('تنظیمات کاربر')),
        body: SingleChildScrollView(
child: Column(
            children: [
              ...symbols.map((s) => buildSymbolSection(s)).toList(),
              Divider(),
              Text('تصاویر دریافتی', style: TextStyle(fontSize: 20)),
              buildImageGallery(imageUrls),
            ],
          ),
        ),
      ),
    );
  }
}
