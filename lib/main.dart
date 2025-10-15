import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, bool> selections = {};
  Map<String, String> directionSelections = {};
  String userId = "user123"; // مقدار تستی

  @override
  void initState() {
    super.initState();
    loadLocalSettings();
  }

  Future<void> loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> loaded = {};
    final Map<String, String> directions = {};

    for (var s in symbols) {
      loaded[s] = prefs.getBool(s) ?? false;
      directions[s] = prefs.getString('$s:direction') ?? 'BUY/SELL';
      for (var tf in timeframes) {
        loaded['$s:$tf'] = prefs.getBool('$s:$tf') ?? false;
      }
    }

    setState(() {
      selections = loaded;
      directionSelections = directions;
    });
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
      selections[key] = value;
    } else if (value is String) {
      await prefs.setString(key, value);
      directionSelections[key.split(":")[0]] = value;
    }
    setState(() {});
  }

  Widget buildToggle(String key) {
    return CheckboxListTile(
      title: Text(key),
      value: selections[key] ?? false,
      onChanged: (val) => saveSetting(key, val),
    );
  }

  Widget buildDirectionSelector(String symbol) {
    final selected = directionSelections[symbol] ?? 'BUY/SELL';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['BUY', 'SELL', 'BUY/SELL'].map((option) {
        return Expanded(
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selected,
            onChanged: (val) => saveSetting('$symbol:direction', val!),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTimeframeSection(String symbol) {
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
            Text('جهت معامله'),
            buildDirectionSelector(symbol),
          ],
        ),
      ),
    );
  }

  Future<List<String>> fetchUserImages() async {
    final res = await http.get(Uri.parse('http://178.63.171.244:5000/get-user-images?userId=$userId'));
    final data = jsonDecode(res.body);
    return List<String>.from(data['images']);
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
              ...symbols.map((s) => buildTimeframeSection(s)),
              Divider(),
              Text('تصاویر دریافتی', style: TextStyle(fontSize: 20)),
              FutureBuilder<List<String>>(
                future: fetchUserImages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return buildImageGallery(snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
