// lib/widgets/refresh.dart
import 'package:flutter/material.dart';

/// Pembungkus RefreshIndicator.adaptive yang reusable.
class AppRefresh extends StatelessWidget {
  const AppRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
    this.displacement,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  /// Jarak awal gesture dari tepi atas.
  final double edgeOffset;

  /// Jarak turun indikator dari tepi atas saat tampil (default 40).
  final double? displacement;

  /// Warna progress.
  final Color? color;

  /// Warna background indikator.
  final Color? backgroundColor;

  /// Ketebalan stroke indikator (default 2).
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      edgeOffset: edgeOffset,
      displacement: displacement ?? 40.0,      // <-- fix: pastikan non-null
      color: color,
      backgroundColor: backgroundColor,
      strokeWidth: strokeWidth ?? 2.0,
      child: child,
    );
  }
}
