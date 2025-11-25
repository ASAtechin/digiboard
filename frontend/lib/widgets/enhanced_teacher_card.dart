import 'package:flutter/material.dart';
import '../models/teacher.dart';
import 'common_widgets.dart';

/// Enhanced teacher profile card
class EnhancedTeacherCard extends StatefulWidget {
  final Teacher teacher;
  final bool expandable;
  final VoidCallback? onContactTap;

  const EnhancedTeacherCard({
    super.key,
    required this.teacher,
    this.expandable = true,
    this.onContactTap,
  });

  @override
  State<EnhancedTeacherCard> createState() => _EnhancedTeacherCardState();
}

class _EnhancedTeacherCardState extends State<EnhancedTeacherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.expandable) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.8),
                            const Color(0xFF1E3A8A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.teacher.name
                              .split(' ')
                              .map((n) => n[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Name and department
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.teacher.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.teacher.department,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Expand button
                    if (widget.expandable)
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 0.5)
                            .animate(_animationController),
                        child: Icon(
                          Icons.expand_more,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Expanded content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isExpanded
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Experience
                            if (widget.teacher.experience > 0) ...[
                              InfoTile(
                                icon: Icons.school,
                                label: 'Experience',
                                value:
                                    '${widget.teacher.experience} years',
                                iconColor: const Color(0xFF3B82F6),
                              ),
                              Divider(color: Colors.grey.shade200),
                            ],
                            
                            // Office
                            if (widget.teacher.office != null &&
                                widget.teacher.office!.isNotEmpty) ...[
                              InfoTile(
                                icon: Icons.location_on,
                                label: 'Office',
                                value: widget.teacher.office!,
                                iconColor: Colors.red,
                              ),
                              Divider(color: Colors.grey.shade200),
                            ],
                            
                            // Phone
                            if (widget.teacher.phone != null &&
                                widget.teacher.phone!.isNotEmpty) ...[
                              InfoTile(
                                icon: Icons.phone,
                                label: 'Phone',
                                value: widget.teacher.phone!,
                                iconColor: Colors.green,
                                isClickable: true,
                                onTap: widget.onContactTap,
                              ),
                              Divider(color: Colors.grey.shade200),
                            ],
                            
                            // Email
                            if (widget.teacher.email.isNotEmpty) ...[
                              InfoTile(
                                icon: Icons.email,
                                label: 'Email',
                                value: widget.teacher.email,
                                iconColor: Colors.orange,
                                isClickable: true,
                                onTap: widget.onContactTap,
                              ),
                              Divider(color: Colors.grey.shade200),
                            ],
                            
                            // Qualifications
                            if (widget.teacher.qualifications != null &&
                                widget.teacher.qualifications!.isNotEmpty) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 20,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Qualifications',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...widget.teacher.qualifications!
                                      .map((qual) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 32,
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        Color(0xFF3B82F6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    qual,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
