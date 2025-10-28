import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0, _controller.value, 1],
              colors: [Colors.grey[400]!, Colors.grey[300]!, Colors.grey[200]!],
            ),
          ),
        );
      },
    );
  }
}

Widget buildSkeletonLoading() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    buildSkeletonBox(width: 60, height: 60, radius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSkeletonBox(width: 100, height: 16),
                          const SizedBox(height: 8),
                          buildSkeletonBox(width: 150, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                buildSkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                buildSkeletonBox(width: 200, height: 12),
                const SizedBox(height: 12),
                Row(
                  children: [
                    buildSkeletonBox(width: 70, height: 36, radius: 6),
                    const SizedBox(width: 8),
                    buildSkeletonBox(width: 70, height: 36, radius: 6),
                    const SizedBox(width: 8),
                    buildSkeletonBox(width: 70, height: 36, radius: 6),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildSkeletonBox({
  required double width,
  required double height,
  double radius = 4,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(radius),
    ),
    child: ShimmerEffect(),
  );
}
