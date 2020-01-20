import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

class UmbrellaClock extends StatelessWidget {
  final int hour;
  final int min;
  final int second;

  final double animValue;

  final Color outlineColor; // ? collection
  final Color fillColor;
  final Color handColor;
  final Color digitColor;

  const UmbrellaClock({
    @required this.hour,
    @required this.min,
    @required this.second,
    @required this.animValue,
    @required this.outlineColor,
    @required this.fillColor,
    @required this.handColor,
    @required this.digitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: UmbrellaClockPainter(
            hour: hour,
            min: min,
            second: second,
            outlineColor: outlineColor,
            fillColor: fillColor,
            handColor: handColor,
            digitColor: digitColor,
          ),
        ),
      ),
    );
  }
}

// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

// Total distance traveled by a second or a minute hand, each second or minute, respectively.
final radiansPerTick = radians(360 / 60);

class UmbrellaClockPainter extends CustomPainter {
  final int hour;
  final int min;
  final int second;
  final double animValue; // [0.0, 1.0]
  final Color outlineColor; // ? collection
  final Color fillColor;
  final Color handColor;
  final Color digitColor;

  const UmbrellaClockPainter({
    @required this.hour,
    @required this.min,
    @required this.second,
    @required this.animValue,
    @required this.outlineColor,
    @required this.fillColor,
    @required this.handColor,
    @required this.digitColor,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
//    print(size);
    num side = size.shortestSide;
    Offset center = Offset(side / 2, side / 2);
    int padding = (side ~/ 7);
    double radius = side / 2 - padding;

    // calculate points on the clock circle
    int N = 12;
    List<double> x = List(N);
    List<double> y = List(N);
    List<double> angles = List(N);
    Path path = Path(); // clock outline
    for (int i = 0; i < N; i++) {
      angles[i] = -pi / 2 + 2 * i * pi / N;
      x[i] = radius * cos(angles[i]) + center.dx;
      y[i] = radius * sin(angles[i]) + center.dy;
      if (i == 0)
        path.moveTo(x[i], y[i]);
      else
        path.lineTo(x[i], y[i]);
    }
    path.close();

    // draw sector lines
    var paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    List<Color> colors = List<Color>();
    colors.add(outlineColor);
    colors.add(Color(outlineColor.value & 0x01FFFFFF));
    Gradient g = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.center, colors: colors);

    for (int i = 0; i < N; i++) {
      double cx = 3 * cos(angles[i]) + center.dx;
      double cy = 3 * sin(angles[i]) + center.dy;
      Rect r = Rect.fromLTRB(x[i], y[i], cx, cy);
      paint.shader = g.createShader(r);
      canvas.drawLine(Offset(x[i], y[i]), Offset(cx, cy), paint);
    }

    // draw outline
    paint.shader = null;
    canvas.drawPath(path, paint);

    // fill in clock area
    paint.color = fillColor;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // hour
    paint.color = handColor;
    drawHand((hour % 12) * radiansPerHour + (min / 60) * radiansPerHour,
        radius / 2, center, paint, canvas);
    // min
    drawHand(min * radiansPerTick, radius * 3 / 4, center, paint, canvas);
    // center
    canvas.drawCircle(center, 8.0, paint);
    // second
    drawSecond(radius, center, paint, canvas);

    // draw sector circles and digits
    for (int i = 0; i < N; i++) {
      paint.color = outlineColor;
      canvas.drawCircle(Offset(x[i], y[i]), 5.0, paint);
      paint.color = digitColor;
      drawDigit(i == 0 ? 12 : i, radius, angles[i], center, digitColor, canvas);
    }
  }

  void drawSecond(double radius, Offset center, Paint p, Canvas canvas) {
    double alpha = second / 60.0 * 2 * pi - pi / 2;
    double x = (radius - 15) * cos(alpha) + center.dx;
    double y = (radius - 15) * sin(alpha) + center.dy;
    canvas.drawCircle(Offset(x, y), 5.0, p);
    p.strokeWidth = 0.5;
    canvas.drawLine(center, Offset(x, y), p);
  }

  void drawHand(
      double angle, double len, Offset center, Paint p, Canvas canvas) {
    double alpha = angle - pi / 2;
    double x = len * cos(alpha) + center.dx;
    double y = len * sin(alpha) + center.dy;
    canvas.drawLine(center, Offset(x, y), p);
  }

  void drawDigit(int digit, double radius, double angle, Offset center,
      Color color, Canvas canvas) {
    ui.ParagraphBuilder b = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        //textDirection: TextDirection.ltr,
        maxLines: 1,
        //fontFamily: 'Raleway',
        //fontSize: 16.0,
        height: 1.0,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        //strutStyle: null,
        //ellipsis: '..',
        //locale: Locale.cachedLocale,
      ),
    );
    b.pushStyle(ui.TextStyle(color: color, fontSize: 20.0));
    b.addText(digit.toString());
    ui.Paragraph p = b.build();
    p.layout(ui.ParagraphConstraints(width: 25));
    double x = (radius + 20) * cos(angle) + center.dx;
    double y = (radius + 20) * sin(angle) + center.dy;
    Offset offset = Offset(x - p.width / 2, y - p.height / 2);
    canvas.drawParagraph(p, offset);
  }

  @override
  bool shouldRepaint(UmbrellaClockPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.min != min ||
        oldDelegate.second != second;
  }
}
