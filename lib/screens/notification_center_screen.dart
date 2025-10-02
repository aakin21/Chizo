import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_history_service.dart';
import '../models/notification_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  int unreadCount = 0;
  
  // Notification Settings
  bool _notificationsEnabled = true;
  bool _tournamentNotifications = true;
  bool _winCelebrationNotifications = true;
  bool _streakReminderNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notification_all') ?? true;
      _tournamentNotifications = prefs.getBool('notification_tournament') ?? true;
      _winCelebrationNotifications = prefs.getBool('notification_win_celebration') ?? true;
      _streakReminderNotifications = prefs.getBool('notification_streak_reminder') ?? true;
      
      setState(() {});
    } catch (e) {
      print('Error loading notification preferences: $e');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      final notificationList = await NotificationHistoryService.getNotificationHistory();
      final unread = await NotificationHistoryService.getUnreadCount();
      
      setState(() {
        notifications = notificationList;
        unreadCount = unread;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    try {
      await NotificationHistoryService.markAsRead(notification.id);
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
        unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final success = await NotificationHistoryService.deleteNotification(notification.id);
      if (success) {
        setState(() {
          notifications.removeWhere((n) => n.id == notification.id);
          if (!notification.isRead) {
            unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationHistoryService.markAllAsRead();
      setState(() {
        notifications = notifications.map((n) => n.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        )).toList();
        unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking all as read: $e')),
      );
    }
  }

  Future<void> _deleteAllNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Notifications'),
        content: Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await NotificationHistoryService.deleteAllNotifications();
                setState(() {
                  notifications.clear();
                  unreadCount = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All notifications deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting all notifications: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_all', _notificationsEnabled);
      await prefs.setBool('notification_tournament', _tournamentNotifications);
      await prefs.setBool('notification_win_celebration', _winCelebrationNotifications);
      await prefs.setBool('notification_streak_reminder', _streakReminderNotifications);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification settings saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              const Spacer(),
              if (unreadCount > 0)
                IconButton(
                  icon: const Icon(Icons.mark_email_read, color: Colors.white),
                  onPressed: _markAllAsRead,
                  tooltip: 'Tümünü okundu işaretle',
                ),
            ],
          ),
        ),
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      slivers: [
        // Notification Settings
        SliverToBoxAdapter(
          child: _buildNotificationSettings(),
        ),
        
        // Çöp kutusu ikonu
        if (notifications.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(right: 8, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: _deleteAllNotifications,
                    tooltip: 'Tümünü sil',
                    color: Colors.grey[600],
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        
        // Notifications List
        _buildNotificationsSliverList(),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Ana bildirim toggle
          SwitchListTile(
            title: Text('Bildirimler'),
            subtitle: Text('Telefon bildirimlerini aç/kapat (bildirimler uygulamada görünmeye devam eder)'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveNotificationSettings();
            },
          ),
          
          // Alt bildirim türleri
          if (_notificationsEnabled) ...[
            SwitchListTile(
              title: Text('Turnuva Bildirimleri'),
              subtitle: Text('Lig aşaması, eşleşme başlangıç/bitiş hatırlatmaları'),
              value: _tournamentNotifications,
              onChanged: (value) {
                setState(() {
                  _tournamentNotifications = value;
                });
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              title: Text('Kazanç Kutlamaları'),
              subtitle: Text('Match kazanma ve milestone bildirimleri'),
              value: _winCelebrationNotifications,
              onChanged: (value) {
                setState(() {
                  _winCelebrationNotifications = value;
                });
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              title: Text('Hot Streak Hatırlatmaları'),
              subtitle: Text('Günlük hot streak ve ödül hatırlatmaları'),
              value: _streakReminderNotifications,
              onChanged: (value) {
                setState(() {
                  _streakReminderNotifications = value;
                });
                _saveNotificationSettings();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsSliverList() {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (notifications.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz bildirim yok',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni bildirimler burada görünecek',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
        childCount: notifications.length,
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Notification'),
            content: Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getNotificationColor(notification.type).withOpacity(0.2),
          child: Text(
            getNotificationIcon(notification.type),
            style: TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: getNotificationColor(notification.type),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: notification.isRead 
            ? null 
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getNotificationColor(notification.type),
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification);
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}