import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'تنظیمات کاربر', home: SettingsPage(userId: '786540582'));
  }
}

class SettingsPage extends StatefulWidget {
  final String userId;
  SettingsPage({required this.userId});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late WebSocketChannel channel;

  final List<String> symbols = [
    'EURUSD', 'XAUUSD', 'GBPUSD', 'USDJPY', 'AUDUSD',
    'CADJPY', 'BTCUSD', 'ETHUSD', 'USDCHF',
    'DowJones', 'NASDAQ', 'S&P500', 'AUDJPY', 'EURJPY', 'ADAUSD'
  ];

  final List<String> timeframes = [
    'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M10', 'M12',
    'M15', 'M20', 'M30', 'H1', 'H2', 'H3', 'H4',
    'H6', 'H8', 'H12', 'D1', 'W1', 'MN1'
  ];

  final List<String> modes = ['A1', 'A2', 'B', 'C', 'D', 'E', 'F', 'G'];
  final List<String> sessions = ['SYDNEY', 'TOKYO', 'LONDON', 'NEWYORK'];

  Map<String, bool> selectedSymbols = {};
  Map<String, Map<String, bool>> selectedTimeframes = {};
  Map<String, bool> selectedModes = {};
  Map<String, bool> selectedSessions = {};
  String selectedExclusiveMode = '';

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://178.63.171.244:5001');
    for (var s in symbols) {
      selectedSymbols[s] = false;
      selectedTimeframes[s] = {for (var tf in timeframes) tf: false};
    }
    for (var m in modes) selectedModes[m] = false;
    for (var sess in sessions) selectedSessions[sess] = false;
    fetchInitialSettings();
  }

  Future<void> fetchInitialSettings() async {
    try {
      final res = await http.get(Uri.parse('http://178.63.171.244:5000/get-settings?userId=${widget.userId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final settings = data['settings'];
        applySettings(settings);
        await saveLocalSettings(settings);
      }
    } catch (_) {
      final local = await loadLocalSettings();
      applySettings(local);
    }
  }

  void applySettings(Map<String, dynamic> settings) {
    setState(() {
      for (var s in symbols) selectedSymbols[s] = settings[s] ?? false;
      for (var s in symbols) {
        for (var tf in timeframes) {
          final key = '$s:$tf';
          selectedTimeframes[s]![tf] = settings[key] ?? false;
        }
      }
      for (var m in modes) selectedModes[m] = settings[m] ?? false;
      selectedExclusiveMode = selectedModes['A1'] == true ? 'A1' : selectedModes['A2'] == true ? 'A2' : '';
      for (var sess in sessions) selectedSessions[sess] = settings[sess] ?? false;
    });
  }

  Future<void> saveLocalSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    settings.forEach((k, v) {
      if (v is bool) prefs.setBool(k, v);
    });
  }

  Future<Map<String, dynamic>> loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> result = {};
    for (var s in symbols) result[s] = prefs.getBool(s) ?? false;
    for (var s in symbols) {
      for (var tf in timeframes) {
        final key = '$s:$tf';
        result[key] = prefs.getBool(key) ?? false;
      }
    }
    for (var m in modes) result[m] = prefs.getBool(m) ?? false;
    for (var sess in sessions) result[sess] = prefs.getBool(sess) ?? false;
    return result;
  }

  void sendSetting(String key, dynamic value) {
    final payload = {'userId': widget.userId, 'setting': {key: value}};
    channel.sink.add(jsonEncode(payload));
    channel.stream.listen((message) async {
      final response = jsonDecode(message);
      if (response['status'] == 'ok') {
        applySettings(response['settings']);
        await saveLocalSettings(response['settings']);
      }
    });
  }

  Widget buildSymbolButton(String symbol) {
    final isSelected = selectedSymbols[symbol] ?? false;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () => sendSetting(symbol, !isSelected),
      child: Text(symbol),
    );
  }

  Widget buildTimeframeSection(String symbol) {
    return ExpansionTile(
      title: Text('تایم‌فریم‌های $symbol'),
      children: timeframes.map((tf) {
        final isSelected = selectedTimeframes[symbol]![tf] ?? false;
        return CheckboxListTile(
          title: Text(tf),
          value: isSelected,
          onChanged: (val) => sendSetting('$symbol:$tf', val ?? false),
        );
      }).toList(),
    );
  }

  Widget buildModeSection() {
    final exclusive = ['A1', 'A2'];
    final others = ['B', 'C', 'D', 'E', 'F', 'G'];
    return Column(
      children: [
        Text('مودهای انحصاری'),
        Row(
          children: exclusive.map((mode) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(mode),
                value: mode,
                groupValue: selectedExclusiveMode,
                onChanged: (val) {
                  selectedExclusiveMode = val!;
                  sendSetting('A1', val == 'A1');
                  sendSetting('A2', val == 'A2');
                },
              ),
            );
          }).toList(),
        ),
        Wrap(
          spacing: 8,
          children: others.map((mode) {
            final isSelected = selectedModes[mode] ?? false;
            return FilterChip(
              label: Text(mode),
              selected: isSelected,
              onSelected: (val) => sendSetting(mode, val),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSessionSection() {
    return Wrap(
      spacing: 8,
      children: sessions.map((sess) {
        final isSelected = selectedSessions[sess] ?? false;
        return FilterChip(
          label: Text(sess),
          selected: isSelected,
          onSelected: (val) => sendSetting(sess, val),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات کاربر')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('جفت‌ارزها'),
            Wrap(spacing: 8, children: symbols.map(buildSymbolButton).toList()),
            SizedBox(height: 24),
            ...symbols.map(buildTimeframeSection).toList(),
            SizedBox(height: 24),
            buildModeSection(),
            SizedBox(height: 24),
            Text('جلسات معاملاتی'),
            buildSessionSection(),
          ],
        ),
      ),
    );
  }
}
