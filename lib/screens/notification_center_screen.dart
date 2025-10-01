import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../l10n/app_localizations.dart';

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
  bool _voteReminderNotifications = true;
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
      _voteReminderNotifications = prefs.getBool('notification_vote_reminder') ?? true;
      _winCelebrationNotifications = prefs.getBool('notification_win_celebration') ?? true;
      _streakReminderNotifications = prefs.getBool('notification_streak_reminder') ?? true;
      
      setState(() {});
    } catch (e) {
      // print('Error loading notification preferences: $e');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      final notificationList = await NotificationService.getUserNotifications();
      final unread = await NotificationService.getUnreadCount();
      
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
      await NotificationService.markAsRead(notification.id);
      setState(() {
        // Yeni bir NotificationModel oluştur
        final updatedNotification = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
          readAt: DateTime.now(),
        );
        
        // Listede güncelle
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = updatedNotification;
        }
        
        unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      setState(() {
        // Tüm bildirimleri güncelle
        notifications = notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
          );
        }).toList();
        
        unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking all as read: $e')),
      );
    }
  }

  Future<void> _updateNotificationPreference(String type, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_$type', value);
      setState(() {
        switch (type) {
          case 'all':
            _notificationsEnabled = value;
            break;
          case 'tournament':
            _tournamentNotifications = value;
            break;
          case 'vote_reminder':
            _voteReminderNotifications = value;
            break;
          case 'win_celebration':
            _winCelebrationNotifications = value;
            break;
          case 'streak_reminder':
            _streakReminderNotifications = value;
            break;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'tournament_update':
        return '🏆';
      case 'voting_result':
        return '🗳️';
      case 'coin_reward':
        return '💰';
      case 'streak_reward':
        return '🔥';
      case 'system_announcement':
        return '📢';
      default:
        return '🔔';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'tournament_update':
        return Colors.purple;
      case 'voting_result':
        return Colors.blue;
      case 'coin_reward':
        return Colors.amber;
      case 'streak_reward':
        return Colors.orange;
      case 'system_announcement':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationCenter),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(AppLocalizations.of(context)!.markAllAsRead),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bildirim Ayarları
            _buildNotificationSettings(),
            
            const SizedBox(height: 16),
            
            // Bildirimler
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (notifications.isEmpty)
              _buildEmptyState()
            else
              _buildNotificationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔔 ${AppLocalizations.of(context)!.notificationSettings}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.allNotifications),
              subtitle: Text(AppLocalizations.of(context)!.allNotificationsDescription),
              value: _notificationsEnabled,
              onChanged: (value) async {
                await _updateNotificationPreference('all', value);
              },
              secondary: const Icon(Icons.notifications),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.tournamentNotifications),
              subtitle: Text(AppLocalizations.of(context)!.tournamentNotificationsDescription),
              value: _tournamentNotifications,
              onChanged: !_notificationsEnabled ? null : (value) async {
                await _updateNotificationPreference('tournament', value);
              },
              secondary: const Icon(Icons.emoji_events),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.voteReminderNotifications),
              subtitle: Text(AppLocalizations.of(context)!.voteReminderNotificationsDescription),
              value: _voteReminderNotifications,
              onChanged: !_notificationsEnabled ? null : (value) async {
                await _updateNotificationPreference('vote_reminder', value);
              },
              secondary: const Icon(Icons.how_to_vote),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.winCelebrationNotifications),
              subtitle: Text(AppLocalizations.of(context)!.winCelebrationNotificationsDescription),
              value: _winCelebrationNotifications,
              onChanged: !_notificationsEnabled ? null : (value) async {
                await _updateNotificationPreference('win_celebration', value);
              },
              secondary: const Icon(Icons.celebration),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.streakReminderNotifications),
              subtitle: Text(AppLocalizations.of(context)!.streakReminderNotificationsDescription),
              value: _streakReminderNotifications,
              onChanged: !_notificationsEnabled ? null : (value) async {
                await _updateNotificationPreference('streak_reminder', value);
              },
              secondary: const Icon(Icons.local_fire_department),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotificationsYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.newNotificationsWillAppearHere,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📱 ${AppLocalizations.of(context)!.notificationsList}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 1,
      color: isUnread ? color.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
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
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markAsRead(notification),
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
