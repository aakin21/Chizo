import 'package:flutter/material.dart';

class StandardNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  final Function(Locale)? onLanguageChanged;
  final Function(String)? onThemeChanged;
  final VoidCallback? onRefresh;

  const StandardNavigationBar({
    super.key,
    required this.currentPage,
    this.onLanguageChanged,
    this.onThemeChanged,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String page,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isActive = currentPage == page;
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: isActive 
          ? color.withValues(alpha: 0.3) 
          : color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(32, 32),
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _getPageIcon(String page) {
    switch (page) {
      case 'home':
        return const Icon(Icons.how_to_vote, color: Colors.green, size: 24);
      case 'profile':
        return const Icon(Icons.person, color: Colors.blue, size: 24);
      case 'tournament':
        return const Icon(Icons.emoji_events, color: Colors.purple, size: 24);
      case 'leaderboard':
        return const Icon(Icons.leaderboard, color: Colors.orange, size: 24);
      case 'notifications':
        return const Icon(Icons.notifications, color: Colors.purple, size: 24);
      case 'store':
        return const Icon(Icons.store, color: Colors.orange, size: 24);
      case 'settings':
        return const Icon(Icons.settings, color: Colors.green, size: 24);
      default:
        return const Icon(Icons.apps, color: Colors.grey, size: 24);
    }
  }

  void _navigateToPage(BuildContext context, String page) {
    if (currentPage == page) return; // Aynı sayfadaysak hiçbir şey yapma

    // Home sayfasına dön
    if (page == 'home') {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    // Diğer sayfalar için sadece body'yi değiştir
    // Bu fonksiyon artık sadece callback olarak kullanılacak
    // Gerçek navigasyon home_screen.dart'ta yapılacak
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Back button'ı kaldır
      title: Row(
        children: [
          _getPageIcon(currentPage),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Oy Verme (Home)
              _buildNavigationButton(
                context: context,
                icon: Icons.how_to_vote,
                page: 'home',
                color: Colors.green,
                onPressed: () => _navigateToPage(context, 'home'),
              ),
              // Profil
              _buildNavigationButton(
                context: context,
                icon: Icons.person,
                page: 'profile',
                color: Colors.blue,
                onPressed: () => _navigateToPage(context, 'profile'),
              ),
              // Turnuva
              _buildNavigationButton(
                context: context,
                icon: Icons.emoji_events,
                page: 'tournament',
                color: Colors.purple,
                onPressed: () => _navigateToPage(context, 'tournament'),
              ),
              // Liderlik
              _buildNavigationButton(
                context: context,
                icon: Icons.leaderboard,
                page: 'leaderboard',
                color: Colors.orange,
                onPressed: () => _navigateToPage(context, 'leaderboard'),
              ),
              // Bildirimler
              _buildNavigationButton(
                context: context,
                icon: Icons.notifications,
                page: 'notifications',
                color: Colors.purple,
                onPressed: () => _navigateToPage(context, 'notifications'),
              ),
              // Mağaza
              _buildNavigationButton(
                context: context,
                icon: Icons.store,
                page: 'store',
                color: Colors.orange,
                onPressed: () => _navigateToPage(context, 'store'),
              ),
              // Ayarlar
              _buildNavigationButton(
                context: context,
                icon: Icons.settings,
                page: 'settings',
                color: Colors.green,
                onPressed: () => _navigateToPage(context, 'settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
