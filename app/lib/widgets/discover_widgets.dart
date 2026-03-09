import 'package:flutter/material.dart';
import '../models/route_model.dart';

class StatChip extends StatelessWidget {
  final String val, label;
  const StatChip(this.val, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A1A2E))),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
    ],
  );
}

class BigStat extends StatelessWidget {
  final IconData icon; 
  final String val, label;
  const BigStat(this.icon, this.val, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: const Color(0xFFFFC107), size: 28),
      const SizedBox(height: 8),
      Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E))),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
    ],
  );
}

class TrendingCard extends StatelessWidget {
  final TrendingModel data;
  final VoidCallback? onTap;
  const TrendingCard({required this.data, this.onTap, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: data.color.withAlpha(50), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 18))),
        ),
        const Spacer(),
        Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(data.meta, style: const TextStyle(color: Color(0xFF999999), fontSize: 11)),
        const SizedBox(height: 4),
        Text(data.rating, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ),
  ),
  );
}

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onTap;
  const RouteCard({required this.route, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: const Color(0xFFF8F8F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: route.iconBg.withAlpha(80), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(route.typeEmoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(route.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1A2E)), overflow: TextOverflow.ellipsis)),
                    if (route.verified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF4CAF50), size: 14),
                    ],
                  ],
                ),
                Text('${route.dist} · ${route.time}', style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
                const SizedBox(height: 2),
                Text(route.stars, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFEEEEEE), size: 14),
        ],
      ),
    ),
  );
}
