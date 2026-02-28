import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatefulWidget {
  final String imageUrl;

  const ShimmerImage({super.key, required this.imageUrl});

  @override
  State<ShimmerImage> createState() =>
      _ShimmerImageState();
}

class _ShimmerImageState extends State<ShimmerImage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_loaded)
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder:
              (context, child, loadingProgress) {
            if (loadingProgress == null) {
              Future.microtask(() {
                if (mounted) {
                  setState(() => _loaded = true);
                }
              });
              return child;
            }
            return const SizedBox();
          },
          errorBuilder: (_, __, ___) =>
              Container(color: Colors.grey.shade300),
        ),
      ],
    );
  }
}