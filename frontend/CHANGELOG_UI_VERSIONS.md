# UI Version History

## Version 1: `timetable_carousel_screen.dart`
- Initial implementation of the 3D Carousel.
- Basic lecture details.
- Static attendance placeholder.

## Version 2: `timetable_carousel_screen_v2.dart` (Benchmarked as `timetable_carousel_screen_v2_benchmark.dart`)
- **Advanced Header**: Custom header with live digital clock.
- **Cozy Colors**: Dynamic color system based on lecture status (Active=Orange, Past=Slate, Future=Soft Palette).
- **Intelligent Attendance**:
    - Live simulation of attendance numbers.
    - Detailed breakdown of Present vs Absent.
    - Scrollable list of absentee names.
- **Adaptive Layout**: Uses `Flexible` and `LayoutBuilder` to adjust content density based on screen size.
- **High Visibility**: Increased font sizes for key information (Time, Subject, Attendance Count).

## Version 3: `timetable_carousel_screen_v3.dart` (Current)
- **Auto-Transition**: Automatically scrolls to the next lecture when the current one ends.
- **Enhanced Visuals**:
    - "Next Up" preview glow.
    - Smoother animations.
    - Refined "Glassmorphism" effects.
