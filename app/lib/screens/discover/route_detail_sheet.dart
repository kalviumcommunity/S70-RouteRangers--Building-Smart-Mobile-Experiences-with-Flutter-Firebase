import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/route_model.dart';
import '../../models/route_review.dart';
import '../../providers/app_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/discover_widgets.dart';
import '../map_tab.dart';

class RouteDetailSheet extends StatelessWidget {
  final RouteModel route;
  const RouteDetailSheet({required this.route, super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, scrollController) {
        final firestore = FirestoreService();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 24, 
              right: 24, 
              top: 12, 
              bottom: 12 + MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(route.type.toUpperCase(), style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text(route.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(14)),
                      child: Text('★ ${route.rating}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFFC107), fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Map Placeholder
                Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])),
                  child: Center(child: Icon(Icons.map_outlined, color: Colors.white.withAlpha(80), size: 48)),
                ),
                const SizedBox(height: 24),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                Text(route.desc, style: const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5)),
                const SizedBox(height: 24),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BigStat(Icons.straighten_rounded, route.dist, 'Distance'),
                    BigStat(Icons.speed_rounded, route.time, 'Avg. Time'),
                    const BigStat(Icons.terrain_rounded, 'Mod.', 'Elevation'),
                  ],
                ),
                const SizedBox(height: 32),
                
                // --- Community Reviews Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Community Reviews', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E))),
                    TextButton(
                      onPressed: () => _showReviewForm(context, route.name),
                      child: const Text('Add Review', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<RouteReview>>(
                  stream: firestore.getRouteReviews(route.name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) return const Text('No reviews yet. Be the first!', style: TextStyle(color: Colors.grey, fontSize: 13));
                    
                    return Column(
                      children: reviews.map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8F6F3), borderRadius: BorderRadius.circular(16)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('★ ${r.rating}', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 4),
                          Text(r.comment, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                        ]),
                      )).toList(),
                    );
                  }
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate directly without popping the modal first to avoid unmounted context crashes
                      Navigator.of(context, rootNavigator: true).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MapTab()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Start Navigation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviewForm(BuildContext context, String routeName) {
    double rating = 5;
    final commentController = TextEditingController();
    final appState = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Review $routeName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your Rating'),
            StatefulBuilder(
              builder: (context, setState) => Slider(
                value: rating, min: 1, max: 5, divisions: 4, 
                label: rating.toString(), 
                onChanged: (v) => setState(() => rating = v),
              ),
            ),
            TextField(controller: commentController, decoration: const InputDecoration(hintText: 'Your thoughts...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final review = RouteReview(
                id: '',
                routeName: routeName,
                rating: rating,
                comment: commentController.text,
                tags: [],
                timestamp: DateTime.now(),
                userId: appState.user?.uid ?? 'anonymous',
                userName: appState.user?.displayName ?? appState.user?.email?.split('@')[0] ?? 'Explorer',
              );
              Navigator.pop(ctx);
              try {
                await appState.addReview(review);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Review submitted!'), backgroundColor: Color(0xFF4CAF50)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Could not submit review ($e)'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
