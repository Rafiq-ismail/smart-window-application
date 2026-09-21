import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const AlertBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color..withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color,
          width: 1.3,
        ),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
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