import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lecture.dart';
import 'weekly_timetable_screen.dart';

// --- Main Screen Widget ---

class TimetableCarouselScreen extends StatefulWidget {
  const TimetableCarouselScreen({Key? key}) : super(key: key);

  @override
  State<TimetableCarouselScreen> createState() => _TimetableCarouselScreenState();
}

class _TimetableCarouselScreenState extends State<TimetableCarouselScreen> {
  late PageController _pageController;
  List<Lecture> _lectures = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _currentLectureIndex = -1; // Index of the lecture happening right now

  @override
  void initState() {
    super.initState();
    // Viewport fraction 0.6 to decrease card width and show more context
    _pageController = PageController(viewportFraction: 0.6, initialPage: 0);
    _fetchTodaySchedule();
  }

  Future<void> _fetchTodaySchedule() async {
    try {
      final lectures = await ApiService.getTodaySchedule();
      
      // Sort by start time
      lectures.sort((a, b) => a.startTime.compareTo(b.startTime));

      final now = DateTime.now();
      int currentIndex = -1;

      // Find the current lecture
      for (int i = 0; i < lectures.length; i++) {
        if (now.isAfter(lectures[i].startTime) && now.isBefore(lectures[i].endTime)) {
          currentIndex = i;
          break;
        }
        // If no lecture is active, focus on the next upcoming one
        if (now.isBefore(lectures[i].startTime) && currentIndex == -1) {
          currentIndex = i;
        }
      }
      
      // If all lectures are done, focus on the last one
      if (currentIndex == -1 && lectures.isNotEmpty) {
        currentIndex = lectures.length - 1;
      }

      setState(() {
        _lectures = lectures;
        _isLoading = false;
        _currentLectureIndex = currentIndex;
        _currentPage = currentIndex != -1 ? currentIndex : 0;
        
        // Jump to the current lecture
        if (currentIndex != -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(currentIndex);
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading schedule\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTodaySchedule,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lectures.isEmpty) {
       return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: Text('No lectures scheduled for today', style: TextStyle(color: Colors.white, fontSize: 24))),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: Column(
          children: [
            // --- Custom Header ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S SCHEDULE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateString.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  // Digital Clock Placeholder (Static for now, can be animated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Text(
                          DateFormat('HH:mm').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 2,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65, // Increased height for more content
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _lectures.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final lecture = _lectures[index];
                      final isCurrentLecture = index == _currentLectureIndex;

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double page = 0.0;
                          if (_pageController.position.haveDimensions) {
                            page = _pageController.page ?? 0;
                          } else {
                            page = _currentPage.toDouble();
                          }
                          
                          double delta = (index - page);
                          double absDelta = delta.abs();
                          
                          // Advanced 3D Carousel Effect
                          final Matrix4 matrix = Matrix4.identity()
                            ..setEntry(3, 2, 0.001); // Perspective
                            
                          // Scale: Center card is largest
                          double scale = (1 - (absDelta * 0.15)).clamp(0.8, 1.0);
                          
                          // Translation: Move side cards closer to center (overlap)
                          double transX = delta * -30.0;
                          
                          // Rotation: Rotate side cards inward
                          double rotationY = delta * 0.2; // Radians
                          
                          matrix
                            ..translate(transX, 0.0, 0.0)
                            ..scale(scale)
                            ..rotateY(-rotationY);

                          // Opacity: Fade out side cards
                          double opacity = (1 - (absDelta * 0.4)).clamp(0.4, 1.0);
                          
                          return Transform(
                            transform: matrix,
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: opacity,
                              child: child,
                            ),
                          );
                        },
                        child: LectureDetailCard(
                          lecture: lecture,
                          isCurrent: isCurrentLecture,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // --- Bottom Control Center ---
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Weather & Status
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        '24°C',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 20,
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM ONLINE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  // Right: Quick Actions
                  Row(
                    children: [
                      _buildQuickAction(Icons.calendar_view_week_rounded, 'WEEK', () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WeeklyTimetableScreen()),
                        );
                      }),
                      const SizedBox(width: 16),
                      _buildQuickAction(Icons.people_alt_rounded, 'TEACHERS', () {}),
                      const SizedBox(width: 16),
                      _buildQuickAction(Icons.notifications_none_rounded, 'ALERTS', () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Detailed Lecture Card Widget ---

class LectureDetailCard extends StatelessWidget {
  final Lecture lecture;
  final bool isCurrent;

  const LectureDetailCard({
    Key? key,
    required this.lecture,
    required this.isCurrent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);
    
    // Dynamic Colors based on Status
    final Color themeColor = _getThemeColor(lecture);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95), // Solid dark background
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isCurrent ? themeColor : Colors.white.withOpacity(0.1),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          if (isCurrent)
            BoxShadow(
              color: themeColor.withOpacity(0.3),
              blurRadius: 50,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Subtle Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeColor.withOpacity(0.1),
                      Colors.transparent,
                      Colors.transparent,
                      themeColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            
            // Decorative Circle
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      themeColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: Split into Left (Info) and Right (Attendance)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Time, Status, Subject, Teacher
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time & Status Row
                            Row(
                              children: [
                                _buildTimePill(start, end),
                                const SizedBox(width: 16),
                                if (isCurrent)
                                  PulsingBadge(color: themeColor, text: 'LIVE NOW')
                                else
                                  _buildStatusBadge('UPCOMING', Colors.grey),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Subject Title
                            Text(
                              lecture.subject.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48, // Increased font size
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                height: 1.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Teacher Name
                            Text(
                              lecture.teacher.name,
                              style: const TextStyle( // Removed opacity for better visibility
                                color: Colors.white,
                                fontSize: 22, // Increased font size
                                fontWeight: FontWeight.w600, // Increased weight
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Right: Attendance Panel
                      _buildCompactAttendance(themeColor),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBox(
                          Icons.meeting_room_rounded,
                          'ROOM',
                          lecture.classroom,
                          themeColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoBox(
                          Icons.class_rounded,
                          'TYPE',
                          lecture.lectureType,
                          Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Bottom Section: Homework/Notes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Darker background for contrast
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sticky_note_2_outlined, color: themeColor, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'NOTES',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 18, // Much larger label
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lecture.description ?? 'No notes available.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24, // Much larger text
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3, // Allow one more line
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(String start, String end) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Text(
            '$start - $end',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAttendance(Color themeColor) {
    // Mock Data for "Intelligent" feel - Simulating live data
    final int total = 60;
    final int seed = lecture.id.hashCode;
    final int present = 48 + (seed % 12); 
    final int absent = total - present;
    final double percentage = present / total;
    
    // Mock Absentee Names
    final List<String> allStudents = [
      'Aarav Patel', 'Aditi Sharma', 'Arjun Singh', 'Diya Gupta', 'Ishaan Kumar',
      'Kavya Reddy', 'Rohan Verma', 'Sanya Malhotra', 'Vihaan Joshi', 'Zara Khan',
      'Ananya Das', 'Kabir Mehta'
    ];
    // Deterministically select absentees based on seed
    final List<String> absentees = [];
    for (int i = 0; i < absent; i++) {
      absentees.add(allStudents[(seed + i) % allStudents.length]);
    }

    return Container(
      width: 220, // Fixed width for consistency
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATTENDANCE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(Icons.pie_chart_rounded, color: themeColor, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$present',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'PRESENT',
                    style: TextStyle(
                      color: Colors.greenAccent.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$absent',
                    style: TextStyle(
                      color: Colors.redAccent.shade100,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'ABSENT',
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar (The "Yellow Line")
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              minHeight: 4,
            ),
          ),

          if (absent > 0) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 8),
            Text(
              'ABSENTEES:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: absentees.map((name) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.red[100],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Increased opacity for better contrast
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18), // Removed opacity
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8), // Increased opacity
                  fontSize: 12, // Increased size
                  fontWeight: FontWeight.w900, // Increased weight
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Increased size
              fontWeight: FontWeight.w800, // Increased weight
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getThemeColor(Lecture lecture) {
    final now = DateTime.now();
    final isPast = now.isAfter(lecture.endTime);
    final isCurrent = now.isAfter(lecture.startTime) && now.isBefore(lecture.endTime);
    
    if (isCurrent) {
      return const Color(0xFFFF6B00); // Cozy Warm Orange Glow for Active
    } else if (isPast) {
      return const Color(0xFF64748B); // Muted Slate for Past
    } else {
      // Future lectures get cool, cozy tones
      final colors = [
        const Color(0xFF818CF8), // Soft Indigo
        const Color(0xFFF472B6), // Soft Pink
        const Color(0xFF34D399), // Soft Emerald
        const Color(0xFFA78BFA), // Soft Violet
        const Color(0xFF60A5FA), // Soft Blue
      ];
      return colors[lecture.subject.hashCode.abs() % colors.length];
    }
  }
}

class PulsingBadge extends StatefulWidget {
  final Color color;
  final String text;

  const PulsingBadge({Key? key, required this.color, required this.text}) : super(key: key);

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * (_animation.value - 1.0),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 8, color: Colors.white.withOpacity(_animation.value > 1.1 ? 1.0 : 0.8)),
              const SizedBox(width: 6),
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}