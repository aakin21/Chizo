import 'package:flutter/material.dart';
import 'profile_tab.dart';
import 'turnuva_tab.dart';
import 'settings_tab.dart';
import 'voting_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPage(BuildContext context, Widget page, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: BackButton(
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Sayfa"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Üstte 3 buton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _openPage(context, const ProfileTab(), "Profilim"),
                  child: const Text('Profil'),
                ),
                ElevatedButton(
                  onPressed: () => _openPage(context, const TurnuvaTab(), "Turnuvalar"),
                  child: const Text('Turnuva'),
                ),
                ElevatedButton(
                  onPressed: () => _openPage(context, const SettingsTab(), "Ayarlar"),
                  child: const Text('Ayarlar'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Altta tam ekran Voting
          Expanded(
            child: const VotingTab(),
          ),
        ],
      ),
    );
  }
}
