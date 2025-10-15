import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تنظیمات کاربر',
      home: SettingsPage(userId: '786540582'),
    );
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
    'H6', 'H8', 'H12', 'D1', 'W1'
  ];

  final List<String> sessions = ['SYDNEY', 'TOKYO', 'LONDON', 'NEWYORK'];

  Map<String, bool> selectedSymbols = {};
  Map<String, Map<String, bool>> selectedTimeframes = {};
  Map<String, bool> selectedSessions = {};
  String selectedExclusiveMode = '';
  Map<String, bool> selectedModes = {
    'A1': false,
    'A2': false,
    'B': false,
    'C': false,
    'D': false,
    'E': false,
    'F': false,
    'G': false,
  };

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://YOUR_VPS_IP:8765');
    for (var symbol in symbols) {
      selectedSymbols[symbol] = false;
      selectedTimeframes[symbol] = {
        for (var tf in timeframes) tf: false,
      };
    }
    for (var session in sessions) {
      selectedSessions[session] = false;
    }
  }

  void sendSetting(String key, dynamic value) {
    final payload = {
      'userId': widget.userId,
      'setting': {
        key: value,
      }
    };
    channel.sink.add(jsonEncode(payload));
  }

  Widget buildSymbolButton(String symbol) {
    final isSelected = selectedSymbols[symbol] ?? false;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedSymbols[symbol] = !isSelected;
        });
        sendSetting(symbol, selectedSymbols[symbol]);
      },
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
          onChanged: (val) {
            setState(() {
              selectedTimeframes[symbol]![tf] = val ?? false;
            });
            sendSetting('$symbol:$tf', val ?? false);
          },
        );
      }).toList(),
    );
  }

  Widget buildModeSection() {
    final List<String> exclusiveModes = ['A1', 'A2'];
    final List<String> otherModes = ['B', 'C', 'D', 'E', 'F', 'G'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('انتخاب A1 یا A2 (فقط یکی)', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: exclusiveModes.map((mode) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(mode),
                value: mode,
                groupValue: selectedExclusiveMode,
                onChanged: (val) {
                  setState(() {selectedExclusiveMode = val!;
                    selectedModes['A1'] = val == 'A1';
                    selectedModes['A2'] = val == 'A2';
                    sendSetting('A1', selectedModes['A1']);
                    sendSetting('A2', selectedModes['A2']);
                  });
                },
              ),
            );
          }).toList(),
        ),
        Divider(),
        Text('سایر مودها', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: otherModes.map((mode) {
            final isSelected = selectedModes[mode] ?? false;
            return FilterChip(
              label: Text(mode),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  selectedModes[mode] = val;
                  sendSetting(mode, val);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('جلسات معاملاتی', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: sessions.map((session) {
            final isSelected = selectedSessions[session] ?? false;
            return FilterChip(
              label: Text(session),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  selectedSessions[session] = val;
                  sendSetting(session, val);
                });
              },
            );
          }).toList(),
        ),
      ],
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
            Text('جفت‌ارزها', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symbols.map(buildSymbolButton).toList(),
            ),
            SizedBox(height: 24),
            ...symbols.map(buildTimeframeSection).toList(),
            SizedBox(height: 24),
            buildModeSection(),
            SizedBox(height: 24),
            buildSessionSection(),
          ],
        ),
      ),
    );
  }
}
