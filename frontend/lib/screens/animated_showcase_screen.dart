import 'package:flutter/material.dart';
import '../themes/design_system.dart';
import '../widgets/animated_box_frames.dart';

/// AnimatedShowcase Screen
/// Demonstrates all animated box frames and components with Google-inspired animations
class AnimatedShowcaseScreen extends StatelessWidget {
  const AnimatedShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.surfaceLight,
      appBar: AppBar(
        title: Text(
          'DigiBoard Animated Components',
          style: DesignSystem.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: DesignSystem.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Animated Box Frames
              _buildSection(
                title: '✨ Animated Box Frames',
                description: 'Color-changing frames with smooth transitions',
                child: Column(
                  children: [
                    AnimatedBoxFrame(
                      title: '🎯 Next Lecture',
                      subtitle: 'Auto-rotating color theme',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Introduction to Programming',
                            style: DesignSystem.displaySmall.copyWith(
                              color: DesignSystem.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: DesignSystem.spacing2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: DesignSystem.primary,
                                size: DesignSystem.iconSizeLarge,
                              ),
                              SizedBox(width: DesignSystem.spacing2),
                              Text(
                                'Room A101 • 09:00 - 10:30',
                                style: DesignSystem.bodyLarge.copyWith(
                                  color: DesignSystem.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing3),
                    AnimatedBoxFrame(
                      title: '📚 Featured Subject',
                      subtitle: 'Rotating color highlights',
                      colors: [
                        Colors.deepOrange,
                        Colors.purple,
                        Colors.cyan,
                      ],
                      child: Text(
                        'This frame cycles through custom colors: Orange → Purple → Cyan',
                        style: DesignSystem.bodyLarge.copyWith(
                          color: DesignSystem.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),

              // Section 2: Animated Color Grid
              _buildSection(
                title: '🎨 Animated Color Grid',
                description: 'Interactive grid with bouncing animations and icons',
                child: AnimatedColorGrid(
                  items: [
                    AnimatedGridItem(
                      title: 'Lectures',
                      subtitle: '12 classes',
                      icon: Icons.class_rounded,
                      color: DesignSystem.primary,
                      onTap: () => _showSnackbar(context, 'Lectures tapped!'),
                    ),
                    AnimatedGridItem(
                      title: 'Teachers',
                      subtitle: '8 faculty',
                      icon: Icons.people_rounded,
                      color: DesignSystem.secondary,
                      onTap: () => _showSnackbar(context, 'Teachers tapped!'),
                    ),
                    AnimatedGridItem(
                      title: 'Rooms',
                      subtitle: '15 locations',
                      icon: Icons.location_on_rounded,
                      color: DesignSystem.tertiary,
                      onTap: () => _showSnackbar(context, 'Rooms tapped!'),
                    ),
                    AnimatedGridItem(
                      title: 'Schedule',
                      subtitle: 'Full week view',
                      icon: Icons.calendar_month_rounded,
                      color: DesignSystem.success,
                      onTap: () => _showSnackbar(context, 'Schedule tapped!'),
                    ),
                  ],
                  crossAxisCount: 2,
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),

              // Section 3: Animated Card Stack
              _buildSection(
                title: '🃏 Animated Card Stack',
                description: 'Slide-in card transitions with staggered animations',
                child: AnimatedCardStack(
                  cards: [
                    StackedCard(
                      title: 'Welcome',
                      description:
                          'Experience DigiBoard with amazing animated components inspired by Google\'s design language.',
                      icon: Icons.auto_awesome_rounded,
                      color: DesignSystem.primary,
                    ),
                    StackedCard(
                      title: 'Smooth Transitions',
                      description:
                          'Watch as cards slide, bounce, and rotate with carefully tuned animations.',
                      icon: Icons.animation_rounded,
                      color: DesignSystem.secondary,
                    ),
                    StackedCard(
                      title: 'Professional UI',
                      description:
                          'Built with Material Design 3 and WCAG AAA accessibility standards.',
                      icon: Icons.grade_rounded,
                      color: DesignSystem.tertiary,
                    ),
                  ],
                  autoRotateInterval: const Duration(seconds: 4),
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),

              // Section 4: Feature Cards
              _buildSection(
                title: '⭐ Animated Feature Cards',
                description: 'Individual feature highlights with hover effects',
                child: Column(
                  children: [
                    AnimatedFeatureCard(
                      title: 'Real-time Updates',
                      description:
                          'Live data synced from backend with smooth animations.',
                      icon: Icons.refresh_rounded,
                      color: DesignSystem.primary,
                      onTap: () =>
                          _showSnackbar(context, 'Real-time Updates selected!'),
                    ),
                    SizedBox(height: DesignSystem.spacing3),
                    AnimatedFeatureCard(
                      title: 'Responsive Design',
                      description:
                          'Perfect on all screen sizes from mobile to 4K displays.',
                      icon: Icons.devices_rounded,
                      color: DesignSystem.secondary,
                      onTap: () =>
                          _showSnackbar(context, 'Responsive Design selected!'),
                    ),
                    SizedBox(height: DesignSystem.spacing3),
                    AnimatedFeatureCard(
                      title: 'Accessible UI',
                      description:
                          'WCAG AAA compliant with high contrast colors.',
                      icon: Icons.accessibility_rounded,
                      color: DesignSystem.tertiary,
                      onTap: () =>
                          _showSnackbar(context, 'Accessible UI selected!'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),

              // Section 5: Info Box
              Container(
                padding: EdgeInsets.all(DesignSystem.paddingLarge),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(DesignSystem.cornerRadiusLarge),
                  border: Border.all(
                    color: DesignSystem.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Animation Details',
                      style: DesignSystem.headlineSmall.copyWith(
                        color: DesignSystem.primary,
                      ),
                    ),
                    SizedBox(height: DesignSystem.spacing2),
                    Text(
                      '• Color transitions: Smooth interpolation between colors\n'
                      '• Bouncing effect: Staggered animations with physics-based motion\n'
                      '• Card stack: Slide-in and stack transitions\n'
                      '• Auto-rotate: Seamless cycling through components\n'
                      '• Hover effects: Responsive to user interaction\n'
                      '• All animations: Material Design timing (200-400ms)',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignSystem.spacing4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DesignSystem.headlineLarge.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: DesignSystem.spacing1),
        Text(
          description,
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
        SizedBox(height: DesignSystem.spacing3),
        child,
      ],
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(DesignSystem.spacing2),
      ),
    );
  }
}
