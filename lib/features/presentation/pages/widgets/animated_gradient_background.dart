import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Color? primaryColor;
  final Color? secondaryColor;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedGradientBackground({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.primaryColor != widget.primaryColor ||
        oldWidget.secondaryColor != widget.secondaryColor) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPrimary =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);
    final defaultSecondary =
        isDark ? const Color(0xFF16213E) : const Color(0xFFE8E8E8);

    final primaryColor = widget.primaryColor != null
        ? _adjustForTheme(widget.primaryColor!, isDark)
        : defaultPrimary;

    final secondaryColor = widget.secondaryColor != null
        ? _adjustForTheme(widget.secondaryColor!, isDark)
        : defaultSecondary;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + t, -1.0),
              end: Alignment(1.0 - t, 1.0),
              // ✔️ NO STOPS → no crashes
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Color _adjustForTheme(Color color, bool isDark) {
    if (isDark) {
      return Color.lerp(color, Colors.black, 0.6) ?? color;
    } else {
      return Color.lerp(color, Colors.white, 0.35) ?? color;
    }
  }
}
