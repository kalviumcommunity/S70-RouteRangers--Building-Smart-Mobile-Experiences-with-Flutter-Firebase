import 'package:flutter/material.dart';
import 'map_tab.dart';
import 'discover_tab.dart';
import 'routes_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = const [MapTab(), DiscoverTab(), RoutesTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFFC107),
              onPressed: () => _showHazardSheet(context),
              child: const Icon(Icons.add, color: Color(0xFF1A1A2E)),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFFC107),
          unselectedItemColor: const Color(0xFF999999),
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.route_rounded), label: 'My Routes'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showHazardSheet(BuildContext context) {
    int rating = 0;
    final tags = <String>{};
    final descController = TextEditingController();
    String? errorMsg;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        void trySubmit() {
          // Validate all fields
          if (rating == 0) {
            setS(() => errorMsg = 'Please select a danger level');
            return;
          }
          if (tags.isEmpty) {
            setS(() => errorMsg = 'Please select at least one hazard type');
            return;
          }
          if (descController.text.trim().isEmpty) {
            setS(() => errorMsg = 'Please describe the hazard');
            return;
          }
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Report Submitted!'), backgroundColor: Color(0xFF4CAF50)));
        }

        return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 16, left: 20, right: 20, top: 12),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('📍 Report Hazard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          const Text('Help fellow runners & cyclists stay safe', style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
          // Error message
          if (errorMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[200]!)),
              child: Row(children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMsg!, style: TextStyle(color: Colors.red[700], fontSize: 12))),
              ]),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Danger Level *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(children: List.generate(5, (i) => GestureDetector(
            onTap: () => setS(() { rating = i + 1; errorMsg = null; }),
            child: Padding(padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.star_rounded, size: 32, color: i < rating ? const Color(0xFFFFC107) : Colors.grey[300])),
          ))),
          const SizedBox(height: 16),
          const Text('Hazard Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['🔦 Poor Lighting', '🚗 Traffic', '🚧 Construction', '🕳️ Road Damage', '⚠️ Unsafe Area', '🌊 Flooding']
            .map((t) => GestureDetector(
              onTap: () => setS(() { tags.contains(t) ? tags.remove(t) : tags.add(t); errorMsg = null; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: tags.contains(t) ? const Color(0xFFFFF3E0) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tags.contains(t) ? const Color(0xFFFFC107) : Colors.transparent, width: 1.5)),
                child: Text(t, style: TextStyle(fontSize: 13, fontWeight: tags.contains(t) ? FontWeight.w600 : FontWeight.w400)),
              ),
            )).toList()),
          const SizedBox(height: 16),
          const Text('Description *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: descController, maxLines: 2,
            onChanged: (_) { if (errorMsg != null) setS(() => errorMsg = null); },
            decoration: InputDecoration(hintText: 'Describe the hazard in detail…', filled: true, fillColor: const Color(0xFFF8F6F3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: trySubmit,
            icon: const Icon(Icons.check_rounded), label: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w700)))),
          const SizedBox(height: 20),
          ]),
        ),
      ); }),
    );
  }
}
