import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParadeProgressBar extends StatelessWidget {
  final int currentStep; // 0-based index

  ParadeProgressBar({required this.currentStep});

  final List<Map<String, String>> steps = const [
    {
      "bw": "assets/envelope-heart-bw_Version2.svg",
      "color": "assets/envelope-heart-color_Version2.svg",
    },
    {
      "bw": "assets/smiley-bw_Version2.svg",
      "color": "assets/smiley-color_Version2.svg",
    },
    {
      "bw": "assets/calendar-bw_Version2.svg",
      "color": "assets/calendar-color_Version2.svg",
    },
    {
      "bw": "assets/checklist-bw_Version2.svg",
      "color": "assets/checklist-color_Version2.svg",
    },
    {
      "bw": "assets/paperplane-bw_Version2.svg",
      "color": "assets/paperplane-color_Version2.svg",
    },
  ];

  // Arc heights for each icon [start, mid-high, bottom, mid-high, end]
  static const List<double> arcHeights = [
    0.0, 0.18, 0.33, 0.18, 0.0
  ];

  @override
  Widget build(BuildContext context) {
    const double paradeWidth = 350;
    const double paradeHeight = 160;
    const double iconSize = 56;
    final int iconCount = steps.length;

    final double startX = iconSize / 2;
    final double usableWidth = paradeWidth - iconSize;

    // Calculate even X positions with padding
    final List<double> xPositions = List.generate(
      iconCount,
      (i) => startX + (usableWidth * (i / (iconCount - 1))),
    );

    // Calculate Y positions for arc effect
    final List<double> yPositions = List.generate(
      iconCount,
      (i) => paradeHeight * arcHeights[i],
    );

    return SizedBox(
      width: paradeWidth,
      height: paradeHeight,
      child: Stack(
        children: [
          // Draw connecting lines
          CustomPaint(
            size: const Size(paradeWidth, paradeHeight),
            painter: _ParadeLinePainter(
              xPositions: xPositions,
              yPositions: yPositions,
              highlightTo: currentStep,
            ),
          ),
          // Draw icons
          ...List.generate(iconCount, (i) {
            final assetPath = (i <= currentStep)
                ? steps[i]['color']!
                : steps[i]['bw']!;
            return Positioned(
              left: xPositions[i] - iconSize / 2,
              top: yPositions[i],
              child: SvgPicture.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ParadeLinePainter extends CustomPainter {
  final List<double> xPositions;
  final List<double> yPositions;
  final int highlightTo;

  _ParadeLinePainter({
    required this.xPositions,
    required this.yPositions,
    required this.highlightTo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < xPositions.length - 1; i++) {
      final start = Offset(xPositions[i], yPositions[i] + 28);
      final end = Offset(xPositions[i + 1], yPositions[i + 1] + 28);
      canvas.drawLine(start, end, paintWhite);
    }
  }

  @override
  bool shouldRepaint(_ParadeLinePainter oldDelegate) =>
      oldDelegate.highlightTo != highlightTo;
}