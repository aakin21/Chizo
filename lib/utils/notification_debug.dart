import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/notification_integration_service.dart';

/// Notification debugging utilities
class NotificationDebug {
  /// Test if notifications are working
  static Future<void> testNotification(BuildContext context) async {
    try {
      print('🧪 Testing notification manually...');

      // Send a simple test notification
      await NotificationService.sendLocalNotification(
        title: '🎉 Test Notification',
        body: 'If you see this, notifications are working!',
        type: 'test',
        data: {'test': true},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent! Check your notification tray.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('✅ Test notification sent successfully');
    } catch (e) {
      print('❌ Test notification failed: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Check notification permissions
  static Future<Map<String, dynamic>> checkPermissions() async {
    try {
      final hasPermission = await NotificationService.hasPermission();
      final fcmToken = await NotificationService.getFCMToken();

      return {
        'hasPermission': hasPermission,
        'fcmToken': fcmToken != null && fcmToken.isNotEmpty,
        'fcmTokenValue': fcmToken,
      };
    } catch (e) {
      print('❌ Permission check failed: $e');
      return {
        'hasPermission': false,
        'fcmToken': false,
        'error': e.toString(),
      };
    }
  }

  /// Show debug info dialog
  static Future<void> showDebugInfo(BuildContext context) async {
    final info = await checkPermissions();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔔 Notification Debug Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Has Permission: ${info['hasPermission']}'),
              const SizedBox(height: 8),
              Text('FCM Token: ${info['fcmToken']}'),
              const SizedBox(height: 8),
              if (info['fcmTokenValue'] != null)
                Text('Token: ${info['fcmTokenValue'].substring(0, 20)}...'),
              if (info['error'] != null)
                Text('Error: ${info['error']}', style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testNotification(context);
              },
              child: const Text('Send Test'),
            ),
          ],
        ),
      );
    }
  }
}
