import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/design_system.dart';

/// BannerLectureCard Widget
/// Displays lecture information optimized for banner display
/// Features:
/// - Subject name: 72px (visible from 10+ meters)
/// - Status badge with emoji and color coding
/// - Room location and teacher information
/// - Time remaining calculation
/// - Touch targets: 48px+ for accessibility
class BannerLectureCard extends StatelessWidget {
  final String subjectName;
  final String teacherName;
  final String? teacherDepartment;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'upcoming', 'in-progress', 'completed'
  final VoidCallback? onTap;

  const BannerLectureCard({
    Key? key,
    required this.subjectName,
    required this.teacherName,
    this.teacherDepartment,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.status = 'upcoming',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < DesignSystem.breakpointTablet;

    // Get status color and emoji
    final (statusColor, statusEmoji, statusLabel) = _getStatusInfo(status);

    // Format times
    final timeFormat = DateFormat('HH:mm');
    final startTimeStr = timeFormat.format(startTime);
    final endTimeStr = timeFormat.format(endTime);

    // Calculate time remaining
    final now = DateTime.now();
    final duration = startTime.difference(now);
    final minutesRemaining = duration.inMinutes;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(DesignSystem.spacing3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor,
              statusColor.withOpacity(0.8),
            ],
          ),
          borderRadius:
              BorderRadius.circular(DesignSystem.cornerRadiusLarge),
          boxShadow: DesignSystem.shadowElevation2,
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge (top-left)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing2,
                    vertical: DesignSystem.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      DesignSystem.cornerRadiusSmall,
                    ),
                  ),
                  child: Text(
                    '$statusEmoji $statusLabel',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textInverse,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: DesignSystem.spacing3),

                // Subject Name (LARGE - 72px for banner)
                Text(
                  subjectName,
                  style: DesignSystem.displayMedium.copyWith(
                    color: DesignSystem.textInverse,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: DesignSystem.spacing3),

                // Divider
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.3),
                ),

                SizedBox(height: DesignSystem.spacing3),

                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: DesignSystem.textInverse,
                      size: DesignSystem.iconSizeLarge,
                    ),
                    SizedBox(width: DesignSystem.spacing2),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: DesignSystem.textInverse,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: DesignSystem.spacing2),

                // Time Row
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: DesignSystem.textInverse,
                      size: DesignSystem.iconSizeLarge,
                    ),
                    SizedBox(width: DesignSystem.spacing2),
                    Expanded(
                      child: Text(
                        '$startTimeStr - $endTimeStr',
                        style: TextStyle(
                          color: DesignSystem.textInverse,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: DesignSystem.spacing3),

                // Time Remaining (if upcoming)
                if (status == 'upcoming' && minutesRemaining > 0)
                  Container(
                    padding: EdgeInsets.all(DesignSystem.spacing2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        DesignSystem.cornerRadiusSmall,
                      ),
                    ),
                    child: Text(
                      '⏱️ $minutesRemaining minutes remaining',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.textInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(height: DesignSystem.spacing3),

                // Teacher Info
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: DesignSystem.textInverse,
                      size: DesignSystem.iconSizeLarge,
                    ),
                    SizedBox(width: DesignSystem.spacing2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName,
                            style: TextStyle(
                              color: DesignSystem.textInverse,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (teacherDepartment != null)
                            Text(
                              teacherDepartment!,
                              style: TextStyle(
                                color:
                                    DesignSystem.textInverse.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  /// Get status color, emoji, and label
  (Color, String, String) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'happening_now':
        return (DesignSystem.secondary, '🚀', 'HAPPENING NOW');
      case 'completed':
      case 'finished':
        return (DesignSystem.tertiary, '✅', 'COMPLETED');
      case 'cancelled':
        return (DesignSystem.error, '❌', 'CANCELLED');
      default:
        return (DesignSystem.tertiary, '⏰', 'COMING UP');
    }
  }
}
