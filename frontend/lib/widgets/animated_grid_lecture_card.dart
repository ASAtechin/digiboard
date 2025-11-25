import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/design_system.dart';

/// GridLectureCard Widget
/// Simple, clean grid cell with transparent background and colored border
class AnimatedGridLectureCard extends StatelessWidget {
  final String subjectName;
  final String teacherName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const AnimatedGridLectureCard({
    Key? key,
    required this.subjectName,
    required this.teacherName,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.status = 'upcoming',
    this.isHighlighted = false,
    this.onTap,
  }) : super(key: key);


  (Color, String, String) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'happening_now':
        return (DesignSystem.secondary, '🚀', 'NOW');
      case 'completed':
      case 'finished':
        return (DesignSystem.tertiary, '✅', 'DONE');
      case 'cancelled':
        return (DesignSystem.error, '❌', 'CANCELLED');
      default:
        return (DesignSystem.tertiary, '⏰', 'UPCOMING');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTimeStr = timeFormat.format(startTime);
    final endTimeStr = timeFormat.format(endTime);

    final (statusColor, statusEmoji, statusLabel) = _getStatusInfo(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: statusColor.withOpacity(0.6),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Badge - Premium style
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor, width: 1.5),
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.12),
                    statusColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                '$statusEmoji $statusLabel',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 8),

            // Subject Name - Bold and prominent
            Text(
              subjectName,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),

            // Divider
            Container(
              height: 1,
              color: statusColor.withOpacity(0.2),
              margin: EdgeInsets.symmetric(vertical: 4),
            ),

            SizedBox(height: 4),

            // Time with icon - Enhanced
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.schedule, color: statusColor, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$startTimeStr - $endTimeStr',
                    style: TextStyle(
                      color: statusColor.withOpacity(0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Location with icon - Enhanced
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.location_on, color: statusColor, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color: statusColor.withOpacity(0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // Teacher with icon - Enhanced
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.person, color: statusColor, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    teacherName,
                    style: TextStyle(
                      color: statusColor.withOpacity(0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
