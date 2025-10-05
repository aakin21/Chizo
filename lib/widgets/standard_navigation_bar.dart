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
        return const Icon(Icons.how_to_vote, color: Color(0xFFFF6B35), size: 24); // Ana turuncu ton
      case 'profile':
        return const Icon(Icons.person, color: Color(0xFFFF8C42), size: 24); // Açık turuncu ton
      case 'tournament':
        return const Icon(Icons.emoji_events, color: Color(0xFFE55A2B), size: 24); // Koyu turuncu ton
      case 'leaderboard':
        return const Icon(Icons.leaderboard, color: Color(0xFFFF6B35), size: 24); // Ana turuncu ton
      case 'notifications':
        return const Icon(Icons.notifications, color: Color(0xFFFF8C42), size: 24); // Açık turuncu ton
      case 'store':
        return const Icon(Icons.store, color: Color(0xFFE55A2B), size: 24); // Koyu turuncu ton
      case 'settings':
        return const Icon(Icons.settings, color: Color(0xFFFF6B35), size: 24); // Ana turuncu ton
      default:
        return const Icon(Icons.apps, color: Color(0xFFFF6B35), size: 24); // Ana turuncu ton
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
                color: const Color(0xFFFF6B35), // Ana turuncu ton
                onPressed: () => _navigateToPage(context, 'home'),
              ),
              // Profil
              _buildNavigationButton(
                context: context,
                icon: Icons.person,
                page: 'profile',
                color: const Color(0xFFFF8C42), // Açık turuncu ton
                onPressed: () => _navigateToPage(context, 'profile'),
              ),
              // Turnuva
              _buildNavigationButton(
                context: context,
                icon: Icons.emoji_events,
                page: 'tournament',
                color: const Color(0xFFE55A2B), // Koyu turuncu ton
                onPressed: () => _navigateToPage(context, 'tournament'),
              ),
              // Liderlik
              _buildNavigationButton(
                context: context,
                icon: Icons.leaderboard,
                page: 'leaderboard',
                color: const Color(0xFFFF6B35), // Ana turuncu ton
                onPressed: () => _navigateToPage(context, 'leaderboard'),
              ),
              // Bildirimler
              _buildNavigationButton(
                context: context,
                icon: Icons.notifications,
                page: 'notifications',
                color: const Color(0xFFFF8C42), // Açık turuncu ton
                onPressed: () => _navigateToPage(context, 'notifications'),
              ),
              // Mağaza
              _buildNavigationButton(
                context: context,
                icon: Icons.store,
                page: 'store',
                color: const Color(0xFFE55A2B), // Koyu turuncu ton
                onPressed: () => _navigateToPage(context, 'store'),
              ),
              // Ayarlar
              _buildNavigationButton(
                context: context,
                icon: Icons.settings,
                page: 'settings',
                color: const Color(0xFFFF6B35), // Ana turuncu ton
                onPressed: () => _navigateToPage(context, 'settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
