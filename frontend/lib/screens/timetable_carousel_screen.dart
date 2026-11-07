import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lecture.dart';
import '../themes/design_system.dart';

// --- Main Screen Widget: the lesson carousel, in the Forest night signage theme ---

class TimetableCarouselScreen extends StatefulWidget {
  /// A short label above the date: the room a classroom screen hangs in, or
  /// "Whole school". Shown in capitals, in gold. Null: no label.
  final String? eyebrow;

  const TimetableCarouselScreen({super.key, this.eyebrow});

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
        if (initial || MediaQuery.disableAnimationsOf(context)) {
          _pageController.jumpToPage(targetIndex);
        } else {
          _pageController.animateToPage(
            targetIndex,
            duration: DesignSystem.animationSlow,
            curve: DesignSystem.curveEntrance,
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

  /// Amber, with black text: the screen cannot confirm there is no alert.
  Widget _buildAlertStatusUnknownBanner() {
    return Container(
      width: double.infinity,
      // Room at both sides, so the text stays centred and clear of the corner badge.
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: DesignSystem.cornerInset(MediaQuery.sizeOf(context).width)),
      color: DesignSystem.alertAmber,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: DesignSystem.onAlertAmber, size: 30),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'Alert status unavailable: this screen cannot reach the school server. Follow staff instructions.',
                style: DesignSystem.sans(size: 22, weight: FontWeight.w700, color: DesignSystem.onAlertAmber, height: 1.25),
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
    // --- Emergency: red, white text, no decoration ---
    if (type == 'emergency') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        color: DesignSystem.emergency,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: DesignSystem.onEmergency, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  message,
                  style: DesignSystem.sans(size: 32, weight: FontWeight.w700, color: DesignSystem.onEmergency, height: 1.2),
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

    // --- Warning: amber, black text (the same amber as "cannot confirm") ---
    if (type == 'warning') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        color: DesignSystem.alertAmber,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: DesignSystem.onAlertAmber, size: 36),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  message,
                  style: DesignSystem.sans(size: 30, weight: FontWeight.w700, color: DesignSystem.onAlertAmber, height: 1.2),
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

    // --- Info/Notice: a bar on the card colour with a gold rule and a NOTICE badge ---
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      decoration: const BoxDecoration(
        color: DesignSystem.popover,
        border: Border(bottom: BorderSide(color: DesignSystem.gold, width: 2)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: DesignSystem.accent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, color: DesignSystem.accentForeground, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'NOTICE',
                    style: DesignSystem.eyebrow(size: 16, color: DesignSystem.accentForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                message,
                style: DesignSystem.sans(size: 24, weight: FontWeight.w400),
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
        backgroundColor: DesignSystem.background,
        body: Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: DesignSystem.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: DesignSystem.destructive, size: 56),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'System Offline',
                      style: DesignSystem.serif(size: 44),
                    ),
                    TextSpan(
                      text: '\n$_error',
                      style: DesignSystem.sans(size: 24, color: DesignSystem.mutedForeground, height: 1.6),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _fetchTodaySchedule(isPolling: false),
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primary,
                  foregroundColor: DesignSystem.primaryForeground,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  textStyle: DesignSystem.sans(size: 22, weight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusControl)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Stack(
        children: [
          Column(
            children: [
              // --- Header: eyebrow, serif title with its gold rule, weather and clock ---
              _buildHeader(dateString),

              // --- Carousel: today's lessons, the current one centred ---
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // As tall as the room left over, up to three quarters of the screen.
                    final height = constraints.maxHeight.clamp(0.0, screen.height * 0.78).toDouble();
                    return Center(
                      child: SizedBox(
                        height: height,
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

                                final absDelta = (index - page).abs();

                                // Flat, calm: the neighbours are a little smaller and quieter
                                // (never below 4.5:1 for their text), without tilt or glow.
                                final scale = (1 - (absDelta * 0.10)).clamp(0.88, 1.0);
                                final opacity = (1 - (absDelta * 0.28)).clamp(DesignSystem.fadedOpacity, 1.0);

                                return Transform.scale(
                                  scale: scale,
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
                    );
                  },
                ),
              ),
            ],
          ),

          // Emergency Notification Overlay
          _buildNotificationOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(String dateString) {
    final s = DesignSystem.scaleFor(MediaQuery.sizeOf(context).width);
    final eyebrow = widget.eyebrow?.trim() ?? '';
    return Padding(
      padding: EdgeInsets.fromLTRB(40 * s, 48 * s, 40 * s, 12 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow.isNotEmpty) ...[
                Text(eyebrow.toUpperCase(), style: DesignSystem.eyebrow(size: 22 * s)),
                SizedBox(height: 4 * s),
              ],
              Text(
                dateString,
                style: DesignSystem.serif(size: 48 * s, height: 1.15, letterSpacing: -0.5 * s),
              ),
              SizedBox(height: 12 * s),
              Container(width: DesignSystem.ruleWidth * s, height: DesignSystem.ruleHeight, color: DesignSystem.gold),
            ],
          ),

          // Live Clock & Weather
          Row(
            children: [
              if (_temperature != null)
                Container(
                  margin: EdgeInsets.only(right: 16 * s),
                  padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
                  decoration: DesignSystem.cardDecoration(),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_rounded, color: DesignSystem.gold, size: 30 * s),
                      SizedBox(width: 12 * s),
                      Text(
                        '${_temperature!.toStringAsFixed(1)}°C',
                        style: DesignSystem.sans(size: 30 * s, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 6 * s),
                decoration: DesignSystem.cardDecoration(),
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      DateFormat('HH:mm').format(DateTime.now()),
                      style: DesignSystem.display(size: 60 * s, height: 1.1),
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

// --- Detailed Lecture Card: a card on the card colour, a hairline border, gold when it is the current one ---

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: DesignSystem.cardDecoration(
        borderColor: isCurrent ? DesignSystem.gold : DesignSystem.border,
        borderWidth: isCurrent ? 2 : DesignSystem.hairline,
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The layout is drawn for a card at least this big (a 1080p screen with its
            // cards and notices showing). On a smaller screen, or a smaller card, it is
            // the same layout scaled down, so nothing overlaps or is cut off.
            const designWidth = 1140.0;
            const designHeight = 470.0;
            final scale = math.min(1.0, math.min(constraints.maxWidth / designWidth, constraints.maxHeight / designHeight));
            return FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth / scale,
                height: constraints.maxHeight / scale,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Time & Class
                Flexible(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: _buildTimeDisplay(start, end),
                            ),
                            const SizedBox(height: 16),
                            // "Live" only while the lesson is on; before it starts, the focused card is next.
                            if (isCurrent && DateTime.now().isAfter(lecture.startTime) && DateTime.now().isBefore(lecture.endTime))
                              _buildBadge('LIVE NOW', DesignSystem.success, DesignSystem.successSoft)
                            else if (DateTime.now().isAfter(lecture.endTime))
                              _buildBadge('COMPLETED', DesignSystem.mutedForeground, DesignSystem.muted)
                            else if (isCurrent)
                              _buildBadge('NEXT', DesignSystem.accentForeground, DesignSystem.accent)
                            else
                              _buildBadge('UPCOMING', DesignSystem.mutedForeground, DesignSystem.muted),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      _buildClassPanel(),
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
                          style: DesignSystem.eyebrow(size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lecture.subject,
                          style: DesignSystem.serif(size: 72, height: 1.05, letterSpacing: -1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lecture.teacher.name,
                          style: DesignSystem.sans(size: 36, weight: FontWeight.w400),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildInfoTile('ROOM', lecture.classroom)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInfoTile('TYPE', lecture.lectureType)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notes
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: DesignSystem.cardDecoration(color: DesignSystem.muted),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: DesignSystem.ochre, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'LEARNING OUTCOMES',
                                    style: DesignSystem.eyebrow(size: 18),
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
                ),
              ),
            );
          },
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
            style: DesignSystem.serif(size: 26, color: DesignSystem.ochre, height: 1.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: DesignSystem.sans(size: 26, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Lesson times: serif lining figures; the end time quieter.
  Widget _buildTimeDisplay(String start, String end) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          start,
          style: DesignSystem.display(size: 64),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '-',
            style: DesignSystem.display(size: 44, color: DesignSystem.mutedForeground),
          ),
        ),
        Text(
          end,
          style: DesignSystem.display(size: 44, color: DesignSystem.mutedForeground),
        ),
      ],
    );
  }

  /// A status badge: a pill on the soft status colour, with a dot and a word.
  Widget _buildBadge(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: DesignSystem.sans(size: 20, weight: FontWeight.w700, color: foreground, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  /// The class and room for this period, from the timetable. Screens never
  /// show anything about individual students (no attendance, no names).
  Widget _buildClassPanel() {
    final substituted = lecture.lectureType == 'Substitution';
    final tiles = <Widget>[
      if (lecture.course.isNotEmpty) _buildInfoTile('CLASS', lecture.course, width: 250),
      if (lecture.classroom.isNotEmpty) _buildInfoTile('ROOM', lecture.classroom, width: 250),
      if (substituted) _buildInfoTile('TODAY', 'Substitute arranged', width: 360, substitution: true),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Expanded(
      flex: 3,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              tiles[i],
            ],
          ],
        ),
      ),
    );
  }

  /// An eyebrow label over a value on a muted tile. A substitution is flagged in the warning colours.
  Widget _buildInfoTile(String label, String value, {double? width, bool substitution = false}) {
    final tile = Container(
      width: width,
      height: width == null ? null : 112,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: DesignSystem.cardDecoration(
        color: substitution ? DesignSystem.warningSoft : DesignSystem.muted,
        borderColor: substitution ? DesignSystem.warning : DesignSystem.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: DesignSystem.eyebrow(size: 16, color: substitution ? DesignSystem.warning : DesignSystem.ochre),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: DesignSystem.serif(size: 48, height: 1.1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
    return tile;
  }
}
