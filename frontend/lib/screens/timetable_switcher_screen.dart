import 'package:flutter/material.dart';
import 'timetable_carousel_screen.dart';
import 'timetable_carousel_screen_v2.dart';
import 'timetable_carousel_screen_v3.dart';
import 'home_screen_ui1.dart' as split_view;

class TimetableSwitcherScreen extends StatefulWidget {
  const TimetableSwitcherScreen({Key? key}) : super(key: key);

  @override
  State<TimetableSwitcherScreen> createState() => _TimetableSwitcherScreenState();
}

class _TimetableSwitcherScreenState extends State<TimetableSwitcherScreen> {
  // Default to the latest version
  String _selectedVersion = 'V3';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Active Screen (Background)
        _buildActiveScreen(),

        // The Switcher Control (Floating Overlay)
        Positioned(
          top: 50,
          right: 180, // Positioned to the left of the clock (approx)
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_carousel_rounded, color: Colors.blueAccent.shade100, size: 16),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVersion,
                      dropdownColor: const Color(0xFF0F172A),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 18),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                      ),
                      items: [
                        _buildMenuItem('V1', 'Legacy View'),
                        _buildMenuItem('V2', 'Stable View'),
                        _buildMenuItem('V3', 'Auto-Pilot View'),
                        _buildMenuItem('Split', 'Dashboard View'),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVersion = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildMenuItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Text(value, style: TextStyle(color: Colors.blueAccent.shade100, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActiveScreen() {
    // Key is important to force rebuild when switching versions
    switch (_selectedVersion) {
      case 'V1':
        return const TimetableCarouselScreen(key: ValueKey('V1'));
      case 'V2':
        return const TimetableCarouselScreenV2(key: ValueKey('V2'));
      case 'Split':
        return const split_view.HomeScreen(key: ValueKey('Split'));
      case 'V3':
      default:
        return const TimetableCarouselScreenV3(key: ValueKey('V3'));
    }
  }
}
