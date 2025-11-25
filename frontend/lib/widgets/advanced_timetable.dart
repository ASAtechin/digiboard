import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';
import '../themes/design_system.dart';

class AdvancedTimetable extends StatelessWidget {
  final List<Lecture> lectures;

  const AdvancedTimetable({Key? key, required this.lectures}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lecture = lectures[index];
        return _buildTimetableRow(context, lecture, index);
      },
    );
  }

  Widget _buildTimetableRow(BuildContext context, Lecture lecture, int index) {
    final lectureNumber = index + 1;
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);

    // Determine accent color based on index or subject
    final List<Color> accents = [
      const Color(0xFF818CF8), // Indigo
      const Color(0xFFF472B6), // Pink
      const Color(0xFF34D399), // Emerald
      const Color(0xFFFBBF24), // Amber
      const Color(0xFF60A5FA), // Blue
      const Color(0xFFA78BFA), // Violet
    ];
    final accentColor = accents[index % accents.length];

    // Mock homework if description is empty
    final homework = lecture.description?.isNotEmpty == true
        ? lecture.description!
        : "Review Chapter ${lecture.chapter ?? 'notes'} and complete exercises.";

    // Icon based on subject (simple mapping)
    IconData subjectIcon = Icons.book_rounded;
    final subjectLower = lecture.subject.toLowerCase();
    if (subjectLower.contains('math')) subjectIcon = Icons.calculate_rounded;
    else if (subjectLower.contains('phys')) subjectIcon = Icons.flash_on_rounded;
    else if (subjectLower.contains('chem')) subjectIcon = Icons.science_rounded;
    else if (subjectLower.contains('bio')) subjectIcon = Icons.biotech_rounded;
    else if (subjectLower.contains('comp')) subjectIcon = Icons.computer_rounded;
    else if (subjectLower.contains('eng')) subjectIcon = Icons.menu_book_rounded;
    else if (subjectLower.contains('break')) subjectIcon = Icons.coffee_rounded;

    final isBreak = subjectLower.contains('break') || subjectLower.contains('lunch');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24), // Dark card background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: accentColor, width: 6),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 1. Time Column
            Container(
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    start,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    end,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lec $lectureNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Subject & Teacher
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(subjectIcon, color: accentColor, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lecture.subject,
                            style: const TextStyle(
                              fontSize: 32, // Large visibility
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isBreak) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_rounded, 
                                  color: Colors.white.withOpacity(0.6), 
                                  size: 20
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lecture.teacher.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Homework Section (Hidden for breaks)
            if (!isBreak)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_outlined, 
                            color: accentColor, 
                            size: 18
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HOMEWORK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        homework,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'RECESS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
