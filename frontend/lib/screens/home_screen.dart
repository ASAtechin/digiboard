import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lecture.dart';
import '../services/api_service.dart';
import '../widgets/lecture_card.dart';
import '../widgets/teacher_info_card.dart';
import '../providers/font_provider.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final futures = await Future.wait([
        ApiService.getNextLecture(),
        ApiService.getTodaySchedule(),
      ]);

      setState(() {
        nextLecture = futures[0] as Lecture?;
        todaySchedule = futures[1] as List<Lecture>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F8FF), // Light Blue background
          appBar: AppBar(
            title: const Text(
              'DigiBoard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            backgroundColor: const Color(0xFF1E3A8A), // Blue
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
            ],
          ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Compact Header
              _buildCompactHeader(),
              const SizedBox(height: 16),
              
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading lecture information...'),
                      ],
                    ),
                  ),
                )
              else if (error != null)
                Expanded(child: _buildErrorWidget())
              else
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine layout based on screen size and data availability
                      bool hasNextLecture = nextLecture != null;
                      bool hasSchedule = todaySchedule.isNotEmpty;
                      
                      if (constraints.maxWidth < 800) {
                        // Mobile/tablet layout - stack vertically
                        return Column(
                          children: [
                            if (hasNextLecture)
                              Expanded(
                                flex: hasSchedule ? 2 : 3,
                                child: _buildNextLectureCompact(),
                              ),
                            if (hasNextLecture && hasSchedule)
                              const SizedBox(height: 16),
                            if (hasSchedule)
                              Expanded(
                                flex: hasNextLecture ? 3 : 4,
                                child: _buildTodayScheduleCompact(fontProvider),
                              ),
                            if (!hasNextLecture && !hasSchedule)
                              Expanded(child: _buildEmptyStateCard()),
                          ],
                        );
                      } else {
                        // Desktop layout - side by side
                        return Row(
                          children: [
                            if (hasNextLecture)
                              Expanded(
                                flex: hasSchedule ? 2 : 3,
                                child: _buildNextLectureCompact(),
                              ),
                            if (hasNextLecture && hasSchedule)
                              const SizedBox(width: 16),
                            if (hasSchedule)
                              Expanded(
                                flex: hasNextLecture ? 3 : 4,
                                child: _buildTodayScheduleCompact(fontProvider),
                              ),
                            if (!hasNextLecture && !hasSchedule)
                              Expanded(child: _buildEmptyStateCard()),
                          ],
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      );
      },
    );
  }

  Widget _buildCompactHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A), // Deep Blue
            const Color(0xFF3B82F6), // Blue
            const Color(0xFF60A5FA), // Light Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(now),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                timeFormat.format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.access_time,
            color: Colors.white70,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildNextLectureCompact() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A), // Blue
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Next Lecture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: nextLecture != null
                  ? _buildCompactLectureInfo()
                  : _buildNoLectureInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLectureInfo() {
    if (nextLecture == null) return const SizedBox();
    
    final now = DateTime.now();
    final startTime = DateFormat('HH:mm').format(nextLecture!.startTime);
    final endTime = DateFormat('HH:mm').format(nextLecture!.endTime);
    final duration = nextLecture!.endTime.difference(nextLecture!.startTime);
    final timeUntilStart = nextLecture!.startTime.difference(now);
    
    // Dynamic status based on timing
    String status = '';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.schedule;
    
    if (timeUntilStart.inMinutes <= 0 && now.isBefore(nextLecture!.endTime)) {
      status = 'In Progress';
      statusColor = Colors.green;
      statusIcon = Icons.play_circle;
    } else if (timeUntilStart.inMinutes <= 15) {
      status = 'Starting Soon';
      statusColor = const Color(0xFFF59E0B); // Orange
      statusIcon = Icons.access_time;
    } else {
      status = 'Upcoming';
      statusColor = const Color(0xFF3B82F6); // Blue
      statusIcon = Icons.upcoming;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Course and semester info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.2)),
          ),
          child: Text(
            '${nextLecture!.course} • ${nextLecture!.semester}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Subject with dynamic sizing
        Flexible(
          child: Text(
            nextLecture!.subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A), // Blue
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        
        // Location and timing info
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                nextLecture!.classroom,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '$startTime - $endTime',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6), // Blue
              ),
            ),
            const Spacer(),
            Text(
              '${duration.inMinutes} min',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        
        // Teacher info with avatar
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF3B82F6), // Blue
              child: Text(
                nextLecture!.teacher.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextLecture!.teacher.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3A8A), // Blue
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    nextLecture!.teacher.department,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Chapter/Description if available
        if (nextLecture!.chapter != null || nextLecture!.description != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nextLecture!.chapter != null) ...[
                  Text(
                    'Chapter',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextLecture!.chapter!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A8A), // Blue
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (nextLecture!.description != null && nextLecture!.chapter == null) ...[
                  Text(
                    nextLecture!.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A8A), // Blue
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
        
        // Time until start (if applicable)
        if (timeUntilStart.inMinutes > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Starts in ${timeUntilStart.inHours > 0 ? "${timeUntilStart.inHours}h " : ""}${timeUntilStart.inMinutes % 60}m',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildNoLectureInfo() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.schedule,
          size: 48,
          color: Colors.grey,
        ),
        SizedBox(height: 12),
        Text(
          'No upcoming lectures',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          'Enjoy your break!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodayScheduleCompact(FontProvider fontProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A), // Blue
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Schedule',
                      style: TextStyle(
                        fontSize: fontProvider.headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (todaySchedule.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_getUniqueClasses(todaySchedule).join(" • ")}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: fontProvider.largeIconSize,
                ),
              ],
            ),
          ),
          Expanded(
            child: todaySchedule.isEmpty
                ? _buildNoScheduleInfo()
                : _buildScheduleList(fontProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildNoScheduleInfo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No lectures scheduled for today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(FontProvider fontProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaySchedule.length,
      itemBuilder: (context, index) {
        final lecture = todaySchedule[index];
        final now = DateTime.now();
        final startTime = DateFormat('HH:mm').format(lecture.startTime);
        final endTime = DateFormat('HH:mm').format(lecture.endTime);
        final isNext = nextLecture != null && lecture.id == nextLecture!.id;
        final isOngoing = now.isAfter(lecture.startTime) && now.isBefore(lecture.endTime);
        final isPast = now.isAfter(lecture.endTime);
        final duration = lecture.endTime.difference(lecture.startTime);
        
        // Dynamic styling based on lecture status
        Color backgroundColor;
        Color borderColor;
        Color textColor;
        Color cardColor;
        IconData? statusIcon;
        
        // Enhanced color palette based on categories
        Color getSubjectColor(String subject) {
          final subjectLower = subject.toLowerCase();
          
          // Check for lecture types first with enhanced color palette
          if (subjectLower.contains('lab') || subjectLower.contains('laboratory') || subjectLower.contains('practical')) {
            return const Color(0xFF059669); // Emerald Green for Labs
          } else if (subjectLower.contains('lecture') || subjectLower.contains('theory')) {
            return const Color(0xFF2563EB); // Royal Blue for Lectures
          } else if (subjectLower.contains('tutorial') || subjectLower.contains('seminar')) {
            return const Color(0xFF7C3AED); // Purple for Tutorials
          } else if (subjectLower.contains('workshop') || subjectLower.contains('project')) {
            return const Color(0xFFEA580C); // Orange for Workshops
          } else if (subjectLower.contains('exam') || subjectLower.contains('test') || subjectLower.contains('quiz')) {
            return const Color(0xFFDC2626); // Red for Exams
          } else if (subjectLower.contains('sport') || subjectLower.contains('gym') || subjectLower.contains('physical') || subjectLower.contains('pe')) {
            return const Color(0xFF0891B2); // Sky Blue for Sports
          } else if (subjectLower.contains('break') || subjectLower.contains('lunch') || subjectLower.contains('recess')) {
            return const Color(0xFF65A30D); // Lime Green for Breaks
          }
          
          // Then check for subject categories with refined colors
          if (subjectLower.contains('math') || subjectLower.contains('calculus') || subjectLower.contains('algebra')) {
            return const Color(0xFF6366F1); // Indigo for Math
          } else if (subjectLower.contains('computer') || subjectLower.contains('programming') || subjectLower.contains('software') || subjectLower.contains('data')) {
            return const Color(0xFF0284C7); // Blue for Computer Science
          } else if (subjectLower.contains('physics') || subjectLower.contains('chemistry') || subjectLower.contains('biology')) {
            return const Color(0xFF16A34A); // Green for Sciences
          } else if (subjectLower.contains('history') || subjectLower.contains('literature') || subjectLower.contains('english') || subjectLower.contains('language')) {
            return const Color(0xFFD97706); // Amber for Humanities
          } else if (subjectLower.contains('art') || subjectLower.contains('design') || subjectLower.contains('music')) {
            return const Color(0xFFE11D48); // Rose for Arts
          } else if (subjectLower.contains('business') || subjectLower.contains('economics') || subjectLower.contains('management')) {
            return const Color(0xFF7C2D12); // Brown for Business
          } else {
            return const Color(0xFF64748B); // Slate for others
          }
        }
        
        // Get course-based color classification
        Color getCourseColor(String course) {
          final courseLower = course.toLowerCase();
          
          if (courseLower.contains('computer science') || courseLower.contains('cs')) {
            return const Color(0xFF0284C7); // Blue for Computer Science
          } else if (courseLower.contains('mathematics') || courseLower.contains('math')) {
            return const Color(0xFF6366F1); // Indigo for Mathematics
          } else if (courseLower.contains('physics')) {
            return const Color(0xFF16A34A); // Green for Physics
          } else if (courseLower.contains('engineering')) {
            return const Color(0xFFEA580C); // Orange for Engineering
          } else if (courseLower.contains('business') || courseLower.contains('mba')) {
            return const Color(0xFF7C2D12); // Brown for Business
          } else if (courseLower.contains('medicine') || courseLower.contains('medical')) {
            return const Color(0xFFDC2626); // Red for Medicine
          } else if (courseLower.contains('arts') || courseLower.contains('design')) {
            return const Color(0xFFE11D48); // Rose for Arts
          } else if (courseLower.contains('literature') || courseLower.contains('english')) {
            return const Color(0xFFD97706); // Amber for Literature
          } else {
            return const Color(0xFF64748B); // Slate for others
          }
        }
        
        // Get lighter shade for backgrounds
        Color getLighterShade(Color color) {
          return Color.fromRGBO(
            (color.red + (255 - color.red) * 0.8).round(),
            (color.green + (255 - color.green) * 0.8).round(),
            (color.blue + (255 - color.blue) * 0.8).round(),
            1.0,
          );
        }
        
        // Get darker shade for gradients
        Color getDarkerShade(Color color) {
          return Color.fromRGBO(
            (color.red * 0.7).round(),
            (color.green * 0.7).round(),
            (color.blue * 0.7).round(),
            1.0,
          );
        }
        
        // Get category label and icon
        String getCategoryLabel(String subject) {
          final subjectLower = subject.toLowerCase();
          
          if (subjectLower.contains('lab') || subjectLower.contains('laboratory') || subjectLower.contains('practical')) {
            return 'LAB';
          } else if (subjectLower.contains('lecture') || subjectLower.contains('theory')) {
            return 'LECTURE';
          } else if (subjectLower.contains('tutorial') || subjectLower.contains('seminar')) {
            return 'TUTORIAL';
          } else if (subjectLower.contains('workshop') || subjectLower.contains('project')) {
            return 'WORKSHOP';
          } else if (subjectLower.contains('exam') || subjectLower.contains('test') || subjectLower.contains('quiz')) {
            return 'EXAM';
          } else if (subjectLower.contains('sport') || subjectLower.contains('gym') || subjectLower.contains('physical') || subjectLower.contains('pe')) {
            return 'SPORTS';
          } else if (subjectLower.contains('break') || subjectLower.contains('lunch') || subjectLower.contains('recess')) {
            return 'BREAK';
          } else {
            return 'CLASS';
          }
        }
        
        IconData getCategoryIcon(String subject) {
          final subjectLower = subject.toLowerCase();
          
          if (subjectLower.contains('lab') || subjectLower.contains('laboratory') || subjectLower.contains('practical')) {
            return Icons.science;
          } else if (subjectLower.contains('lecture') || subjectLower.contains('theory')) {
            return Icons.school;
          } else if (subjectLower.contains('tutorial') || subjectLower.contains('seminar')) {
            return Icons.groups;
          } else if (subjectLower.contains('workshop') || subjectLower.contains('project')) {
            return Icons.build;
          } else if (subjectLower.contains('exam') || subjectLower.contains('test') || subjectLower.contains('quiz')) {
            return Icons.quiz;
          } else if (subjectLower.contains('sport') || subjectLower.contains('gym') || subjectLower.contains('physical') || subjectLower.contains('pe')) {
            return Icons.sports;
          } else if (subjectLower.contains('break') || subjectLower.contains('lunch') || subjectLower.contains('recess')) {
            return Icons.restaurant;
          } else {
            return Icons.book;
          }
        }
        
        Color subjectColor = getSubjectColor(lecture.subject);
        Color courseColor = getCourseColor(lecture.course);
        String categoryLabel = getCategoryLabel(lecture.subject);
        IconData categoryIcon = getCategoryIcon(lecture.subject);
        
        // Get complementary colors for enhanced visuals
        Color lightShade = getLighterShade(subjectColor);
        Color darkShade = getDarkerShade(subjectColor);
        Color courseLightShade = getLighterShade(courseColor);
        
        if (isOngoing) {
          backgroundColor = const Color(0xFF16A34A).withOpacity(0.15); // Green background
          borderColor = const Color(0xFF16A34A);
          textColor = const Color(0xFF14532D); // Dark green text
          cardColor = const Color(0xFF16A34A).withOpacity(0.1);
          statusIcon = Icons.play_circle;
        } else if (isNext) {
          backgroundColor = lightShade.withOpacity(0.6); // Light shade background
          borderColor = subjectColor;
          textColor = const Color(0xFF1E3A8A); // Blue text
          cardColor = lightShade.withOpacity(0.3);
          statusIcon = Icons.upcoming;
        } else if (isPast) {
          backgroundColor = const Color(0xFF64748B).withOpacity(0.08); // Slate background
          borderColor = Colors.transparent;
          textColor = const Color(0xFF475569); // Slate text
          cardColor = const Color(0xFF64748B).withOpacity(0.05);
          statusIcon = Icons.check_circle_outline;
        } else {
          backgroundColor = lightShade.withOpacity(0.4); // Light shade background
          borderColor = Colors.transparent;
          textColor = const Color(0xFF1F2937); // Dark text
          cardColor = lightShade.withOpacity(0.2);
          statusIcon = Icons.schedule;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: borderColor != Colors.transparent 
                ? Border.all(color: borderColor, width: 2)
                : null,
            boxShadow: [
              if (isNext || isOngoing)
                BoxShadow(
                  color: borderColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Time block with dynamic styling
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOngoing 
                          ? [const Color(0xFF16A34A), const Color(0xFF15803D)] // Green gradient
                          : isNext 
                              ? [subjectColor, darkShade] // Subject color gradient
                              : isPast
                                  ? [const Color(0xFF6B7280), const Color(0xFF4B5563)] // Gray gradient
                                  : [lightShade, subjectColor], // Light to normal gradient
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      if (isNext || isOngoing)
                        BoxShadow(
                          color: (isOngoing ? Colors.green : subjectColor).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        startTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontProvider.timeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                      ),
                      Text(
                        endTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontProvider.timeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Lecture details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lecture.subject,
                              style: TextStyle(
                                fontSize: fontProvider.subjectFontSize,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (statusIcon != null)
                            Icon(
                              statusIcon,
                              color: borderColor != Colors.transparent ? borderColor : Colors.grey,
                              size: fontProvider.mediumIconSize,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      const SizedBox(height: 4),
                      
                      // Course and semester info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: courseLightShade.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: courseColor.withOpacity(0.4), width: 0.5),
                            ),
                            child: Text(
                              lecture.course,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: courseColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lecture.semester,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${duration.inMinutes}m',
                            style: TextStyle(
                              fontSize: fontProvider.smallFontSize,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Category badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [subjectColor, darkShade],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: subjectColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  categoryIcon,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  categoryLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person, size: fontProvider.smallIconSize, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lecture.teacher.name,
                              style: TextStyle(
                                fontSize: fontProvider.bodyFontSize,
                                color: Colors.grey[600],
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
                          Icon(Icons.location_on, size: fontProvider.smallIconSize, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lecture.classroom,
                              style: TextStyle(
                                fontSize: fontProvider.bodyFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Chapter info if available and space permits
                      if (lecture.chapter != null && lecture.chapter!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            lecture.chapter!,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1), // Blue
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available,
              size: 64,
              color: Color(0xFF3B82F6), // Blue
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Lectures Today',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A), // Blue
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enjoy your free day!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1), // Blue
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A8A), // Blue
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(now),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeFormat.format(now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLectureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Lecture',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        if (nextLecture != null)
          Column(
            children: [
              LectureCard(lecture: nextLecture!),
              const SizedBox(height: 16),
              TeacherInfoCard(teacher: nextLecture!.teacher),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.schedule,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No upcoming lectures',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enjoy your break!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTodayScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleScreen(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todaySchedule.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No lectures scheduled for today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaySchedule.length > 3 ? 3 : todaySchedule.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return LectureCard(lecture: todaySchedule[index]);
            },
          ),
        if (todaySchedule.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
                  );
                },
                child: Text('View ${todaySchedule.length - 3} more lectures'),
              ),
            ),
          ),
      ],
    );
  }

  List<String> _getUniqueClasses(List<Lecture> lectures) {
    final courses = lectures.map((lecture) => lecture.course).toSet().toList();
    courses.sort();
    return courses;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load lectures',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!.contains('Network') 
                ? 'Please check your connection and try again'
                : 'Something went wrong. Please try again.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
