import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class StoryTypeOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const StoryTypeOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.containerBackground,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: isSelected ? Colors.transparent : Colors.grey),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
