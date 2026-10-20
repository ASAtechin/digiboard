import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lecture.dart';

// --- Main Screen Widget (Version 4 - New Iteration) ---

class TimetableCarouselScreen extends StatefulWidget {
  const TimetableCarouselScreen({super.key});

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
  double? _temperature;
  // Current alerts, highest severity first, as last confirmed by the server.
  List<Map<String, dynamic>> _alerts = [];
  // True when the latest alert check failed: the screen cannot confirm there is no alert.
  bool _alertStatusUnknown = false;
  Timer? _notificationTimer;
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65, initialPage: 0);
    _fetchTodaySchedule();
    _fetchWeather();
    _fetchNotification();
    
    // Check for transitions every minute
    _transitionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndTransition();
    });

    // Poll for notifications every 10 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchNotification();
    });

    // Poll for schedule updates every 5 seconds
    _scheduleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchTodaySchedule(isPolling: true);
    });
  }

  Future<void> _fetchWeather() async {
    try {
      // Fetch location from DB settings
      final location = await ApiService.getSchoolLocation();
      double? lat;
      double? long;
      
      if (location != null) {
        lat = location['latitude'];
        long = location['longitude'];
        if (kDebugMode) {
          debugPrint('Using School Location from DB: ${location['address']} ($lat, $long)');
        }
      }

      final weatherData = await ApiService.getCurrentWeather(lat: lat, long: long);
      if (weatherData.containsKey('current_weather')) {
        setState(() {
          _temperature = weatherData['current_weather']['temperature'];
        });
      }
    } catch (e) {
      debugPrint('Error setting weather: $e');
    }
  }

  Future<void> _fetchTodaySchedule({bool isPolling = false}) async {
    try {
      final lectures = await ApiService.getTodaySchedule();
      lectures.sort((a, b) => a.startTime.compareTo(b.startTime));

      setState(() {
        _lectures = lectures;
        _isLoading = false;
      });
      
      // Wait for the PageView to be built before jumping
      if (!isPolling) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndTransition(initial: true);
        });
      } else {
        _checkAndTransition(initial: false);
      }
      
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
    _notificationTimer?.cancel();
    _scheduleTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotification() async {
    try {
      final status = await ApiService.getNotification();
      final alerts = <Map<String, dynamic>>[];
      final list = status['alerts'];
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic> && item['active'] == true) {
            alerts.add(item);
          }
        }
      } else if (status['active'] == true) {
        alerts.add(status);
      }
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _alertStatusUnknown = false;
        });
      }
    } catch (e) {
      debugPrint('Alert status unavailable: $e');
      // Keep the last confirmed alerts on screen and say the status cannot be confirmed.
      if (mounted) {
        setState(() {
          _alertStatusUnknown = true;
        });
      }
    }
  }

  // The highest-severity alert addressed to everyone or to the room on screen.
  Map<String, dynamic>? _alertForThisScreen() {
    for (final alert in _alerts) {
      final targets = alert['targets'];
      if (targets is List && targets.isNotEmpty) {
        if (_lectures.isEmpty || _currentPage >= _lectures.length) continue;
        final room = _lectures[_currentPage].classroom.toLowerCase();
        if (targets.any((t) => t.toString().toLowerCase() == room)) return alert;
        continue;
      }
      return alert;
    }
    return null;
  }

  Widget _buildNotificationOverlay() {
    final alert = _alertForThisScreen();
    if (alert == null && !_alertStatusUnknown) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alert != null)
            _buildAlertBanner(
              alert['message']?.toString() ?? 'Alert',
              alert['type']?.toString() ?? 'info',
            ),
          if (_alertStatusUnknown) _buildAlertStatusUnknownBanner(),
        ],
      ),
    );
  }

  Widget _buildAlertStatusUnknownBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      color: Colors.amber.shade800,
      child: const SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.black, size: 22),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Alert status unavailable: this screen cannot reach the school server. Follow staff instructions.',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String message, String type) {
    // --- Emergency Style (Full Banner) ---
    if (type == 'emergency') {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade900.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
    }

    // --- Info/Notice Style (Banner) ---
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95), // Dark Slate
          border: Border(
            bottom: BorderSide(
              color: Colors.blueAccent.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'NOTICE',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
    );
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
                onPressed: () => _fetchTodaySchedule(isPolling: false),
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
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
                      Colors.blueAccent.withValues(alpha: 0.1),
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
                                ..translateByDouble(transX, 0.0, 0.0, 1.0)
                                ..scaleByDouble(scale, scale, scale, 1.0)
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
              ],
            ),
            
            // Emergency Notification Overlay
            _buildNotificationOverlay(),
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
                        BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.5), blurRadius: 10)
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    dateString.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Live Clock & Weather
          Row(
            children: [
              if (_temperature != null)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '${_temperature!.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
        ],
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
    super.key,
    required this.lecture,
    required this.isCurrent,
    required this.lectureIndex,
  });

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
          color: isCurrent ? themeColor : Colors.white.withValues(alpha: 0.05),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          if (isCurrent)
            BoxShadow(
              color: themeColor.withValues(alpha: 0.2),
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
                      themeColor.withValues(alpha: 0.15),
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
                  color: Colors.white.withValues(alpha: 0.05),
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
                                  // "Live" only while the lesson is on; before it starts, the focused card is next.
                                  if (isCurrent && DateTime.now().isAfter(lecture.startTime) && DateTime.now().isBefore(lecture.endTime))
                                    _buildLiveBadge(themeColor)
                                  else if (DateTime.now().isAfter(lecture.endTime))
                                    _buildStatusBadge('COMPLETED', Colors.white12)
                                  else if (isCurrent)
                                    _buildStatusBadge('NEXT', themeColor.withValues(alpha: 0.35))
                                  else
                                    _buildStatusBadge('UPCOMING', Colors.white24),
                                ],
                              ),
                            ),
                            _buildClassPanel(themeColor),
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
                                      color: Colors.white.withValues(alpha: 0.1),
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
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                color: Colors.white.withValues(alpha: 0.9),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 38),
          ),
        ),
        Text(
          end,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
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
            color: color.withValues(alpha: 0.4),
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

  /// The class and room for this period, from the timetable. Screens never
  /// show anything about individual students (no attendance, no names).
  Widget _buildClassPanel(Color themeColor) {
    final substituted = lecture.lectureType == 'Substitution';
    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 420),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lecture.course.isNotEmpty) SizedBox(height: 96, child: _buildInfoTile(Icons.groups_rounded, 'CLASS', lecture.course, themeColor)),
          if (lecture.classroom.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(height: 96, child: _buildInfoTile(Icons.meeting_room_rounded, 'ROOM', lecture.classroom, themeColor)),
          ],
          if (substituted) ...[
            const SizedBox(height: 12),
            SizedBox(height: 96, child: _buildInfoTile(Icons.swap_horiz_rounded, 'TODAY', 'Substitute arranged', Colors.amber)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
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
              color: Colors.white.withValues(alpha: 0.5),
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
