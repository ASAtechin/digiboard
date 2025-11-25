import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lecture.dart';

class WeeklyTimetableScreen extends StatefulWidget {
  const WeeklyTimetableScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyTimetableScreen> createState() => _WeeklyTimetableScreenState();
}

class _WeeklyTimetableScreenState extends State<WeeklyTimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Lecture>> _weeklySchedule = {};
  bool _isLoading = true;
  String? _error;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    _fetchWeeklySchedule();
    
    // Set initial tab to current day if possible
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final index = _days.indexOf(dayName);
    if (index != -1) {
      _tabController.index = index;
    }
  }

  Future<void> _fetchWeeklySchedule() async {
    try {
      final schedule = await ApiService.getWeeklySchedule();
      setState(() {
        _weeklySchedule = schedule;
        _isLoading = false;
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Weekly Timetable', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[700],
          indicatorWeight: 3,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : TabBarView(
                  controller: _tabController,
                  children: _days.map((day) {
                    final lectures = _weeklySchedule[day] ?? [];
                    if (lectures.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No lectures on $day', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                          ],
                        ),
                      );
                    }
                    
                    // Sort lectures by time
                    lectures.sort((a, b) => a.startTime.compareTo(b.startTime));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lectures.length,
                      itemBuilder: (context, index) {
                        final lecture = lectures[index];
                        return _buildLectureCard(lecture);
                      },
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    final timeFormat = DateFormat('HH:mm');
    final start = timeFormat.format(lecture.startTime);
    final end = timeFormat.format(lecture.endTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(start, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text(end, style: TextStyle(fontSize: 12, color: Colors.blue[300])),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.subject,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(lecture.teacher.name, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      Icon(Icons.room_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('Room ${lecture.classroom}', style: TextStyle(color: Colors.grey[600])),
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
}
