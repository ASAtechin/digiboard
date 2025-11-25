import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';
import '../themes/design_system.dart';

class CarouselTimetable extends StatefulWidget {
  final List<Lecture> lectures;

  const CarouselTimetable({Key? key, required this.lectures}) : super(key: key);

  @override
  State<CarouselTimetable> createState() => _CarouselTimetableState();
}

class _CarouselTimetableState extends State<CarouselTimetable> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Find the initial page (current or next lecture)
    int initialPage = 0;
    final now = DateTime.now();
    for (int i = 0; i < widget.lectures.length; i++) {
      if (now.isBefore(widget.lectures[i].endTime)) {
        initialPage = i;
        break;
      }
    }
    _currentPage = initialPage;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.3, // Adjusted to show 3 distinct cards like the reference image
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500, // Height for the carousel area
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.lectures.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = 0;
              if (_pageController.position.haveDimensions) {
                page = _pageController.page ?? 0;
              } else {
                page = _currentPage.toDouble();
              }
              
              // Calculate distance from center of viewport
              double delta = (index - page).abs();
              
              // Scale factor: Center is 1.0, sides are 0.85
              // Matches the reference image hierarchy
              double scale = (1 - (delta * 0.3)).clamp(0.85, 1.0);
              scale = Curves.easeOutQuad.transform(scale);
              
              // Active state interpolation
              double activeFactor = (1 - delta).clamp(0.0, 1.0);
              activeFactor = Curves.easeInOutCubic.transform(activeFactor);
              
              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: _buildCard(widget.lectures[index], activeFactor),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(Lecture lecture, double activeFactor) {
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);
    
    // Determine status
    final now = DateTime.now();
    bool isInProgress = now.isAfter(lecture.startTime) && now.isBefore(lecture.endTime);
    
    // Interpolate Colors
    final Color activeColor = const Color(0xFF6366F1); // Active Purple/Indigo
    final Color inactiveColor = Colors.white.withOpacity(0.1); // Inactive Glass
    final Color cardColor = Color.lerp(inactiveColor, activeColor, activeFactor)!;
    
    final Color activeBorderColor = const Color(0xFFA5B4FC);
    final Color inactiveBorderColor = Colors.white.withOpacity(0.1);
    final Color borderColor = Color.lerp(inactiveBorderColor, activeBorderColor, activeFactor)!;
    
    final double borderWidth = 1.0 + activeFactor; // 1.0 to 2.0
    
    final Color textColor = Colors.white;

    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20), // Increased margin for separation
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.6 * activeFactor),
            blurRadius: 30 * activeFactor,
            spreadRadius: 5 * activeFactor,
          )
        ],
        gradient: activeFactor > 0.5
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(inactiveColor, const Color(0xFF818CF8), activeFactor)!,
                  Color.lerp(inactiveColor, const Color(0xFF4F46E5), activeFactor)!,
                ],
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Time & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$start - $end',
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isInProgress)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subject
                  Text(
                    lecture.subject,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24 + (12 * activeFactor), // Smooth font size transition
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Teacher
                  Text(
                    lecture.teacher.name,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Progress Bar (Visual only)
                  Container(
                    height: 6,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: isInProgress ? 0.6 : (now.isAfter(lecture.endTime) ? 1.0 : 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: activeFactor > 0.5 ? const Color(0xFFFBBF24) : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Homework (Fade in based on activeFactor)
                  Opacity(
                    opacity: (activeFactor - 0.5).clamp(0.0, 0.5) * 2, // Only visible when mostly active
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assignment_outlined, color: textColor.withOpacity(0.9), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'HOMEWORK',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lecture.description ?? 'No homework assigned.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
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

    if (isInProgress) {
      return RotatingBorder(
        isActive: true,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class RotatingBorder extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const RotatingBorder({Key? key, required this.child, required this.isActive}) : super(key: key);

  @override
  State<RotatingBorder> createState() => _RotatingBorderState();
}

class _RotatingBorderState extends State<RotatingBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(4), // Border width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28), // Outer radius
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: 6.28,
              colors: const [
                Colors.transparent,
                Color(0xFF818CF8), // Indigo
                Colors.transparent,
                Color(0xFFC084FC), // Purple
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              transform: GradientRotation(_controller.value * 6.28),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF818CF8).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
