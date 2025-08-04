import 'package:flutter/material.dart';
import '../core/widgets/coming_soon_widget.dart';

class HRGoalsScreen extends StatelessWidget {
  const HRGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonWidget(
      title: 'Goals Management',
      subtitle: 'HR Goals & Objectives',
      icon: Icons.flag,
      description: 'Manage and track organizational goals, set objectives for teams and individuals, monitor progress, and align performance with company targets.',
    );
  }
}
