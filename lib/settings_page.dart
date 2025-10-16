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
  Map<String, dynamic> settings = {};
  bool loading = true;

  final List<String> symbols = ["EURUSD", "XAUUSD"];
  final List<String> timeframes = ["M1", "M5"];
  final List<String> directions = ["Buy", "Sell", "BuyAndSell"];
  final List<String> modes = ["A1", "A2"];

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final res = await http.get(Uri.parse('http://178.63.171.244:5000/get-settings?userId=${widget.userId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          settings = Map<String, dynamic>.from(data['settings']);
          loading = false;
        });
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> updateSettings() async {
    try {
      final body = jsonEncode({
        "userId": widget.userId,
        "setting": settings,
      });
      await http.post(
        Uri.parse('http://178.63.171.244:5000/update-settings'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
    } catch (_) {}
  }

  Widget buildSymbolSettings(String symbol) {
    final symbolData = settings[symbol] ?? {
      "timeframes": [],
      "direction": "Buy",
      "A": "A1",
      "B": false
    };

    return ExpansionTile(
      title: Text(symbol),
      children: [
        Text("تایم‌فریم‌ها", style: TextStyle(fontWeight: FontWeight.bold)),
        ...timeframes.map((tf) {
          final selected = symbolData["timeframes"].contains(tf);
          return CheckboxListTile(
            title: Text(tf),
            value: selected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  symbolData["timeframes"].add(tf);
                } else {
                  symbolData["timeframes"].remove(tf);
                }
                settings[symbol] = symbolData;
                updateSettings();
              });
            },
          );
        }),

        Divider(),
        Text("دایرکشن", style: TextStyle(fontWeight: FontWeight.bold)),
        ...directions.map((dir) {
          return RadioListTile(
            title: Text(dir),
            value: dir,
            groupValue: symbolData["direction"],
            onChanged: (val) {
              setState(() {
                symbolData["direction"] = val;
                settings[symbol] = symbolData;
                updateSettings();
              });
            },
          );
        }),

        Divider(),
        Text("مود A", style: TextStyle(fontWeight: FontWeight.bold)),
        ...modes.map((m) {
          return RadioListTile(
            title: Text(m),
            value: m,
            groupValue: symbolData["A"],
            onChanged: (val) {
              setState(() {
                symbolData["A"] = val;
                settings[symbol] = symbolData;
                updateSettings();
              });
            },
          );
        }),

        SwitchListTile(
          title: Text("مود B"),
          value: symbolData["B"] ?? false,
          onChanged: (val) {
            setState(() {
              symbolData["B"] = val;
              settings[symbol] = symbolData;
              updateSettings();
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات کاربر')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: symbols.map(buildSymbolSettings).toList(),
      ),
    );
  }
}
