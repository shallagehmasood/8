import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initNotifications();
  runApp(MyApp());
}

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await notifications.initialize(settings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? "نوتیفیکیشن";
    final body = message.notification?.body ?? "";
    notifications.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'تصاویر',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final String userId = "786540582";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Test',
      home: HomePage(userId: userId),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userId;
  HomePage({required this.userId});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? token;

  @override
  void initState() {
    super.initState();
    getAndSendToken();
  }

  Future<void> getAndSendToken() async {
    token = await FirebaseMessaging.instance.getToken();
    print("📱 FCM Token: $token");

    await http.post(
      Uri.parse('http://178.63.171.244:5000/save-token'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "fcm_token": token,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FCM Test")),
      body: Center(
        child: Text(token != null ? "توکن ثبت شد" : "در حال دریافت توکن..."),
      ),
    );
  }
}
