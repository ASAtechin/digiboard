import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Font Settings Section
                _buildSettingsSection(
                  'Display Settings',
                  [
                    _buildFontSliderCard(fontProvider),
                    const SizedBox(height: 16),
                    _buildFontPreviewCard(fontProvider),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Quick Presets Section
                _buildSettingsSection(
                  'Quick Font Presets',
                  [
                    _buildPresetButtons(fontProvider),
                  ],
                ),
                const SizedBox(height: 24),
                
                // App Information Section
                _buildSettingsSection(
                  'About',
                  [
                    _buildInfoCard(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFontSliderCard(FontProvider fontProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.text_fields,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fontProvider.fontSizeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Font Size Slider
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
                  thumbColor: const Color(0xFF1E3A8A),
                  overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: fontProvider.fontScale,
                  min: 0.8,
                  max: 1.5,
                  divisions: 14,
                  onChanged: (value) {
                    fontProvider.setFontScale(value);
                  },
                ),
              ),
              
              // Scale Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Small',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Large',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Extra',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Text(
            'Adjust the font size to improve readability. This will affect all text throughout the app.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontPreviewCard(FontProvider fontProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.preview,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sample lecture card preview
          Container(
            padding: EdgeInsets.all(fontProvider.basePadding),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 60 * fontProvider.fontScale,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6 * fontProvider.fontScale,
                    vertical: 8 * fontProvider.fontScale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '09:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontProvider.timeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      Text(
                        '10:30',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontProvider.timeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: fontProvider.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Structures & Algorithms',
                        style: TextStyle(
                          fontSize: fontProvider.subjectFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E3A8A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: fontProvider.smallPadding / 2),
                      Text(
                        'Dr. Sarah Johnson • Room 206',
                        style: TextStyle(
                          fontSize: fontProvider.bodyFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons(FontProvider fontProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Presets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  'Small',
                  '80%',
                  fontProvider.fontScale == 0.8,
                  () => fontProvider.setSmallFont(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  'Normal',
                  '100%',
                  fontProvider.fontScale == 1.0,
                  () => fontProvider.setNormalFont(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  'Large',
                  '120%',
                  fontProvider.fontScale == 1.2,
                  () => fontProvider.setLargeFont(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  'Extra',
                  '150%',
                  fontProvider.fontScale == 1.5,
                  () => fontProvider.setExtraLargeFont(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, String percentage, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF3B82F6) 
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? null 
              : Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'About DigiBoard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'DigiBoard v1.0.0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A modern digital lecture schedule board for educational institutions.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
