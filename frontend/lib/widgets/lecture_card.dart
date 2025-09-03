import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lecture.dart';

class LectureCard extends StatelessWidget {
  final Lecture lecture;

  const LectureCard({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _getLectureTypeColor(lecture.lectureType),
              _getLectureTypeColor(lecture.lectureType).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lecture.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lecture.lectureType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (lecture.chapter != null && lecture.chapter!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.book_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lecture.chapter!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Row(
                children: [
                  _buildInfoItem(
                    Icons.access_time,
                    lecture.timeRange,
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    Icons.location_on_outlined,
                    lecture.classroom,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildInfoItem(
                    Icons.calendar_today_outlined,
                    lecture.dayOfWeek,
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    Icons.school_outlined,
                    lecture.course,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getLectureTypeColor(String type) {
    switch (type) {
      case 'Lab':
        return const Color(0xFFEA580C); // Orange
      case 'Tutorial':
        return const Color(0xFF059669); // Green
      case 'Seminar':
        return const Color(0xFF7C3AED); // Purple
      default:
        return const Color(0xFF1E3A8A); // Blue
    }
  }
}
