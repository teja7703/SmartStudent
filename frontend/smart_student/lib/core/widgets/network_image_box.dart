import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A network image with built-in loading shimmer, error fallback and
/// an optional gradient overlay. Falls back to a colored placeholder when
/// the URL is empty or fails to load.
class NetworkImageBox extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color color;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_rounded,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(loading: true);
      },
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      height: height,
      width: width,
      color: color.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Icon(fallbackIcon, color: color.withValues(alpha: 0.6), size: 40),
    );
  }
}
