import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';
import '../themes/design_system.dart';

/// CurrentLectureBanner Widget
/// Shows the currently in-progress lecture with animated effects
/// Displays: Lecture name, teacher, chapter/subject, and current time
class CurrentLectureBanner extends StatefulWidget {
  final Lecture? currentLecture;
  final DateTime? currentTime;

  const CurrentLectureBanner({
    Key? key,
    this.currentLecture,
    this.currentTime,
  }) : super(key: key);

  @override
  State<CurrentLectureBanner> createState() => _CurrentLectureBannerState();
}

class _CurrentLectureBannerState extends State<CurrentLectureBanner>
    with SingleTickerProviderStateMixin {
  late DateTime displayTime;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    displayTime = widget.currentTime ?? DateTime.now();

    // Update time every second
    Future.delayed(const Duration(seconds: 1), _updateTime);

    // Glow animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        displayTime = DateTime.now();
      });
      // Schedule next update
      Future.delayed(const Duration(seconds: 1), _updateTime);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final timeString = timeFormat.format(displayTime);

    // If no current lecture, show "No Class" message
    if (widget.currentLecture == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.surfaceLight,
              DesignSystem.surfaceLight.withOpacity(0.95),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: DesignSystem.divider,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(DesignSystem.paddingLarge * 1.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ No Class Now',
                  style: TextStyle(
                    color: DesignSystem.tertiary,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Free period - Enjoy your break!',
                  style: TextStyle(
                    color: DesignSystem.textSecondary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing3 * 1.5,
                vertical: DesignSystem.spacing2 * 1.5,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.cornerRadiusMedium),
                border: Border.all(
                  color: DesignSystem.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                timeString,
                style: TextStyle(
                  color: DesignSystem.primary,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final lecture = widget.currentLecture!;
    final startTimeFormat = DateFormat('HH:mm');
    final startTimeStr = startTimeFormat.format(lecture.startTime);
    final endTimeStr = startTimeFormat.format(lecture.endTime);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignSystem.secondary,
                const Color(0xFF512DA8), // Deep purple accent
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.secondary.withOpacity(_glowAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(DesignSystem.cornerRadiusMedium),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.paddingLarge * 1.5,
            vertical: DesignSystem.paddingLarge * 1.2,
          ),
          child: Row(
            children: [
              // Left: Lecture info
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated "HAPPENING NOW" badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent
                                          .withOpacity(_glowAnimation.value + 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'HAPPENING NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lecture name
                    Text(
                      lecture.subject,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 64, // HUGE for 20ft visibility
                        height: 1.1,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Teacher and Location row
                    Row(
                      children: [
                        _buildInfoChip(Icons.person_rounded, lecture.teacher.name),
                        const SizedBox(width: 24),
                        _buildInfoChip(Icons.location_on_rounded, lecture.classroom),
                      ],
                    ),
                  ],
                ),
              ),

              // Vertical Divider
              Container(
                height: 120,
                width: 2,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),

              // Right: Current time
              Expanded(
                flex: 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CURRENT TIME',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 96, // MASSIVE for visibility
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$startTimeStr - $endTimeStr',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
