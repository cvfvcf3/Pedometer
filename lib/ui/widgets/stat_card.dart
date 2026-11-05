import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, required this.unit, required this.icon});
  final String label; final String value; final String unit; final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final faint = scheme.onSurface.withValues(alpha: 0.55);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 10),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: muted, height: 1.2)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 11, color: faint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
