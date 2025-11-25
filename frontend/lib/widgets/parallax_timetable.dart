import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';
import '../themes/design_system.dart';

class ParallaxTimetable extends StatefulWidget {
  final List<Lecture> lectures;

  const ParallaxTimetable({Key? key, required this.lectures}) : super(key: key);

  @override
  State<ParallaxTimetable> createState() => _ParallaxTimetableState();
}

class _ParallaxTimetableState extends State<ParallaxTimetable> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600, // Fixed height for the scrollable area
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.lectures.length,
        itemBuilder: (context, index) {
          return _buildParallaxItem(context, index);
        },
      ),
    );
  }

  Widget _buildParallaxItem(BuildContext context, int index) {
    final lecture = widget.lectures[index];
    final itemPosition = index * 220.0; // Approximate height of item
    final difference = _scrollOffset - itemPosition;
    final percent = (difference / 600).clamp(-1.0, 1.0); // -1 to 1 based on screen height

    // Parallax offset for the background/content
    final parallaxOffset = percent * 50.0;

    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);

    // Colors
    final List<Color> colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF3B82F6), // Blue
    ];
    final color = colors[index % colors.length];

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Stack(
        children: [
          // Background with Parallax
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Base Color
                Container(color: const Color(0xFF1E1E24)),
                
                // Parallax Gradient/Shape
                Positioned(
                  top: -50 - parallaxOffset,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.4),
                          color.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50 + parallaxOffset,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Time Column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      start,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      end,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 32),
                
                // Divider
                Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(width: 32),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lecture.subject,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_rounded, color: Colors.white.withOpacity(0.7), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            lecture.teacher.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
