import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class CustomButton extends StatelessWidget {

  final String text;

  final VoidCallback onPressed;

  const CustomButton({

    super.key,

    required this.text,

    required this.onPressed,

  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 55,

      child: ElevatedButton(

        onPressed: onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          elevation: 4,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(15),

          ),

        ),

        child: Text(

          text,

          style: const TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }

}