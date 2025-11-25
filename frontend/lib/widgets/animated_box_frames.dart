import 'package:flutter/material.dart';
import '../themes/design_system.dart';

/// AnimatedBoxFrame Widget
/// Inspired by Google's Material Design presentation style
/// Features dynamic color transitions and rotating frame animations
class AnimatedBoxFrame extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Duration animationDuration;
  final List<Color>? colors;
  final bool enableAutoAnimation;

  const AnimatedBoxFrame({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 800),
    this.colors,
    this.enableAutoAnimation = true,
  }) : super(key: key);

  @override
  State<AnimatedBoxFrame> createState() => _AnimatedBoxFrameState();
}

class _AnimatedBoxFrameState extends State<AnimatedBoxFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _colorIndex = 0;

  late List<Color> _colors;

  @override
  void initState() {
    super.initState();

    // Default Google-inspired colors
    _colors = widget.colors ??
        [
          DesignSystem.primary, // Indigo
          DesignSystem.secondary, // Pink
          DesignSystem.tertiary, // Teal
          DesignSystem.success, // Green
          DesignSystem.warning, // Amber
        ];

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.enableAutoAnimation) {
      _startColorCycle();
    }
  }

  void _startColorCycle() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.forward().then((_) {
          if (mounted) {
            setState(() {
              _colorIndex = (_colorIndex + 1) % _colors.length;
            });
            _animationController.reset();
            _startColorCycle();
          }
        });
      }
    });
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
        final currentColor = _colors[_colorIndex];
        final nextColor = _colors[(_colorIndex + 1) % _colors.length];

        // Interpolate between colors
        final Color frameColor = Color.lerp(currentColor, nextColor,
                _animationController.value) ??
            currentColor;

        return Container(
          margin: EdgeInsets.all(DesignSystem.spacing3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: frameColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      frameColor.withOpacity(0.05),
                      frameColor.withOpacity(0.02),
                    ],
                  ),
                ),
              ),

              // Border animation
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                  border: Border.all(
                    color: frameColor,
                    width: 3,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(DesignSystem.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with color indicator
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: frameColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: DesignSystem.spacing2),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: DesignSystem.headlineSmall.copyWith(
                              color: DesignSystem.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Subtitle
                    if (widget.subtitle != null) ...[
                      SizedBox(height: DesignSystem.spacing1),
                      Text(
                        widget.subtitle!,
                        style: DesignSystem.bodySmall.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ],

                    SizedBox(height: DesignSystem.spacing3),

                    // Animated colored line
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [frameColor, frameColor.withOpacity(0.3)],
                        ),
                      ),
                    ),

                    SizedBox(height: DesignSystem.spacing3),

                    // Child content
                    widget.child,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// AnimatedColorGrid Widget
/// Display multiple animated boxes with rotating colors
class AnimatedColorGrid extends StatefulWidget {
  final List<AnimatedGridItem> items;
  final int crossAxisCount;

  const AnimatedColorGrid({
    Key? key,
    required this.items,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  State<AnimatedColorGrid> createState() => _AnimatedColorGridState();
}

class _AnimatedColorGridState extends State<AnimatedColorGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: DesignSystem.spacing3,
        mainAxisSpacing: DesignSystem.spacing3,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return AnimatedGridItemWidget(
          item: widget.items[index],
          animationController: _animationController,
          index: index,
        );
      },
    );
  }
}

/// Individual animated grid item
class AnimatedGridItemWidget extends StatelessWidget {
  final AnimatedGridItem item;
  final AnimationController animationController;
  final int index;

  const AnimatedGridItemWidget({
    Key? key,
    required this.item,
    required this.animationController,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Stagger animation for each item
        final staggerValue = (animationController.value + (index * 0.1)) % 1.0;

        // Bounce effect
        final bounceValue = (staggerValue * 3).clamp(0.0, 1.0);
        final bounceOffset = (bounceValue < 0.5
            ? bounceValue * 2
            : 2 - (bounceValue * 2)); // 0->1->0

        return Transform.translate(
          offset: Offset(0, bounceOffset * 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(DesignSystem.cornerRadiusLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color,
                  item.color.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.4),
                  blurRadius: 16 + (bounceOffset * 8),
                  offset: Offset(0, 4 + (bounceOffset * 4)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                onTap: item.onTap,
                child: Padding(
                  padding: EdgeInsets.all(DesignSystem.paddingMedium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with rotation animation
                      Transform.rotate(
                        angle: animationController.value * 2 * 3.14159,
                        child: Icon(
                          item.icon,
                          size: DesignSystem.iconSizeXLarge,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: DesignSystem.spacing2),
                      // Title
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: DesignSystem.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: DesignSystem.spacing1),
                      // Subtitle
                      Text(
                        item.subtitle,
                        textAlign: TextAlign.center,
                        style: DesignSystem.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Data model for animated grid items
class AnimatedGridItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  AnimatedGridItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// AnimatedCardStack Widget
/// Create a stacked card effect like Google Slides presentations
class AnimatedCardStack extends StatefulWidget {
  final List<StackedCard> cards;
  final Duration autoRotateInterval;

  const AnimatedCardStack({
    Key? key,
    required this.cards,
    this.autoRotateInterval = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<AnimatedCardStack> createState() => _AnimatedCardStackState();
}

class _AnimatedCardStackState extends State<AnimatedCardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _startCardRotation();
  }

  void _startCardRotation() {
    Future.delayed(widget.autoRotateInterval, () {
      if (mounted) {
        _animationController.forward().then((_) {
          if (mounted) {
            setState(() {
              _currentCardIndex =
                  (_currentCardIndex + 1) % widget.cards.length;
            });
            _animationController.reset();
            _startCardRotation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.cards.length, (index) {
        final card = widget.cards[index];
        final isCurrentCard = index == _currentCardIndex;
        final isPreviousCard = index ==
            (_currentCardIndex - 1 + widget.cards.length) % widget.cards.length;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Calculate transform based on position
            double offsetX = 0;
            double offsetY = 0;
            double opacity = 0;
            double scale = 0.85;

            if (isCurrentCard) {
              // Current card slides in from right
              offsetX = 50 * (1 - _animationController.value);
              opacity = 1;
              scale = 1;
            } else if (isPreviousCard) {
              // Previous card slides out to left
              offsetX = -50 * _animationController.value;
              opacity = 1 - (_animationController.value * 0.3);
              scale = 1 - (_animationController.value * 0.05);
            } else {
              // Other cards in stack
              offsetY = 10;
              opacity = 0.6;
            }

            return Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: EdgeInsets.all(DesignSystem.spacing3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        DesignSystem.cornerRadiusLarge,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          card.color,
                          card.color.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: card.color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(DesignSystem.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large icon
                          Icon(
                            card.icon,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: DesignSystem.spacing3),
                          // Title
                          Text(
                            card.title,
                            style: DesignSystem.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: DesignSystem.spacing2),
                          // Description
                          Text(
                            card.description,
                            style: DesignSystem.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Data model for stacked cards
class StackedCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  StackedCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// AnimatedFeatureCard Widget
/// Highlight individual features with animated background patterns
class AnimatedFeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AnimatedFeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<AnimatedFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.5 : 0.3),
                    blurRadius: _isHovered ? 30 : 20,
                    offset: Offset(0, _isHovered ? 12 : 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(DesignSystem.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated icon background
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Transform.rotate(
                        angle: _animationController.value * 2 * 3.14159,
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing3),
                    // Title
                    Text(
                      widget.title,
                      style: DesignSystem.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing2),
                    // Description
                    Text(
                      widget.description,
                      style: DesignSystem.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing3),
                    // Animated progress bar
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100 * _animationController.value,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
