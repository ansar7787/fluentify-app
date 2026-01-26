import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient (Fresh Green)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E9), // Very light green
                Color(0xFFF1F8E9), // Pale Green
                Colors.white,
              ],
            ),
          ),
        ),

        // Vibrant Green Blobs
        // Top Right
        Positioned(
          top: -120,
          right: -100,
          child: _AuroraBlob(
            colors: [
              AppTheme.secondaryGreen.withValues(alpha: 0.3),
              AppTheme.secondaryGreen.withValues(alpha: 0),
            ],
            size: 500,
          ),
        ),

        // Mid Left
        Positioned(
          top: 250,
          left: -150,
          child: _AuroraBlob(
            colors: [
              AppTheme.secondaryGreen.withValues(alpha: 0.2),
              AppTheme.secondaryGreen.withValues(alpha: 0),
            ],
            size: 450,
          ),
        ),

        // Bottom Right
        Positioned(
          bottom: -100,
          right: -80,
          child: _AuroraBlob(
            colors: [
              const Color(0xFF66BB6A)
                  .withValues(alpha: 0.15), // Slightly different green
              const Color(0xFF66BB6A).withValues(alpha: 0),
            ],
            size: 400,
          ),
        ),

        // Top Left Accent
        Positioned(
          top: 100,
          left: -50,
          child: _AuroraBlob(
            colors: [
              AppTheme.secondaryGreen.withValues(alpha: 0.1),
              AppTheme.secondaryGreen.withValues(alpha: 0),
            ],
            size: 300,
          ),
        ),

        // Blur Layer - Glassmorphism effect base
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.white.withValues(alpha: 0.1)),
        ),

        // Content
        child,
      ],
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final List<Color> colors;
  final double size;

  const _AuroraBlob({required this.colors, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
        ),
      ),
    );
  }
}
