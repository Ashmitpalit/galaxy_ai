import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/ui_constants.dart';

class PinShimmer extends StatelessWidget {
  final double height;
  
  const PinShimmer({
    super.key,
    required this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.pinBorderRadius),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UIConstants.pinBorderRadius),
          ),
        ),
      ),
    );
  }
}
