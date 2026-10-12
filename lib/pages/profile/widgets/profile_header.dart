import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String userName = "User";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final name = await AuthService.instance.getUserName();
    final email = await AuthService.instance.getUserEmail();

    if (!mounted) return;

    setState(() {
      userName = name;
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // Premium Smart Window palette
    final gradientColors = isDark
        ? const [
      Color(0xFF1B2A1E),
      Color(0xFF2B4130),
    ]
        : const [
      Color(0xFF71866D),
      Color(0xFF91A68A),
    ];

    const foregroundColor = Color(0xFFF7FAF5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        // PREMIUM SAGE GRADIENT
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: isDark ? 0.08 : 0.12,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.22 : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          // PROFILE ICON
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDark ? 0.10 : 0.92,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDark ? 0.16 : 0.30,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: isDark
                  ? const Color(0xFFB8CEB2)
                  : const Color(0xFF53634E),
            ),
          ),

          const SizedBox(height: 16),

          // NAME
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: foregroundColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // EMAIL
          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foregroundColor.withValues(
                alpha: 0.82,
              ),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Smart Window Administrator",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foregroundColor.withValues(
                alpha: 0.68,
              ),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          // CONNECTION STATUS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDark ? 0.08 : 0.14,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDark ? 0.12 : 0.20,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF78E6A1),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                const Text(
                  "ESP32 Connected",
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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