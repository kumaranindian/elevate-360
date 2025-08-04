import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_utils.dart';

class ComingSoonWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  const ComingSoonWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
            Color(0xFF415A77),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              
              // Description
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              
              // Coming Soon Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.8),
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSectionSpacing(context)),
              
              // Additional Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'This feature is under development and will be available in a future update.',
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontSize: ResponsiveUtils.getSmallFontSize(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
