import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';

/// Grid-Based Lecture Card with Animations
/// Optimized for grid layout with compact size and strong animations
class GridLectureCard extends StatefulWidget {
  final Lecture lecture;
  final bool isNext;
  final bool isPast;
  final VoidCallback? onTap;

  const GridLectureCard({
    super.key,
    required this.lecture,
    this.isNext = false,
    this.isPast = false,
    this.onTap,
  });

  @override
  State<GridLectureCard> createState() => _GridLectureCardState();
}

class _GridLectureCardState extends State<GridLectureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Auto-play animation
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    if (widget.isNext) return const Color(0xFF3B82F6); // Blue - Next
    if (widget.isPast) return const Color(0xFF9CA3AF); // Gray - Completed
    return const Color(0xFF8B5CF6); // Purple - Upcoming
  }

  Color _getBackgroundColor() {
    if (widget.isNext) return const Color(0xFF3B82F6).withOpacity(0.12);
    if (widget.isPast) return const Color(0xFF9CA3AF).withOpacity(0.08);
    return const Color(0xFF8B5CF6).withOpacity(0.12);
  }

  String _getStatusEmoji() {
    if (widget.isNext) return '⭕';
    if (widget.isPast) return '✅';
    return '⏳';
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(widget.lecture.startTime);
    final duration = widget.lecture.endTime.difference(widget.lecture.startTime);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(),
                    width: _isHovered ? 3.0 : 2.5,
                  ),
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getBorderColor().withOpacity(
                        _isHovered ? 0.4 : 0.25,
                      ),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 6 : 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getStatusEmoji(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getBorderColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getBorderColor(),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              startTime,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getBorderColor(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Subject Title
                      Text(
                        widget.lecture.subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _getBorderColor(),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Location & Duration
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: _getBorderColor().withOpacity(0.6),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  widget.lecture.classroom,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getBorderColor().withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: _getBorderColor().withOpacity(0.6),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${duration.inMinutes}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getBorderColor().withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
