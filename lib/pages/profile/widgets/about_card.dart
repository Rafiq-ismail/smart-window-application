import 'package:flutter/material.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.18 : 0.035,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: colors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  "About Smart Window",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // INFORMATION
          const _InfoRow(
            icon: Icons.window_rounded,
            title: "Application",
            value: "Smart Window IoT",
          ),

          const _Divider(),

          const _InfoRow(
            icon: Icons.code_rounded,
            title: "Version",
            value: "1.0.0",
          ),

          const _Divider(),

          const _InfoRow(
            icon: Icons.flutter_dash_rounded,
            title: "Framework",
            value: "Flutter",
          ),

          const _Divider(),

          const _InfoRow(
            icon: Icons.memory_rounded,
            title: "Controller",
            value: "ESP32",
          ),

          const _Divider(),

          const _InfoRow(
            icon: Icons.person_outline_rounded,
            title: "Developer",
            value: "Muhammad Rafiq",
          ),
        ],
      ),
    );
  }
}


// INFO ROW

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colors.primary,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.onSurface.withValues(
                  alpha: 0.65,
                ),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// DIVIDER

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant,
    );
  }
}