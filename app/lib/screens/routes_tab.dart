import 'package:flutter/material.dart';

class RoutesTab extends StatelessWidget {
  const RoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      // Header
      SliverToBoxAdapter(child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF1A1A2E)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My Routes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Your saved & recent activity', style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13)),
        ]),
      )),
      // Stats Row
      SliverToBoxAdapter(child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12)]),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Stat('12', 'Saved'),
          Container(width: 1, height: 30, color: Colors.grey[200]),
          _Stat('87', 'km Total'),
          Container(width: 1, height: 30, color: Colors.grey[200]),
          _Stat('24', 'Completed'),
        ]),
      )),
      // Saved Routes
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('⭐ Saved Routes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(color: Color(0xFFFFC107))))]))),
      SliverList(delegate: SliverChildListDelegate([
        _SavedRoute('Riverside Loop Trail', '★★★★★ 5.0', '🏃 Running · 3.2 km · ~18 min', const Color(0xFFE8F5E9)),
        _SavedRoute('Central Park Circuit', '★★★★☆ 4.2', '🚴 Cycling · 8.5 km · ~25 min', const Color(0xFFE3F2FD)),
      ])),
      // Recent Activity
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🕒 Recent Activity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: Color(0xFFFFC107))))]))),
      SliverList(delegate: SliverChildListDelegate([
        _ActivityCard('🏃', 'Riverside Loop Trail', 'Completed · 3.2 km · 17:42 min', 'Today'),
        _ActivityCard('🚴', 'Central Park Circuit', 'Completed · 8.5 km · 24:10 min', 'Yesterday'),
        _ActivityCard('🚶', 'Lakeside Morning Path', 'Completed · 2.1 km · 21:30 min', '2 days ago'),
        const SizedBox(height: 16),
      ])),
    ]);
  }
}

class _Stat extends StatelessWidget {
  final String num, label;
  const _Stat(this.num, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(num, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
    Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF999999)))]);
}

class _SavedRoute extends StatelessWidget {
  final String name, stars, meta; final Color iconBg;
  const _SavedRoute(this.name, this.stars, this.meta, this.iconBg);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.route_rounded, color: Color(0xFF1A1A2E), size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
            child: const Text('✅ Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))))]),
        Text(stars, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
        Text(meta, style: const TextStyle(color: Color(0xFF999999), fontSize: 11)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
    ]));
}

class _ActivityCard extends StatelessWidget {
  final String emoji, title, desc, time;
  const _ActivityCard(this.emoji, this.title, this.desc, this.time);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)]),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        Text(desc, style: const TextStyle(color: Color(0xFF999999), fontSize: 11)),
      ])),
      Text(time, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11)),
    ]));
}
