import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/lecture.dart';
import '../services/api_service.dart';
import '../themes/design_system.dart';
import '../widgets/banner_header.dart';
import '../widgets/banner_lecture_card.dart';
import '../widgets/banner_schedule_list.dart';
import '../widgets/animated_box_frames.dart';
import '../widgets/current_lecture_banner.dart';
import '../widgets/advanced_timetable.dart';
import '../widgets/parallax_timetable.dart';
import '../widgets/carousel_timetable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lecture? nextLecture;
  List<Lecture> todaySchedule = [];
  bool isLoading = true;
  String? error;
  Timer? _refreshTimer;
  String _scheduleViewMode = 'Carousel'; // Default to Carousel as requested

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh data every 5 seconds for dynamic updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (kDebugMode) {
      print('📡 [DigiBoard] Fetching schedule data...');
    }

    try {
      // Fetch both next lecture and today's schedule
      final next = await ApiService.getNextLecture();
      final schedule = await ApiService.getTodaySchedule();

      if (mounted) {
        setState(() {
          nextLecture = next;
          todaySchedule = schedule;
          isLoading = false;
          error = null;
        });

        if (kDebugMode) {
          print('✅ Data loaded: ${schedule.length} lectures today');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
        if (kDebugMode) {
          print('❌ Error loading data: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < DesignSystem.breakpointTablet;
    final isLargeScreen = screenWidth >= DesignSystem.breakpointDesktopLarge;

    return Scaffold(
      backgroundColor: DesignSystem.surfaceLight,
      body: isLoading
          ? _buildLoadingState()
          : error != null
              ? _buildErrorState()
              : _buildContent(isSmallScreen, isLargeScreen),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const _AnimatedShowcaseScreen(),
            ),
          );
        },
        backgroundColor: DesignSystem.secondary,
        icon: const Icon(Icons.animation_rounded),
        label: const Text('✨ Animations'),
      ),
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: DesignSystem.primary,
            strokeWidth: 4,
          ),
          SizedBox(height: DesignSystem.spacing3),
          Text(
            'Loading classroom schedule...',
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: DesignSystem.iconSizeXLarge,
            color: DesignSystem.error,
          ),
          SizedBox(height: DesignSystem.spacing3),
          Text(
            'Unable to load schedule',
            style: DesignSystem.headlineLarge.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing2),
          Text(
            error ?? 'Unknown error',
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSystem.spacing4),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: DesignSystem.bodyLarge,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing4,
                vertical: DesignSystem.spacing3,
              ),
              minimumSize: const Size(DesignSystem.minTouchTarget,
                  DesignSystem.minTouchTarget),
            ),
          ),
        ],
      ),
    );
  }

  /// Main content
  Widget _buildContent(bool isSmallScreen, bool isLargeScreen) {
    final currentLecture = _getCurrentLecture();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Current Lecture Banner (replaces BannerHeader)
          // Shows current time on the right and current lecture info on the left
          CurrentLectureBanner(
            currentLecture: currentLecture,
            currentTime: DateTime.now(),
          ),

          SizedBox(height: DesignSystem.spacing4),

          // Main Content Area (Responsive Layout)
          if (isSmallScreen)
            _buildStackedLayout()
          else
            _buildSideByScrollLayout(),

          SizedBox(height: DesignSystem.spacing4),
        ],
      ),
    );
  }

  /// Stacked layout (mobile)
  Widget _buildStackedLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.paddingLarge),
      child: Column(
        children: [
          // Next Lecture Section
          if (nextLecture != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✏️ 🎯 NEXT LESSON',
                  style: TextStyle(
                    color: DesignSystem.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: DesignSystem.spacing3),
                _buildNextLectureCard(),
                SizedBox(height: DesignSystem.spacing4),
              ],
            ),

          // Today's Schedule Section
          if (todaySchedule.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: DesignSystem.spacing3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '📅 TODAY\'S SCHEDULE',
                            style: TextStyle(
                              color: DesignSystem.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignSystem.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: DesignSystem.primary.withOpacity(0.2)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _scheduleViewMode,
                                icon: Icon(Icons.view_carousel_rounded, color: DesignSystem.primary),
                                style: TextStyle(
                                  color: DesignSystem.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _scheduleViewMode = newValue;
                                    });
                                  }
                                },
                                items: <String>['List', 'Parallax']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${todaySchedule.length} classes',
                        style: TextStyle(
                          color: DesignSystem.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildScheduleList(),
              ],
            )
          else
            Container(
              padding: EdgeInsets.all(DesignSystem.paddingLarge),
              decoration: BoxDecoration(
                color: DesignSystem.tertiary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                border: Border.all(
                  color: DesignSystem.tertiary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    size: DesignSystem.iconSizeXLarge,
                    color: DesignSystem.tertiary,
                  ),
                  SizedBox(height: DesignSystem.spacing2),
                  Text(
                    'No classes today!',
                    style: DesignSystem.headlineSmall.copyWith(
                      color: DesignSystem.tertiary,
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacing1),
                  Text(
                    'Enjoy your free day 🎉',
                    style: DesignSystem.bodyMedium.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Side-by-side layout (desktop)
  Widget _buildSideByScrollLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Next Lecture (40%)
          if (nextLecture != null)
            Expanded(
              flex: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✏️ 🎯 NEXT LESSON',
                    style: TextStyle(
                      color: DesignSystem.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacing3),
                  _buildNextLectureCard(),
                ],
              ),
            ),

          // Spacing between columns
          if (nextLecture != null && todaySchedule.isNotEmpty)
            SizedBox(width: DesignSystem.spacing4),

          // Right: Today's Schedule (60%)
          if (todaySchedule.isNotEmpty)
            Expanded(
              flex: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: DesignSystem.spacing3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '📅 TODAY\'S SCHEDULE',
                              style: TextStyle(
                                color: DesignSystem.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: DesignSystem.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: DesignSystem.primary.withOpacity(0.2)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _scheduleViewMode,
                                  icon: Icon(Icons.view_carousel_rounded, color: DesignSystem.primary),
                                  style: TextStyle(
                                    color: DesignSystem.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _scheduleViewMode = newValue;
                                      });
                                    }
                                  },
                                  items: <String>['List', 'Parallax', 'Carousel']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${todaySchedule.length} classes',
                          style: TextStyle(
                            color: DesignSystem.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildScheduleList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Next Lecture Card
  Widget _buildNextLectureCard() {
    if (nextLecture == null) {
      return const SizedBox.shrink();
    }

    // Determine status
    final now = DateTime.now();
    final status = now.isBefore(nextLecture!.startTime) ? 'upcoming' : 'in-progress';

    return BannerLectureCard(
      subjectName: nextLecture!.subject,
      teacherName: nextLecture!.teacher.name,
      teacherDepartment: nextLecture!.teacher.department,
      location: nextLecture!.classroom,
      startTime: nextLecture!.startTime,
      endTime: nextLecture!.endTime,
      status: status,
    );
  }

  /// Schedule List
  Widget _buildScheduleList() {
    if (_scheduleViewMode == 'Parallax') {
      return ParallaxTimetable(lectures: todaySchedule);
    } else if (_scheduleViewMode == 'Carousel') {
      return CarouselTimetable(lectures: todaySchedule);
    }
    return AdvancedTimetable(lectures: todaySchedule);
  }

  /// Determine lecture status
  String _getLectureStatus(Lecture lecture) {
    final now = DateTime.now();

    if (now.isBefore(lecture.startTime)) {
      return 'upcoming';
    } else if (now.isAfter(lecture.startTime) && now.isBefore(lecture.endTime)) {
      return 'in-progress';
    } else {
      return 'completed';
    }
  }

  /// Get the current lecture happening right now
  Lecture? _getCurrentLecture() {
    final now = DateTime.now();
    try {
      return todaySchedule.firstWhere(
        (lecture) =>
            now.isAfter(lecture.startTime) && now.isBefore(lecture.endTime),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Animated Showcase Screen - Demonstrates all animated components
class _AnimatedShowcaseScreen extends StatelessWidget {
  const _AnimatedShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.surfaceLight,
      appBar: AppBar(
        title: Text(
          '✨ Animated Components',
          style: DesignSystem.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: DesignSystem.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Box Frames
              _buildSectionTitle('🎨 Animated Box Frames'),
              SizedBox(height: DesignSystem.spacing2),
              AnimatedBoxFrame(
                title: 'Featured Lecture',
                subtitle: 'Color-rotating frame',
                child: Text(
                  'Watch the border color smoothly transition between Indigo → Pink → Teal → Green → Orange',
                  style: DesignSystem.bodyLarge,
                ),
              ),
              SizedBox(height: DesignSystem.spacing4),

              // Animated Color Grid
              _buildSectionTitle('🎯 Interactive Grid'),
              SizedBox(height: DesignSystem.spacing2),
              AnimatedColorGrid(
                items: [
                  AnimatedGridItem(
                    title: 'Classes',
                    subtitle: '12 total',
                    icon: Icons.class_rounded,
                    color: DesignSystem.primary,
                  ),
                  AnimatedGridItem(
                    title: 'Teachers',
                    subtitle: '8 faculty',
                    icon: Icons.people_rounded,
                    color: DesignSystem.secondary,
                  ),
                  AnimatedGridItem(
                    title: 'Rooms',
                    subtitle: '15 rooms',
                    icon: Icons.location_on_rounded,
                    color: DesignSystem.tertiary,
                  ),
                  AnimatedGridItem(
                    title: 'Calendar',
                    subtitle: 'Full view',
                    icon: Icons.calendar_month_rounded,
                    color: DesignSystem.success,
                  ),
                ],
                crossAxisCount: 2,
              ),
              SizedBox(height: DesignSystem.spacing4),

              // Card Stack Animation
              _buildSectionTitle('🃏 Sliding Card Stack'),
              SizedBox(height: DesignSystem.spacing2),
              AnimatedCardStack(
                cards: [
                  StackedCard(
                    title: 'Material Design 3',
                    description: 'Built with Google\'s latest design system',
                    icon: Icons.auto_awesome_rounded,
                    color: DesignSystem.primary,
                  ),
                  StackedCard(
                    title: 'Smooth Animations',
                    description: '400ms transitions with perfect easing',
                    icon: Icons.animation_rounded,
                    color: DesignSystem.secondary,
                  ),
                  StackedCard(
                    title: 'WCAG AAA',
                    description: 'Fully accessible & inclusive design',
                    icon: Icons.accessibility_rounded,
                    color: DesignSystem.tertiary,
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.spacing4),

              // Feature Cards
              _buildSectionTitle('⭐ Feature Cards'),
              SizedBox(height: DesignSystem.spacing2),
              AnimatedFeatureCard(
                title: 'Real-time Sync',
                description: 'Live data from backend with auto-refresh',
                icon: Icons.sync_rounded,
                color: DesignSystem.primary,
              ),
              SizedBox(height: DesignSystem.spacing3),
              AnimatedFeatureCard(
                title: 'Responsive UI',
                description: 'Perfect on all screens from 360px to 4K',
                icon: Icons.devices_rounded,
                color: DesignSystem.secondary,
              ),
              SizedBox(height: DesignSystem.spacing4),

              // Animation Details
              Container(
                padding: EdgeInsets.all(DesignSystem.paddingLarge),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                  border: Border.all(
                    color: DesignSystem.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Animation Features',
                      style: DesignSystem.headlineSmall.copyWith(
                        color: DesignSystem.primary,
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing2),
                    _buildFeatureBullet('Color Transitions: Smooth interpolation'),
                    _buildFeatureBullet('Bounce Effects: Physics-based motion'),
                    _buildFeatureBullet('Card Animations: Slide and stack'),
                    _buildFeatureBullet('Auto-rotate: Seamless cycling'),
                    _buildFeatureBullet('Hover Effects: Interactive feedback'),
                    _buildFeatureBullet('Timing: 200-400ms Material Design'),
                  ],
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignSystem.headlineLarge.copyWith(
        color: DesignSystem.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignSystem.spacing1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DesignSystem.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: DesignSystem.spacing2),
          Expanded(
            child: Text(
              text,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
