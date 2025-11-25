import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';

class TimelineLectureCard extends StatefulWidget {
  final Lecture lecture;
  final bool isActive;
  final bool isNext;
  final bool isPast;
  final bool isFirst;
  final bool isLast;

  const TimelineLectureCard({
    Key? key,
    required this.lecture,
    required this.isActive,
    required this.isNext,
    required this.isPast,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  State<TimelineLectureCard> createState() => _TimelineLectureCardState();
}

class _TimelineLectureCardState extends State<TimelineLectureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color getStatusColor() {
    if (widget.isActive) return const Color(0xFF4ADE80); // Green
    if (widget.isNext) return const Color(0xFF3B82F6); // Blue
    if (widget.isPast) return const Color(0xFFD1D5DB); // Gray
    return const Color(0xFF8B5CF6); // Purple
  }

  String getStatusEmoji() {
    if (widget.isActive) return '🔴';
    if (widget.isNext) return '⭕';
    if (widget.isPast) return '✅';
    return '⏳';
  }

  String getStatusText() {
    if (widget.isActive) return 'Happening Now';
    if (widget.isNext) return 'Next Up';
    if (widget.isPast) return 'Completed';
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(widget.lecture.startTime);
    final endTime = timeFormat.format(widget.lecture.endTime);
    final duration = widget.lecture.endTime.difference(widget.lecture.startTime);
    final durationText =
        '${duration.inHours}h ${duration.inMinutes % 60}m';

    final statusColor = getStatusColor();
    final statusEmoji = getStatusEmoji();
    final statusText = getStatusText();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline left side
        SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time
              Text(
                startTime,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                endTime,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Timeline middle (dots and line)
        SizedBox(
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top connecting line
              if (!widget.isFirst)
                Container(
                  height: 12,
                  width: 1.5,
                  color: statusColor.withOpacity(0.3),
                ),

              // Animated dot
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isActive ? _scaleAnimation.value : 1.0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Bottom connecting line
              if (!widget.isLast)
                Container(
                  height: 12,
                  width: 1.5,
                  color: statusColor.withOpacity(0.3),
                ),
            ],
          ),
        ),

        // Lecture card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: GestureDetector(
              onTap: () {
                // Card tap handler
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: statusColor.withOpacity(0.7),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge and duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            border: Border.all(color: statusColor),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$statusEmoji $statusText',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        Text(
                          durationText,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Subject
                    Text(
                      widget.lecture.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Teacher and Classroom - side by side
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                '👨‍🏫 ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Expanded(
                                child: Text(
                                  widget.lecture.teacher?.name ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                '🏫 ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Expanded(
                                child: Text(
                                  widget.lecture.classroom ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
