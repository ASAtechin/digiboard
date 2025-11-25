import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';

/// Animated Lecture Card Widget
/// 
/// Displays individual lecture with animated border that responds to state changes.
/// Uses AnimatedContainer for smooth border animations.
/// 
/// Features:
/// - Animated border color transitions
/// - Hover/tap effects with smooth animation
/// - Status-based color indicators
/// - Professional gradient backgrounds
/// - Responsive design
/// 
/// Reference: https://docs.flutter.dev/cookbook/animation/animated-container

class AnimatedLectureCard extends StatefulWidget {
  final Lecture lecture;
  final bool isActive; // Currently happening
  final bool isNext; // Next lecture to happen
  final VoidCallback? onTap;
  final bool isPast; // Already completed

  const AnimatedLectureCard({
    super.key,
    required this.lecture,
    this.isActive = false,
    this.isNext = false,
    this.onTap,
    this.isPast = false,
  });

  @override
  State<AnimatedLectureCard> createState() => _AnimatedLectureCardState();
}

class _AnimatedLectureCardState extends State<AnimatedLectureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for pulsing effect when active
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animation if card is active
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedLectureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle animation state changes
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    if (widget.isActive) return const Color(0xFF4ADE80); // Green - Happening now
    if (widget.isNext) return const Color(0xFF3B82F6); // Blue - Next
    if (widget.isPast) return const Color(0xFF6B7280); // Dark Gray - Completed (improved contrast)
    return const Color(0xFF8B5CF6); // Purple - Upcoming
  }

  Color _getBackgroundColor() {
    if (widget.isActive)
      return const Color(0xFF4ADE80).withOpacity(0.15); // Green - Increased from 0.1
    if (widget.isNext) return const Color(0xFF3B82F6).withOpacity(0.15); // Blue - Increased from 0.1
    if (widget.isPast)
      return const Color(0xFF6B7280).withOpacity(0.12); // Gray - Increased from 0.05
    return const Color(0xFF8B5CF6).withOpacity(0.12); // Purple - Increased from 0.08
  }

  String _getStatusEmoji() {
    if (widget.isActive) return '🔴'; // Red dot - Live
    if (widget.isNext) return '⭕'; // Circle - Next
    if (widget.isPast) return '✅'; // Checkmark - Done
    return '⏳'; // Hourglass - Upcoming
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(widget.lecture.startTime);
    final endTime = timeFormat.format(widget.lecture.endTime);
    final duration =
        widget.lecture.endTime.difference(widget.lecture.startTime);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Create pulsing effect for active cards
            final pulseValue = widget.isActive ? _animationController.value : 0.0;
            final borderWidthPulse = 2.0 + (pulseValue * 1.0); // Pulses from 2 to 3

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Animated border - INCREASED WIDTH FOR VISIBILITY
                border: Border.all(
                  color: _getBorderColor(),
                  width: widget.isActive
                      ? borderWidthPulse
                      : (_isHovered ? 3.0 : 2.5), // Increased from 2.5/2.0 to 3.0/2.5
                ),
                // Animated background color
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                // Animated shadow - INCREASED VISIBILITY
                boxShadow: [
                  BoxShadow(
                    color: _getBorderColor().withOpacity(
                      _isHovered ? 0.5 : (widget.isActive ? 0.4 : 0.3), // Increased opacity
                    ),
                    blurRadius: _isHovered ? 12 : (widget.isActive ? 8 : 6), // Increased blur
                    offset: Offset(0, _isHovered ? 6 : (widget.isActive ? 4 : 2)),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Status + Subject + Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Indicator
                      Row(
                        children: [
                          Text(
                            _getStatusEmoji(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.lecture.subject,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _getBorderColor(),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Time Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getBorderColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getBorderColor(),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$startTime - $endTime',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getBorderColor(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getBorderColor().withOpacity(0.3),
                          _getBorderColor().withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location & Duration Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: _getBorderColor().withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.lecture.classroom,
                          style: TextStyle(
                            fontSize: 13,
                            color: _getBorderColor().withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: _getBorderColor().withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${duration.inMinutes}m',
                        style: TextStyle(
                          fontSize: 13,
                          color: _getBorderColor().withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Teacher Information
                  if (widget.lecture.teacher.name.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getBorderColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '👨‍🏫',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.lecture.teacher.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getBorderColor().withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status Badge (Active Only)
                  if (widget.isActive) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4ADE80).withOpacity(0.8),
                            const Color(0xFF22C55E).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉 HAPPENING NOW! 🎉',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
