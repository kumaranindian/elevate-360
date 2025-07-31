import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1400;

  // Screen size helpers
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < mobileBreakpoint;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= mobileBreakpoint && 
      MediaQuery.of(context).size.width < tabletBreakpoint;
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= tabletBreakpoint;
  
  static bool isLargeDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // Responsive spacing
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    if (isLargeDesktop(context)) return 48.0;
    return 32.0; // Desktop
  }

  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 16.0;
    if (isLargeDesktop(context)) return 24.0;
    return 20.0; // Desktop
  }

  static double getSectionSpacing(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 24.0;
    if (isLargeDesktop(context)) return 32.0;
    return 28.0; // Desktop
  }

  // Responsive max widths for content
  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 900;
    if (isLargeDesktop(context)) return 1400;
    return 1200; // Desktop
  }

  // Responsive grid configurations
  static int getGridCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isMobile(context)) return mobile ?? 1;
    if (isTablet(context)) return tablet ?? 2;
    return desktop ?? 3;
  }

  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 24.0;
    if (isLargeDesktop(context)) return 32.0;
    return 28.0; // Desktop
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 18.0;
    if (isLargeDesktop(context)) return 22.0;
    return 20.0; // Desktop
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) return 14.0;
    if (isTablet(context)) return 15.0;
    if (isLargeDesktop(context)) return 17.0;
    return 16.0; // Desktop
  }

  static double getSmallFontSize(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 13.0;
    if (isLargeDesktop(context)) return 15.0;
    return 14.0; // Desktop
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 24.0;
    if (isLargeDesktop(context)) return 32.0;
    return 28.0; // Desktop
  }

  static double getSmallIconSize(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 18.0;
    if (isLargeDesktop(context)) return 24.0;
    return 20.0; // Desktop
  }

  // Responsive button sizes
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 44.0;
    if (isTablet(context)) return 48.0;
    if (isLargeDesktop(context)) return 56.0;
    return 52.0; // Desktop
  }

  static EdgeInsets getButtonPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    if (isLargeDesktop(context)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 22, vertical: 15); // Desktop
  }

  // Responsive card configurations
  static double getCardPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 20.0;
    if (isLargeDesktop(context)) return 28.0;
    return 24.0; // Desktop
  }

  static double getCardBorderRadius(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 10.0;
    if (isLargeDesktop(context)) return 14.0;
    return 12.0; // Desktop
  }

  // Responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isTablet(context)) return 220.0;
    if (isLargeDesktop(context)) return 280.0;
    return 250.0; // Desktop
  }

  // Responsive content layout
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    return SingleChildScrollView(
      padding: padding ?? EdgeInsets.all(getPadding(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? getMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }

  // Responsive section builder
  static Widget buildResponsiveSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: EdgeInsets.all(padding?.left ?? getCardPadding(context)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(getCardBorderRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: getSmallIconSize(context),
              ),
              SizedBox(width: getSpacing(context) / 2),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: getSpacing(context)),
          ...children,
        ],
      ),
    );
  }

  // Responsive info row builder
  static Widget buildResponsiveInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isEditable = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getSpacing(context) / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile(context) ? 80 : 120,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: getSmallFontSize(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: getSpacing(context)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: getBodyFontSize(context),
              ),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: getSpacing(context)),
            trailing,
          ],
        ],
      ),
    );
  }
} 