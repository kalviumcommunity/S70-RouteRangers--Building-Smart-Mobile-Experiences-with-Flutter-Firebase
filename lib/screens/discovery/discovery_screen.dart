import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/route_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/route_card.dart';
import '../route_creation/create_route_screen.dart';
import '../route_details/route_details_screen.dart';

final selectedDistanceFilterProvider = StateProvider<String>((ref) => 'all');

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routesAsync = ref.watch(filteredRoutesProvider);
    final verifiedOnly = ref.watch(routeFilterVerifiedOnlyProvider);
    final sortBy = ref.watch(routeSortByProvider);
    final selectedTag = ref.watch(routeSelectedTagProvider);
    final distanceFilter = ref.watch(selectedDistanceFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Safe Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter Options',
            onPressed: () {
              _showFilterModal(context);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Modern Search Input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(routeSearchQueryProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search routes, parks, neighborhoods...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryDark),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(routeSearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Fast Filter Row: Verified Toggle & Sort Picker
                Row(
                  children: [
                    FilterChip(
                      selected: verifiedOnly,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 13,
                            color: verifiedOnly ? AppColors.verifiedBadge : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 4),
                          const Text('Verified Hives Only'),
                        ],
                      ),
                      selectedColor: AppColors.verifiedBadgeBackground,
                      checkmarkColor: AppColors.verifiedBadge,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: verifiedOnly ? FontWeight.w800 : FontWeight.w600,
                        color: verifiedOnly ? AppColors.verifiedBadge : null,
                      ),
                      onSelected: (selected) {
                        ref.read(routeFilterVerifiedOnlyProvider.notifier).state = selected;
                      },
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      initialValue: sortBy,
                      onSelected: (val) {
                        ref.read(routeSortByProvider.notifier).state = val;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sort, size: 15, color: AppColors.primaryDark),
                            const SizedBox(width: 5),
                            Text(
                              sortBy == 'safety'
                                  ? 'Highest Safety'
                                  : sortBy == 'distance'
                                      ? 'Distance'
                                      : 'Most Reviews',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'safety',
                          child: Text('Highest Safety Rating'),
                        ),
                        PopupMenuItem(
                          value: 'distance',
                          child: Text('Shortest Distance'),
                        ),
                        PopupMenuItem(
                          value: 'reviews',
                          child: Text('Most Community Reviews'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Horizontal Tags Filter Bar
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTagChip(
                  label: 'All Conditions',
                  isSelected: selectedTag == null,
                  onTap: () => ref.read(routeSelectedTagProvider.notifier).state = null,
                ),
                const SizedBox(width: 6),
                ...AppConstants.reviewTags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTagChip(
                      label: tag,
                      isSelected: selectedTag == tag,
                      onTap: () => ref.read(routeSelectedTagProvider.notifier).state =
                          selectedTag == tag ? null : tag,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Route Cards Feed
          Expanded(
            child: routesAsync.when(
              data: (routes) {
                var displayList = routes;
                if (distanceFilter == 'short') {
                  displayList = routes.where((r) => r.distanceKm < 4.0).toList();
                } else if (distanceFilter == 'medium') {
                  displayList = routes.where((r) => r.distanceKm >= 4.0 && r.distanceKm <= 7.0).toList();
                } else if (distanceFilter == 'long') {
                  displayList = routes.where((r) => r.distanceKm > 7.0).toList();
                }

                if (displayList.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.route_outlined,
                    title: 'No routes match your filters',
                    description: 'Try adjusting your search criteria or resetting filters.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final route = displayList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RouteCard(
                        route: route,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RouteDetailsScreen(routeId: route.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error loading routes: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_road),
        label: const Text('Map Route', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateRouteScreen()),
          );
        },
      ),
    );
  }

  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? AppColors.onPrimary
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Consumer(
          builder: (context, ref, child) {
            final distance = ref.watch(selectedDistanceFilterProvider);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Filter by Distance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Distances'),
                        selected: distance == 'all',
                        selectedColor: AppColors.primary,
                        onSelected: (_) => ref.read(selectedDistanceFilterProvider.notifier).state = 'all',
                      ),
                      ChoiceChip(
                        label: const Text('< 4 km (Quick Loop)'),
                        selected: distance == 'short',
                        selectedColor: AppColors.primary,
                        onSelected: (_) => ref.read(selectedDistanceFilterProvider.notifier).state = 'short',
                      ),
                      ChoiceChip(
                        label: const Text('4–7 km (Standard)'),
                        selected: distance == 'medium',
                        selectedColor: AppColors.primary,
                        onSelected: (_) => ref.read(selectedDistanceFilterProvider.notifier).state = 'medium',
                      ),
                      ChoiceChip(
                        label: const Text('> 7 km (Long Run / Ride)'),
                        selected: distance == 'long',
                        selectedColor: AppColors.primary,
                        onSelected: (_) => ref.read(selectedDistanceFilterProvider.notifier).state = 'long',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
