import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';
import 'status_badge.dart';

/// Modern next lecture card with animations
class ModernNextLectureCard extends StatefulWidget {
  final Lecture lecture;
  final VoidCallback? onTap;

  const ModernNextLectureCard({
    super.key,
    required this.lecture,
    this.onTap,
  });

  @override
  State<ModernNextLectureCard> createState() => _ModernNextLectureCardState();
}

class _ModernNextLectureCardState extends State<ModernNextLectureCard> {
  late DateTime _nextUpdateTime;

  @override
  void initState() {
    super.initState();
    _updateNextTime();
  }

  void _updateNextTime() {
    final now = DateTime.now();
    final nextSecond =
        now.add(Duration(seconds: 1 - now.millisecond ~/ 1000));
    _nextUpdateTime = nextSecond;
  }

  String _getCountdownText() {
    final now = DateTime.now();
    final timeUntilStart = widget.lecture.startTime.difference(now);

    if (timeUntilStart.inSeconds < 0 &&
        now.isBefore(widget.lecture.endTime)) {
      return 'In Progress';
    } else if (timeUntilStart.inSeconds < 0) {
      return 'Completed';
    } else if (timeUntilStart.inHours > 0) {
      return 'In ${timeUntilStart.inHours}h ${timeUntilStart.inMinutes % 60}m';
    } else if (timeUntilStart.inMinutes > 0) {
      return 'In ${timeUntilStart.inMinutes}m';
    } else {
      return 'Starting now!';
    }
  }

  Color _getStatusColor() {
    final now = DateTime.now();
    final timeUntilStart = widget.lecture.startTime.difference(now);

    if (timeUntilStart.inSeconds < 0 &&
        now.isBefore(widget.lecture.endTime)) {
      return Colors.green;
    } else if (timeUntilStart.inMinutes <= 15) {
      return Colors.orange;
    } else if (timeUntilStart.inSeconds < 0) {
      return Colors.grey;
    }
    return const Color(0xFF3B82F6);
  }

  IconData _getStatusIcon() {
    final now = DateTime.now();
    final timeUntilStart = widget.lecture.startTime.difference(now);

    if (timeUntilStart.inSeconds < 0 &&
        now.isBefore(widget.lecture.endTime)) {
      return Icons.play_circle;
    } else if (timeUntilStart.inMinutes <= 15) {
      return Icons.access_time;
    } else if (timeUntilStart.inSeconds < 0) {
      return Icons.check_circle;
    }
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(widget.lecture.startTime);
    final endTime = timeFormat.format(widget.lecture.endTime);
    final statusColor = _getStatusColor();
    final countdownText = _getCountdownText();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF3B82F6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Next Lecture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    StatusBadge(
                      label: countdownText,
                      backgroundColor: statusColor,
                      textColor: Colors.white,
                      icon: _getStatusIcon(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject title
                    Text(
                      widget.lecture.subject,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Course and semester
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.lecture.course} • ${widget.lecture.semester}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.lecture.classroom,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$startTime - $endTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Divider
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    
                    // Teacher info
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF3B82F6).withOpacity(0.8),
                                const Color(0xFF1E3A8A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.lecture.teacher.name
                                  .split(' ')
                                  .map((n) => n[0])
                                  .take(2)
                                  .join(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lecture.teacher.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.lecture.teacher.department,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
