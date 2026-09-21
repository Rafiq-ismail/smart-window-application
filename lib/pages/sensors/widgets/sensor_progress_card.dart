import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class SensorProgressCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double progress;

  const SensorProgressCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double safeProgress =
    progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.divider,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [


          Row(
            children: [

              // SENSOR ICON
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),

                  borderRadius:
                  BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              // TITLE
              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // VALUE
              Text(
                value,

                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),


          // PROGRESS BAR


          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: safeProgress,

              minHeight: 7,

              backgroundColor:
              AppColors.divider,

              valueColor:
              AlwaysStoppedAnimation<Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}