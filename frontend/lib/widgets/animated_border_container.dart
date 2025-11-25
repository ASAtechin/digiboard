import 'package:flutter/material.dart';

/// Animated Border Container Widget
/// 
/// Displays a container with an animated pulsing border that cycles through
/// a list of colors. The border pulses smoothly with a configurable duration.
/// 
/// Example usage:
/// ```dart
/// AnimatedBorderContainer(
///   pulseColors: [Colors.blue, Colors.purple, Colors.pink],
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Content'),
///   ),
/// )
/// ```
class AnimatedBorderContainer extends StatefulWidget {
  /// The widget to display inside the animated border container
  final Widget child;

  /// List of colors to cycle through for the border pulse animation
  final List<Color> pulseColors;

  /// Duration of the complete animation cycle
  /// Default: 3 seconds (0.75s per color)
  final Duration animationDuration;

  /// Border radius of the container
  /// Default: 12.0
  final double borderRadius;

  /// Width of the border in pixels
  /// Pulses between borderWidth and borderWidth + 1
  /// Default: 2.0
  final double borderWidth;

  /// Enable or disable the pulse animation
  /// Default: true
  final bool enablePulse;

  const AnimatedBorderContainer({
    super.key,
    required this.child,
    this.pulseColors = const [
      Color(0xFF3B82F6), // Blue
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFF06B6D4), // Cyan
    ],
    this.animationDuration = const Duration(seconds: 3),
    this.borderRadius = 12.0,
    this.borderWidth = 2.0,
    this.enablePulse = true,
  });

  @override
  State<AnimatedBorderContainer> createState() =>
      _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Color?>> _colorAnimations;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Set up color animations for smooth transitions between colors
    _colorAnimations = [];
    final colorCount = widget.pulseColors.length;

    for (int i = 0; i < colorCount; i++) {
      final currentColor = widget.pulseColors[i];
      final nextColor = widget.pulseColors[(i + 1) % colorCount];

      // Each color gets a portion of the animation timeline
      final start = i / colorCount;
      final end = (i + 1) / colorCount;

      _colorAnimations.add(
        ColorTween(
          begin: currentColor,
          end: nextColor,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.linear),
          ),
        ),
      );
    }

    // Set up border width pulse animation
    // Uses a sine-like curve for smooth pulsing effect
    _widthAnimation = Tween<double>(
      begin: widget.borderWidth,
      end: widget.borderWidth + 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    if (widget.enablePulse) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedBorderContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle enable/disable of pulse
    if (oldWidget.enablePulse != widget.enablePulse) {
      if (widget.enablePulse) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }

    // Handle animation duration changes
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Get the current color based on animation progress
        final currentColorIndex = (_animationController.value *
                widget.pulseColors.length)
            .floor() %
            widget.pulseColors.length;
        final currentAnimation = _colorAnimations[currentColorIndex];
        final currentColor =
            currentAnimation.value ?? widget.pulseColors[currentColorIndex];

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: currentColor,
              width: _widthAnimation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Alternative implementation with shadow glow effect instead of border
/// Uncomment to use this instead of the border version
/*
class AnimatedGlowContainer extends StatefulWidget {
  final Widget child;
  final List<Color> glowColors;
  final Duration animationDuration;
  final double borderRadius;
  final bool enableGlow;

  const AnimatedGlowContainer({
    super.key,
    required this.child,
    this.glowColors = const [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ],
    this.animationDuration = const Duration(seconds: 3),
    this.borderRadius = 12.0,
    this.enableGlow = true,
  });

  @override
  State<AnimatedGlowContainer> createState() => _AnimatedGlowContainerState();
}

class _AnimatedGlowContainerState extends State<AnimatedGlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Color?>> _colorAnimations;
  late Animation<double> _spreadAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _colorAnimations = [];
    final colorCount = widget.glowColors.length;

    for (int i = 0; i < colorCount; i++) {
      final currentColor = widget.glowColors[i];
      final nextColor = widget.glowColors[(i + 1) % colorCount];

      final start = i / colorCount;
      final end = (i + 1) / colorCount;

      _colorAnimations.add(
        ColorTween(
          begin: currentColor,
          end: nextColor,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.linear),
          ),
        ),
      );
    }

    _spreadAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableGlow) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final currentColorIndex =
            (_animationController.value * widget.glowColors.length).floor() %
                widget.glowColors.length;
        final currentAnimation = _colorAnimations[currentColorIndex];
        final currentColor =
            currentAnimation.value ?? widget.glowColors[currentColorIndex];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: currentColor.withOpacity(0.6),
                blurRadius: _spreadAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
*/
