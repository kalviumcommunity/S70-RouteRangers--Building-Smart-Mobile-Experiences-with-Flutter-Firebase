import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'login_screen.dart';

import 'profile/settings_screen.dart';
import 'profile/privacy_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      // Cover + Avatar
      Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
        Container(height: 180, decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF9800)]))),
        Positioned(bottom: -40, child: Container(
          width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF3E0),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)]),
          child: const Center(child: Text('🐝', style: TextStyle(fontSize: 36))))),
      ]),
      const SizedBox(height: 48),
      // User Profile Header
      Consumer<AppState>(
        builder: (context, appState, child) {
          final displayName = appState.user?.displayName;
          final name = (displayName != null && displayName.isNotEmpty) ? displayName : 'Alex Runner';
          
          return Column(
            children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
              const Text('@alexrunner · Hive Explorer', style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
            ],
          );
        }
      ),
      const SizedBox(height: 20),
      // Stats
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(children: [
          _StatCard('47', 'Routes Reviewed'),
          const SizedBox(width: 10),
          _StatCard('128', 'Pins Added'),
          const SizedBox(width: 10),
          _StatCard('312', 'Km Tracked'),
        ])),
      const SizedBox(height: 24),
      // Achievements
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _Achievement('🏅', 'Hive Pioneer', 'First 10 hazard pins reported'),
          _Achievement('🌟', 'Safety Star', 'Reviewed 25+ routes'),
          _Achievement('🐝', 'Queen Bee', 'Top contributor this month'),
        ])),
      const SizedBox(height: 20),
      // Menu
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          _MenuItem(Icons.settings_rounded, 'Settings', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _MenuItem(Icons.shield_rounded, 'Privacy & Safety', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
          }),
          _MenuItem(Icons.logout_rounded, 'Log Out', onTap: () async {
            try {
              // Sign out from Firebase Backend completely
              await Provider.of<AppState>(context, listen: false).signOut();
            } catch (_) {}
            
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }),
        ])),
      const SizedBox(height: 30),
    ]));
  }
}

class _StatCard extends StatelessWidget {
  final String num, label;
  const _StatCard(this.num, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
    child: Column(children: [
      Text(num, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFFFC107))),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
    ])));
}

class _Achievement extends StatelessWidget {
  final String emoji, title, desc;
  const _Achievement(this.emoji, this.title, this.desc);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)]),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22)))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
        Text(desc, style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
      ]),
    ]));
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback? onTap;
  const _MenuItem(this.icon, this.label, {this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)]),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF1A1A2E), size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
      onTap: onTap,
    ));
}
