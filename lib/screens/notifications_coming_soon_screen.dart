import 'package:flutter/material.dart';
import '../core/utils/app_theme.dart';
import '../core/utils/responsive_utils.dart';

class NotificationsComingSoonScreen extends StatefulWidget {
  const NotificationsComingSoonScreen({super.key});

  @override
  State<NotificationsComingSoonScreen> createState() => _NotificationsComingSoonScreenState();
}

class _NotificationsComingSoonScreenState extends State<NotificationsComingSoonScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Float animation for the notification icons
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Rotate animation for the gear icon
    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.buildResponsiveLayout(
      context: context,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main animated icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: ResponsiveUtils.getIconSize(context) * 4,
                      height: ResponsiveUtils.getIconSize(context) * 4,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getIconSize(context) * 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        size: ResponsiveUtils.getIconSize(context) * 2,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context) * 2),
              
              // Title
              Text(
                'Stay Tuned!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getTitleFontSize(context) * 1.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              
              // Subtitle
              Text(
                'Notifications module coming soon',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: ResponsiveUtils.getSubtitleFontSize(context),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context) * 2),
              
              // Feature highlights
              _buildFeatureHighlights(),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context) * 2),
              
              // Animated notification icons
              _buildAnimatedIcons(),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context) * 2),
              
              // Progress indicator
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': Icons.notifications,
        'title': 'Real-time Updates',
        'description': 'Get instant notifications for important events',
      },
      {
        'icon': Icons.settings,
        'title': 'Customizable',
        'description': 'Choose what notifications you want to receive',
      },
      {
        'icon': Icons.schedule,
        'title': 'Smart Scheduling',
        'description': 'Notifications at the right time for you',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return Wrap(
          spacing: ResponsiveUtils.getSpacing(context),
          runSpacing: ResponsiveUtils.getSpacing(context),
          children: features.map((feature) {
            final cardWidth = isSmallScreen
                ? constraints.maxWidth
                : (constraints.maxWidth - ResponsiveUtils.getSpacing(context) * 2) / 3;

            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: AppTheme.primaryColor,
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: ResponsiveUtils.getSmallFontSize(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnimatedIcons() {
    return SizedBox(
      height: ResponsiveUtils.getIconSize(context) * 3,
      child: Stack(
        children: [
          // Floating notification icons
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                left: _floatAnimation.value * 50,
                top: 20,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: ResponsiveUtils.getSmallIconSize(context),
                  ),
                ),
              );
            },
          ),
          
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                right: _floatAnimation.value * 50,
                top: 40,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: ResponsiveUtils.getSmallIconSize(context),
                  ),
                ),
              );
            },
          ),
          
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                left: (1 - _floatAnimation.value) * 60,
                bottom: 20,
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: ResponsiveUtils.getSmallIconSize(context),
                  ),
                ),
              );
            },
          ),
          
          // Rotating gear icon
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Positioned(
                right: 20,
                bottom: 40,
                child: Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) / 2),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: ResponsiveUtils.getSmallIconSize(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          'Development Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        Container(
          width: ResponsiveUtils.isMobile(context) ? 200 : 300,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(4),
          ),
          child: LinearProgressIndicator(
            value: 0.75, // 75% progress
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context) / 2),
        Text(
          '75% Complete',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 