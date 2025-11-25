import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/design_system.dart';
import 'animated_grid_lecture_card.dart';

/// ScheduleListItem Widget
/// Represents a single lecture in the day's schedule
class ScheduleListItem extends StatelessWidget {
  final String subjectName;
  final String teacherName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const ScheduleListItem({
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

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTimeStr = timeFormat.format(startTime);
    final endTimeStr = timeFormat.format(endTime);

    // Get status emoji
    final statusEmoji = _getStatusEmoji(status);
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(DesignSystem.spacing2),
        decoration: BoxDecoration(
          color: isHighlighted
              ? DesignSystem.primary.withOpacity(0.1)
              : DesignSystem.surfaceLight,
          border: Border.all(
            color: isHighlighted ? DesignSystem.primary : DesignSystem.divider,
            width: isHighlighted ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.cornerRadiusSmall),
          boxShadow: isHighlighted ? DesignSystem.shadowElevation1 : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with subject and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject name (smaller for grid)
                      Text(
                        subjectName,
                        style: DesignSystem.bodyLarge.copyWith(
                          color: DesignSystem.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignSystem.spacing1),
                      // Status (smaller)
                      Text(
                        '$statusEmoji ${status.toUpperCase()}',
                        style: DesignSystem.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: DesignSystem.spacing1),

            // Time and location (smaller)
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: DesignSystem.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$startTimeStr - $endTimeStr',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2),

            // Location (smaller)
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: DesignSystem.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2),

            // Teacher (smaller)
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: DesignSystem.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    teacherName,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                      fontSize: 10,
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

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'happening_now':
        return '🚀';
      case 'completed':
      case 'finished':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '⏰';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'happening_now':
        return DesignSystem.secondary;
      case 'completed':
      case 'finished':
        return DesignSystem.tertiary;
      case 'cancelled':
        return DesignSystem.error;
      default:
        return DesignSystem.tertiary;
    }
  }
}

/// BannerScheduleList Widget
/// Displays today's schedule with smooth animations and auto-scroll
class BannerScheduleList extends StatefulWidget {
  final List<ScheduleItem> scheduleItems;
  final String? nextLectureId;
  final bool enableAutoScroll;
  final Duration autoScrollDuration;

  const BannerScheduleList({
    Key? key,
    required this.scheduleItems,
    this.nextLectureId,
    this.enableAutoScroll = true,
    this.autoScrollDuration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<BannerScheduleList> createState() => _BannerScheduleListState();
}

class _BannerScheduleListState extends State<BannerScheduleList> {
  late ScrollController _scrollController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController(initialPage: 0);

    // Start auto-scroll if enabled
    if (widget.enableAutoScroll && widget.scheduleItems.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(widget.autoScrollDuration, () {
      if (mounted && widget.enableAutoScroll) {
        try {
          _currentPage = (_currentPage + 1) % widget.scheduleItems.length;
          _pageController.animateToPage(
            _currentPage,
            duration: DesignSystem.animationSlow,
            curve: DesignSystem.curveEntrance,
          );
          _startAutoScroll();
        } catch (e) {
          // Handle animation errors gracefully
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scheduleItems.isEmpty) {
      return Container(
        padding: EdgeInsets.all(DesignSystem.paddingLarge),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: DesignSystem.iconSizeXLarge,
                color: DesignSystem.primary.withOpacity(0.5),
              ),
              SizedBox(height: DesignSystem.spacing3),
              Text(
                'No classes today',
                style: DesignSystem.headlineSmall.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              SizedBox(height: DesignSystem.spacing2),
              Text(
                'Enjoy your free day! 🎉',
                style: DesignSystem.bodyLarge.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Dynamic 2x2 GridView with content wrapping and responsive sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic child aspect ratio based on content
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // Default aspect ratio, adjust based on screen size
        double childAspectRatio = 1.1;
        int crossAxisCount = 2;
        
        // Tablet/larger screens
        if (screenWidth > 1200) {
          crossAxisCount = 3;
          childAspectRatio = 1.15;
        } else if (screenWidth > 768) {
          crossAxisCount = 2;
          childAspectRatio = 1.2;
        }

        return Padding(
          padding: EdgeInsets.all(DesignSystem.spacing2),
          child: GridView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: DesignSystem.spacing2,
              mainAxisSpacing: DesignSystem.spacing2,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: widget.scheduleItems.length,
            itemBuilder: (context, index) {
              final item = widget.scheduleItems[index];
              return AnimatedGridLectureCard(
                subjectName: item.subjectName,
                teacherName: item.teacherName,
                location: item.location,
                startTime: item.startTime,
                endTime: item.endTime,
                status: item.status,
                isHighlighted: item.id == widget.nextLectureId,
              );
            },
          ),
        );
      },
    );
  }
}

/// ScheduleItem Data Model
class ScheduleItem {
  final String id;
  final String subjectName;
  final String teacherName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  ScheduleItem({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.status = 'upcoming',
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['_id'] ?? json['id'] ?? '',
      subjectName: json['subject'] ?? json['subjectName'] ?? 'Unknown Subject',
      teacherName: json['teacherName'] ?? json['teacher'] ?? 'Unknown Teacher',
      location: json['location'] ?? json['room'] ?? 'Unknown Location',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toString()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toString()),
      status: json['status'] ?? 'upcoming',
    );
  }
}
