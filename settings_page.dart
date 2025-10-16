import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final String userId;
  SettingsPage({required this.userId});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, bool> settings = {};
  bool loading = true;

  final List<String> symbols = [
    "EURUSD",
    "XAUUSD",
    "GBPUSD",
    "USDJPY",
    "USDCHF",
    "AUDUSD",
    "AUDJPY",
    "CADJPY",
    "EURJPY",
    "BTCUSD",
    "ETHUSD",
    "ADAUSD",
    "DowJones",
    "NASDAQ",
    "S&P500",
  ];

  final List<String> timeframes = [
    "M1",
    "M2",
    "M3",
    "M4",
    "M5",
    "M6",
    "M10",
    "M12",
    "M15",
    "M20",
    "M30",
    "H1",
    "H2",
    "H3",
    "H4",
    "H6",
    "H8",
    "H12",
    "D1",
    "W1",
  ];

  final List<String> modes = ["A1", "A2", "A3", "A4", "A5", "A6", "A7"];

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final res = await http.get(
        Uri.parse(
          'http://178.63.171.244:5000/get-settings?userId=${widget.userId}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final s = Map<String, dynamic>.from(data['settings']);
        setState(() {
          settings = s.map((k, v) => MapEntry(k, v == true));
          loading = false;
        });
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> updateSettings() async {
    try {
      final body = jsonEncode({"userId": widget.userId, "setting": settings});
      await http.post(
        Uri.parse('http://178.63.171.244:5000/update-settings'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
    } catch (_) {}
  }

  Widget buildSwitches(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...items.map((key) {
          return SwitchListTile(
            title: Text(key),
            value: settings[key] ?? false,
            onChanged: (val) {
              setState(() => settings[key] = val);
              updateSettings();
            },
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات کاربر')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildSwitches("نمادها", symbols),
          buildSwitches("تایم‌فریم‌ها", timeframes),
          buildSwitches("مودها", modes),
        ],
      ),
    );
  }
}
