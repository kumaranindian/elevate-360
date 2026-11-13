import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand mark: growth arrow breaking out of a 360° ring.
/// Source artwork lives in assets/images/app_logo.svg.
const String _logoAsset = 'assets/images/app_logo.svg';

class _LogoMark extends StatelessWidget {
  final double size;
  final double glowBlur;
  final double glowOffset;
  final double glowSpread;

  const _LogoMark({
    required this.size,
    required this.glowBlur,
    required this.glowOffset,
    required this.glowSpread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Matches the artwork's corner radius (224 / 1024).
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            blurRadius: glowBlur,
            offset: Offset(0, glowOffset),
            spreadRadius: glowSpread,
          ),
        ],
      ),
      child: SvgPicture.asset(
        _logoAsset,
        width: size,
        height: size,
        semanticsLabel: 'Elevate 360 logo',
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 40,
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoMark(size: size, glowBlur: 12, glowOffset: 4, glowSpread: 2),
        if (showText) ...[
          SizedBox(width: size * 0.3),
          Text(
            'Elevate 360',
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class AppLogoSmall extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogoSmall({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _LogoMark(size: size, glowBlur: 8, glowOffset: 3, glowSpread: 1);
  }
}
