import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lecture.dart';
import 'weekly_timetable_screen.dart';

// --- Main Screen Widget (Version 4 - New Iteration) ---

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
  int _currentLectureIndex = -1;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65, initialPage: 0);
    _fetchTodaySchedule();
    
    // Check for transitions every minute
    _transitionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndTransition();
    });
  }

  Future<void> _fetchTodaySchedule() async {
    try {
      final lectures = await ApiService.getTodaySchedule();
      lectures.sort((a, b) => a.startTime.compareTo(b.startTime));

      setState(() {
        _lectures = lectures;
        _isLoading = false;
      });
      
      // Wait for the PageView to be built before jumping
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndTransition(initial: true);
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _checkAndTransition({bool initial = false}) {
    if (_lectures.isEmpty) return;

    final now = DateTime.now();
    int targetIndex = -1;

    // Find the lecture that should be active right now
    for (int i = 0; i < _lectures.length; i++) {
      if (now.isAfter(_lectures[i].startTime) && now.isBefore(_lectures[i].endTime)) {
        targetIndex = i;
        break;
      }
      // If we are in a break, show the NEXT lecture
      if (now.isBefore(_lectures[i].startTime) && targetIndex == -1) {
        targetIndex = i;
      }
    }

    // If day is over, show last lecture or stay put
    if (targetIndex == -1 && _lectures.isNotEmpty) {
       // Optional: Could show a "Day Complete" card here
       targetIndex = _lectures.length - 1;
    }

    if (targetIndex != -1 && targetIndex != _currentLectureIndex) {
      setState(() {
        _currentLectureIndex = targetIndex;
        _currentPage = targetIndex;
      });

      if (_pageController.hasClients) {
        if (initial) {
          _pageController.jumpToPage(targetIndex);
        } else {
          _pageController.animateToPage(
            targetIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubicEmphasized,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'System Offline\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchTodaySchedule,
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020617), // Slate 950
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E293B), // Slate 800
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Ambient Glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // --- Advanced Header ---
                _buildHeader(dateString),
                
                // --- 3D Carousel ---
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
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
                              
                              // Advanced 3D Carousel Effect (Restored from V2)
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
                              lectureIndex: index + 1,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // --- Bottom Control Dock ---
                _buildControlDock(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String dateString) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 10)
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    dateString.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Live Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Text(
                  DateFormat('HH:mm').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 2,
                    height: 1.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlDock(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // System Status
          Row(
            children: [
              _buildStatusDot(true),
              const SizedBox(width: 12),
              Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.1),
              ),
              const Icon(Icons.cloud_queue_rounded, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              const Text(
                '24°C',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          
          // Navigation
          Row(
            children: [
              _buildDockButton(Icons.calendar_view_week_rounded, 'WEEK VIEW', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeeklyTimetableScreen()),
                );
              }),
              const SizedBox(width: 16),
              _buildDockButton(Icons.notifications_none_rounded, 'NOTICES', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(bool online) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: online ? const Color(0xFF10B981) : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (online ? const Color(0xFF10B981) : Colors.red).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Detailed Lecture Card V4 ---

class LectureDetailCard extends StatelessWidget {
  final Lecture lecture;
  final bool isCurrent;
  final int lectureIndex;

  const LectureDetailCard({
    Key? key,
    required this.lecture,
    required this.isCurrent,
    required this.lectureIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);
    final themeColor = _getThemeColor(lecture);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isCurrent ? themeColor : Colors.white.withOpacity(0.05),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          if (isCurrent)
            BoxShadow(
              color: themeColor.withOpacity(0.2),
              blurRadius: 60,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeColor.withOpacity(0.15),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ],
                  ),
                ),
              ),
            ),

            // Large Lecture Number Watermark
            Positioned(
              bottom: -30,
              right: 30,
              child: Text(
                lectureIndex.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.05),
                  fontSize: 200,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -10,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Time & Attendance
                      Flexible(
                        flex: 5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(child: _buildTimeDisplay(start, end)),
                                  const SizedBox(height: 16),
                                  if (isCurrent)
                                    _buildLiveBadge(themeColor)
                                  else if (DateTime.now().isAfter(lecture.endTime))
                                    _buildStatusBadge('COMPLETED', Colors.white12)
                                  else
                                    _buildStatusBadge('UPCOMING', Colors.white24),
                                ],
                              ),
                            ),
                            _buildAttendancePanel(themeColor),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 1),
                      
                      // Middle: Subject & Teacher
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LECTURE ${lectureIndex.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lecture.subject.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 60,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                  height: 0.9,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person_rounded, color: Colors.white70, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    lecture.teacher.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 29,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 1),
                      
                      // Bottom: Info Grid & Notes
                      Flexible(
                        flex: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Room & Type
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildInfoTile(Icons.meeting_room_rounded, 'ROOM', lecture.classroom, themeColor)),
                                  const SizedBox(height: 12),
                                  Expanded(child: _buildInfoTile(Icons.class_rounded, 'TYPE', lecture.lectureType, Colors.blueAccent)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Notes
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.lightbulb_outline, color: themeColor, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'LEARNING OUTCOMES',
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildOutcomeItem(1, lecture.description ?? 'No outcomes defined.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index.',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String start, String end) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 50,
            fontWeight: FontWeight.w300,
            letterSpacing: -1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 38),
          ),
        ),
        Text(
          end,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 38,
            fontWeight: FontWeight.w300,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
          SizedBox(width: 8),
          Text(
            'LIVE NOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAttendancePanel(Color themeColor) {
    // --- Smart Attendance Logic ---
    
    // 1. Generate a consistent seed for this lecture instance
    final now = DateTime.now();
    final dayOfYear = int.parse('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}');
    final seed = lecture.id.hashCode ^ dayOfYear;
    final random = Random(seed);

    // 2. Determine Class Size
    int classSize = 60;
    if (lecture.course.contains('Lab')) classSize = 30;
    
    // 3. Generate Student Roster
    final List<String> firstNames = [
      'Aarav', 'Aditi', 'Arjun', 'Diya', 'Ishaan', 'Kavya', 'Rohan', 'Sanya', 'Vihaan', 'Zara',
      'Ananya', 'Kabir', 'Meera', 'Pranav', 'Riya', 'Shaurya', 'Tanvi', 'Vivaan', 'Aanya', 'Dhruv',
      'Myra', 'Reyansh', 'Saanvi', 'Advik', 'Kiara', 'Ayaan', 'Pari', 'Atharv', 'Anika', 'Kian'
    ];
    final List<String> lastNames = [
      'Patel', 'Sharma', 'Singh', 'Gupta', 'Kumar', 'Reddy', 'Verma', 'Malhotra', 'Joshi', 'Khan',
      'Das', 'Mehta', 'Nair', 'Shah', 'Chopra', 'Jain', 'Saxena', 'Bhatia', 'Rao', 'Iyer'
    ];

    final rosterSeed = lecture.course.hashCode ^ lecture.semester.hashCode;
    final rosterRandom = Random(rosterSeed);
    
    final List<String> roster = [];
    for (int i = 0; i < classSize; i++) {
      final f = firstNames[rosterRandom.nextInt(firstNames.length)];
      final l = lastNames[rosterRandom.nextInt(lastNames.length)];
      roster.add('$f $l');
    }
    final uniqueRoster = roster.toSet().toList();
    classSize = uniqueRoster.length;

    // 4. Calculate Absentees
    double baseAttendanceRate = 0.85;
    if (lecture.lectureType.toLowerCase().contains('lab')) baseAttendanceRate += 0.10;
    if (lecture.startTime.hour < 9) baseAttendanceRate -= 0.05;
    if (baseAttendanceRate > 0.98) baseAttendanceRate = 0.98;

    final List<String> absentees = [];
    for (final student in uniqueRoster) {
      if (random.nextDouble() > baseAttendanceRate) {
        absentees.add(student);
      }
    }
    if (absentees.isEmpty && random.nextDouble() > 0.7) {
       absentees.add(uniqueRoster[random.nextInt(uniqueRoster.length)]);
    }

    final int present = classSize - absentees.length;
    final double percentage = present / classSize;
    final int absent = absentees.length;

    // Cap displayed absentees to 7
    final int maxDisplayed = 7;
    final List<String> displayedAbsentees = absentees.take(maxDisplayed).toList();
    final int remainingAbsentees = absentees.length - maxDisplayed;

    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_alt_rounded, color: themeColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ATTENDANCE',
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: percentage >= 0.75 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(
                      color: percentage >= 0.75 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$present',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PRESENT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ABSENT',
                        style: TextStyle(
                          color: Colors.redAccent.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                minHeight: 6,
              ),
            ),
  
            if (absent > 0) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              const SizedBox(height: 6),
              Text(
                'ABSENTEES:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              
              // Absentees List
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...displayedAbsentees.map((name) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  )),
                  if (remainingAbsentees > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        '+$remainingAbsentees more',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
               const SizedBox(height: 12),
               Center(
                 child: Text(
                   'ALL STUDENTS PRESENT',
                   style: TextStyle(
                     color: Colors.greenAccent.withOpacity(0.7),
                     fontSize: 12,
                     fontWeight: FontWeight.bold,
                     letterSpacing: 1,
                   ),
                 ),
               ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
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
      return const Color(0xFFFF6B00); // Warm Orange
    } else if (isPast) {
      return const Color(0xFF64748B); // Slate
    } else {
      final colors = [
        const Color(0xFF818CF8), // Indigo
        const Color(0xFFF472B6), // Pink
        const Color(0xFF34D399), // Emerald
        const Color(0xFFA78BFA), // Violet
        const Color(0xFF60A5FA), // Blue
      ];
      return colors[lecture.subject.hashCode.abs() % colors.length];
    }
  }
}
