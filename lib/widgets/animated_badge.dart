import 'package:flutter/material.dart';

class AnimatedBadge extends StatefulWidget {
  final Widget badge;

  const AnimatedBadge({required this.badge, Key? key}) : super(key: key);

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge> {
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        opacityLevel = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: const Duration(seconds: 1),
      child: widget.badge,
    );
  }
}
