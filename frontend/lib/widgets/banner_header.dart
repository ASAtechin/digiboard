import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/design_system.dart';

/// BannerHeader Widget
/// Displays current date/time optimized for far-view banner display
/// - Time: 96px (visible from 12+ meters)
/// - Date: 28px (visible from 5+ meters)
/// - Purpose: Serves as visual anchor and time reference in classroom
class BannerHeader extends StatefulWidget {
  final DateTime? currentTime;
  final Color? backgroundColor;
  final Color? textColor;

  const BannerHeader({
    Key? key,
    this.currentTime,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<BannerHeader> createState() => _BannerHeaderState();
}

class _BannerHeaderState extends State<BannerHeader> {
  late DateTime displayTime;

  @override
  void initState() {
    super.initState();
    displayTime = widget.currentTime ?? DateTime.now();

    // Update time every second
    Future.delayed(const Duration(seconds: 1), _updateTime);
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < DesignSystem.breakpointTablet;

    final bgColor = widget.backgroundColor ?? DesignSystem.primary;
    final textColor = widget.textColor ?? DesignSystem.textInverse;

    // Format time and date
    final timeFormat = DateFormat('HH:mm');
    final timeString = timeFormat.format(displayTime);

    final dateFormat = DateFormat('EEEE, MMMM d');
    final dateString = dateFormat.format(displayTime);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        boxShadow: DesignSystem.shadowElevation2,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: DesignSystem.paddingLarge,
          horizontal: DesignSystem.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date display (top)
            Text(
              dateString,
              style: DesignSystem.bodyLarge.copyWith(
                color: textColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: DesignSystem.spacing3),

            // Decorative line
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    textColor.withOpacity(0.3),
                    textColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            SizedBox(height: DesignSystem.spacing3),

            // Time display (HUGE - 96px for far-view)
            Center(
              child: Text(
                timeString,
                style: DesignSystem.displayLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  // Add letter spacing for elegance
                  letterSpacing: 2,
                ),
              ),
            ),

            SizedBox(height: DesignSystem.spacing3),

            // Decorative line
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    textColor.withOpacity(0.1),
                    textColor.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
