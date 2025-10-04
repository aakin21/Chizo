import 'package:flutter/material.dart';
import '../services/hot_streak_notification_service.dart';
import '../services/hotstreak_notification_test_service.dart';

class HotstreakNotificationExample extends StatefulWidget {
  @override
  _HotstreakNotificationExampleState createState() => _HotstreakNotificationExampleState();
}

class _HotstreakNotificationExampleState extends State<HotstreakNotificationExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotstreak Notification Test'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hotstreak Bildirim Testleri',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Test Hotstreak Reward Notification
            ElevatedButton(
              onPressed: () async {
                await HotstreakNotificationTestService.testHotStreakRewardNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hotstreak ödül bildirimi test edildi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                '🔥 Hotstreak Ödül Bildirimi Test Et',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            
            SizedBox(height: 15),
            
            // Test Hotstreak Reminder Notification
            ElevatedButton(
              onPressed: () async {
                await HotstreakNotificationTestService.testHotStreakReminderNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hotstreak hatırlatma bildirimi test edildi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                '⏰ Hotstreak Hatırlatma Bildirimi Test Et',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            
            SizedBox(height: 15),
            
            // Test Localized Notification
            ElevatedButton(
              onPressed: () async {
                await HotstreakNotificationTestService.testLocalizedHotStreakNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lokalize hotstreak bildirimi test edildi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                '🌍 Lokalize Hotstreak Bildirimi Test Et',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            
            SizedBox(height: 15),
            
            // Test All Notifications
            ElevatedButton(
              onPressed: () async {
                await HotstreakNotificationTestService.testAllHotStreakNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tüm hotstreak bildirimleri test edildi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                '🧪 Tüm Hotstreak Bildirimlerini Test Et',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Bilgi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bu test sayfası hotstreak bildirimlerinin düzgün çalışıp çalışmadığını kontrol etmek için kullanılır.\n\n'
                      '• Hotstreak ödül bildirimleri artık lokalize edilmiş\n'
                      '• Çoklu dil desteği eklendi\n'
                      '• Bildirim tipleri düzenlendi\n'
                      '• Test servisleri eklendi',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
