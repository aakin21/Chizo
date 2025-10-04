import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_history_service.dart';
import '../models/notification_model.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

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
  
  // Dil değişkeni
  String _currentLanguage = 'tr';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadNotificationSettings();
    _loadCurrentLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değişikliğini dinle
    _loadCurrentLanguage();
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

  Future<void> _loadCurrentLanguage() async {
    try {
      final locale = await LanguageService.getCurrentLocale();
      setState(() {
        _currentLanguage = locale.languageCode;
      });
    } catch (e) {
      print('Error loading current language: $e');
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
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_all', _notificationsEnabled);
      await prefs.setBool('notification_tournament', _tournamentNotifications);
      await prefs.setBool('notification_win_celebration', _winCelebrationNotifications);
      await prefs.setBool('notification_streak_reminder', _streakReminderNotifications);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim ayarları kaydedildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
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
                  tooltip: _getLocalizedText('markAllAsRead'),
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
    final l10n = AppLocalizations.of(context)!;
    
    return CustomScrollView(
      slivers: [
        // Notification Settings
        SliverToBoxAdapter(
          child: _buildNotificationSettings(),
        ),
        
        // Yönetim butonları
        if (notifications.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.mark_email_read),
                    onPressed: _markAllAsRead,
                    tooltip: l10n.markAllAsRead,
                    color: Colors.blue[600],
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: _deleteAllNotifications,
                    tooltip: _getLocalizedText('deleteAll'),
                    color: Colors.red[600],
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
            title: Text(_getLocalizedText('notifications')),
            subtitle: Text(_getLocalizedText('notificationSettingsDescription')),
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
              title: Text(_getLocalizedText('tournamentNotifications')),
              subtitle: Text(_getLocalizedText('tournamentNotificationsDescription')),
              value: _tournamentNotifications,
              onChanged: (value) {
                setState(() {
                  _tournamentNotifications = value;
                });
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              title: Text(_getLocalizedText('winCelebrationNotifications')),
              subtitle: Text(_getLocalizedText('winCelebrationNotificationsDescription')),
              value: _winCelebrationNotifications,
              onChanged: (value) {
                setState(() {
                  _winCelebrationNotifications = value;
                });
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              title: Text(_getLocalizedText('streakReminderNotifications')),
              subtitle: Text(_getLocalizedText('streakReminderNotificationsDescription')),
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

  String _getLocalizedText(String key) {
    // Gerçek dil ayarlarını kullan
    String currentLanguage = _currentLanguage;
    
    switch (key) {
      case 'notifications':
        switch (currentLanguage) {
          case 'en': return 'Notifications';
          case 'de': return 'Benachrichtigungen';
          case 'es': return 'Notificaciones';
          default: return 'Bildirimler';
        }
      case 'notificationSettingsDescription':
        switch (currentLanguage) {
          case 'en': return 'Turn phone notifications on/off (notifications will continue to appear in the app)';
          case 'de': return 'Telefon-Benachrichtigungen ein/aus (Benachrichtigungen werden weiterhin in der App angezeigt)';
          case 'es': return 'Activar/desactivar notificaciones del teléfono (las notificaciones seguirán apareciendo en la app)';
          default: return 'Telefon bildirimlerini aç/kapat (bildirimler uygulamada görünmeye devam eder)';
        }
      case 'tournamentNotifications':
        switch (currentLanguage) {
          case 'en': return 'Tournament Notifications';
          case 'de': return 'Turnier-Benachrichtigungen';
          case 'es': return 'Notificaciones de Torneo';
          default: return 'Turnuva Bildirimleri';
        }
      case 'tournamentNotificationsDescription':
        switch (currentLanguage) {
          case 'en': return 'League stage, match start/end reminders';
          case 'de': return 'Liga-Phase, Match-Start/Ende-Erinnerungen';
          case 'es': return 'Fase de liga, recordatorios de inicio/fin de partido';
          default: return 'Lig aşaması, eşleşme başlangıç/bitiş hatırlatmaları';
        }
      case 'winCelebrationNotifications':
        switch (currentLanguage) {
          case 'en': return 'Win Celebrations';
          case 'de': return 'Sieg-Feiern';
          case 'es': return 'Celebraciones de Victoria';
          default: return 'Kazanç Kutlamaları';
        }
      case 'winCelebrationNotificationsDescription':
        switch (currentLanguage) {
          case 'en': return 'Match wins and milestone notifications';
          case 'de': return 'Match-Siege und Meilenstein-Benachrichtigungen';
          case 'es': return 'Victorias en partidos y notificaciones de logros';
          default: return 'Match kazanma ve milestone bildirimleri';
        }
      case 'streakReminderNotifications':
        switch (currentLanguage) {
          case 'en': return 'Hot Streak Reminders';
          case 'de': return 'Hot Streak-Erinnerungen';
          case 'es': return 'Recordatorios de Racha';
          default: return 'Hot Streak Hatırlatmaları';
        }
      case 'streakReminderNotificationsDescription':
        switch (currentLanguage) {
          case 'en': return 'Daily hot streak and reward reminders';
          case 'de': return 'Tägliche Hot Streak- und Belohnungs-Erinnerungen';
          case 'es': return 'Recordatorios diarios de racha caliente y recompensas';
          default: return 'Günlük hot streak ve ödül hatırlatmaları';
        }
      case 'markAllAsRead':
        switch (currentLanguage) {
          case 'en': return 'Mark all as read';
          case 'de': return 'Alle als gelesen markieren';
          case 'es': return 'Marcar todo como leído';
          default: return 'Tümünü okundu işaretle';
        }
      case 'deleteAll':
        switch (currentLanguage) {
          case 'en': return 'Delete all';
          case 'de': return 'Alle löschen';
          case 'es': return 'Eliminar todo';
          default: return 'Tümünü sil';
        }
      default:
        return key;
    }
  }
}