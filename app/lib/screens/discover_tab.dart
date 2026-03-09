import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../data/dummy_data.dart';
import '../widgets/discover_widgets.dart';
import 'discover/route_detail_sheet.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});
  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Sticky Hero Header with Search and Tabs
            Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🐝 ', style: TextStyle(fontSize: 22)),
                      Text('Discover', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Find your perfect path', style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13)),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white.withAlpha(150), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search routes...',
                              hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Custom Styled TabBar
                  const TabBar(
                    isScrollable: false,
                    indicatorColor: Color(0xFFFFC107),
                    indicatorWeight: 3,
                    labelColor: Color(0xFFFFC107),
                    unselectedLabelColor: Colors.white60,
                    dividerColor: Colors.transparent,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Running'),
                      Tab(text: 'Cycling'),
                      Tab(text: 'Walking'),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _DiscoverPage(type: 'All', searchQuery: _searchQuery),
                  _DiscoverPage(type: 'Running', searchQuery: _searchQuery),
                  _DiscoverPage(type: 'Cycling', searchQuery: _searchQuery),
                  _DiscoverPage(type: 'Walking', searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  final String type;
  final String searchQuery;

  const _DiscoverPage({required this.type, required this.searchQuery});

  List<RouteModel> get _filteredRoutes {
    var routes = allRoutesData.toList();
    if (type != 'All') {
      routes = routes.where((r) => r.type == type).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      routes = routes.where((r) => 
        r.name.toLowerCase().contains(q) || 
        r.desc.toLowerCase().contains(q)
      ).toList();
    }
    return routes;
  }

  List<TrendingModel> get _filteredTrending {
    var trending = allTrendingData.toList();
    if (type != 'All') {
      trending = trending.where((t) => t.type == type).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      trending = trending.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return trending;
  }

  void _showRouteDetail(BuildContext ctx, RouteModel route) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RouteDetailSheet(route: route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = _filteredRoutes;
    final trending = _filteredTrending;

    if (routes.isEmpty && trending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No routes found in this category',
              style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // Featured (only on first page or when specifically filtered)
        if (searchQuery.isEmpty && routes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                const SizedBox(width: 6),
                const Text('Route of the Day', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFFFFC107))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => _showRouteDetail(context, routes[0]),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.map_rounded, color: Colors.white.withAlpha(50), size: 64)),
                          Positioned(
                            top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                              child: Text(routes[0].type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(routes[0].name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E)))),
                              Text('★ ${routes[0].rating}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFFC107))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(routes[0].desc, style: const TextStyle(color: Color(0xFF666666), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              StatChip(routes[0].dist, 'km'),
                              const SizedBox(width: 20),
                              StatChip(routes[0].time, 'min'),
                              const SizedBox(width: 20),
                              const StatChip('Verified', 'Safe'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],

        // Trending Carousel
        if (trending.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🔥 Trending ${type == 'All' ? 'Near You' : type}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E))),
                TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: trending.length,
              itemBuilder: (_, i) => TrendingCard(
                data: trending[i],
                onTap: () {
                  try {
                    final route = allRoutesData.firstWhere(
                      (r) => r.name.startsWith(trending[i].title) || trending[i].title.startsWith(r.name)
                    );
                    _showRouteDetail(context, route);
                  } catch (e) {
                    // Route not found, ignore tap
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],

        // List of Routes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${type == 'All' ? '📍 Popular' : '📍 $type'} Routes', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A2E))),
              Text('${routes.length} found', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...routes.map((r) => RouteCard(route: r, onTap: () => _showRouteDetail(context, r))),
        const SizedBox(height: 20),
      ],
    );
  }
}
