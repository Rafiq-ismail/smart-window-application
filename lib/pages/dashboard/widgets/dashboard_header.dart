import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String userName = "User";

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final name = await AuthService.instance.getUserName();

    if (!mounted) return;

    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final headerColor = isDark
        ? colors.surface
        : colors.primary;

    final borderColor = isDark
        ? colors.outlineVariant
        : Colors.white.withValues(alpha: 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.circular(26),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.12 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Evening 👋",
                      style: TextStyle(
                        color: isDark
                            ? colors.onSurfaceVariant
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? colors.onSurface
                            : Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Smart Window System",
                      style: TextStyle(
                        color: isDark
                            ? colors.onSurfaceVariant
                            : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ONLINE INDICATOR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: isDark
                      ? colors.primaryContainer
                      : Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),

                  border: Border.all(
                    color: isDark
                        ? colors.outlineVariant
                        : Colors.white.withValues(alpha: 0.10),
                  ),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 9,
                      color: Colors.greenAccent,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Online",
                      style: TextStyle(
                        color: isDark
                            ? colors.onPrimaryContainer
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // STATS
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),

            decoration: BoxDecoration(
              color: isDark
                  ? colors.primaryContainer
                  .withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: isDark
                    ? colors.outlineVariant
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),

            child: Row(
              children: [
                Expanded(
                  child: _DashboardStat(
                    icon: Icons.window_rounded,
                    value: "3",
                    label: "Windows",
                    isDark: isDark,
                  ),
                ),

                _VerticalDivider(
                  isDark: isDark,
                ),

                Expanded(
                  child: _DashboardStat(
                    icon: Icons.sensors_rounded,
                    value: "6",
                    label: "Sensors",
                    isDark: isDark,
                  ),
                ),

                _VerticalDivider(
                  isDark: isDark,
                ),

                Expanded(
                  child: _DashboardStat(
                    icon:
                    Icons.notifications_active_rounded,
                    value: "1",
                    label: "Alerts",
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// DASHBOARD STAT

class _DashboardStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _DashboardStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          color: isDark
              ? colors.primary
              : Colors.white70,
          size: 20,
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: TextStyle(
            color: isDark
                ? colors.onSurface
                : Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(
            color: isDark
                ? colors.onSurfaceVariant
                : Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}


// VERTICAL DIVIDER

class _VerticalDivider extends StatelessWidget {
  final bool isDark;

  const _VerticalDivider({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 55,
      color: isDark
          ? colors.outlineVariant
          : Colors.white.withValues(alpha: 0.15),
    );
  }
}