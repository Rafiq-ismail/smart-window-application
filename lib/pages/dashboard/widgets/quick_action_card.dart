import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colors.outlineVariant,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.10 : 0.035,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: isDark ? 0.14 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: color.withValues(
                      alpha: isDark ? 0.16 : 0.08,
                    ),
                  ),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: 8),

              // TITLE
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}