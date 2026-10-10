import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Country flag loaded from the network and cached; falls back to the emoji flag.
class FlagImage extends StatelessWidget {
  final String url;
  final String emoji;
  final double width;
  final double height;
  final double radius;
  final BoxFit fit;

  const FlagImage({
    super.key,
    required this.url,
    required this.emoji,
    this.width = 64,
    this.height = 44,
    this.radius = 10,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: AppColors.background,
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: height * 0.6)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, _) => Container(
                width: width,
                height: height,
                color: AppColors.border,
              ),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
