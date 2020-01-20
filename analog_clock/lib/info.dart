import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Info extends StatelessWidget {
  final String temperature;
  final String temperatureRange;
  final String condition;
  final String location;
  final double animValue;
  final Color textColor;
  final Color textSelectedColor;

  const Info({
    @required this.temperature,
    @required this.temperatureRange,
    @required this.condition,
    @required this.location,
    @required this.animValue,
    @required this.textColor,
    @required this.textSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    String day = DateFormat.EEEE().format(time);
    String date = DateFormat.d().format(time);
    String month = DateFormat.MMMM().format(time);
    String year = DateFormat.y().format(time);

    return Container(
      //color: ,
      child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(
                flex: 2,
                child: Text(
                  date,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 72.0,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                )),
            Flexible(
                flex: 1,
                child: Text(
                  month + ' ' + year,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                )),
            SizedBox(height: 8),
            Flexible(
                flex: 1,
                child: Text(
                  'POSITIVE ' + day.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: textSelectedColor),
                )),
            SizedBox(height: 8),
            Flexible(
                flex: 1,
                child: Text(
                  temperature,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                )),
            Flexible(
                flex: 1,
                child: Text(
                  location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: textColor),
                )),
            Expanded(
                flex: 2,
                child: CustomPaint(
                  painter:
                      WeatherPainter(id: 1, time: time, animValue: animValue),
                  size: Size(100, 100), // todo: how to make it expand?
                )),
          ]),
    );
  }
}

class WeatherPainter extends CustomPainter {
  final int id; // weather id
  final DateTime time;
  final double animValue; // [0.0, 1.0]

  const WeatherPainter({
    @required this.id,
    @required this.time,
    @required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //print(size);
    double width = size.width;
    double height = size.height;
    Offset center = Offset(width / 2, height / 2);

    switch (id) {
      case 1:
      default:
        drawRain(canvas, center, width, height);
        break;
    }
  }

  void drawRain(Canvas canvas, Offset center, double width, double height) {
    Paint p = Paint();
    p.style = PaintingStyle.stroke;
    p.color = Colors.blue[100];
    p.strokeCap = StrokeCap.round;

    canvas.clipRect(
        Rect.fromCenter(center: center, width: width, height: height));

    //print(animValue);
    // hardcoded "random" rain point
    double w = width / 10; // width "unit"
    int N = 5;

    canvas.save();
    canvas.rotate(pi * 0.02);
    canvas.translate(0, animValue * height);

    // draw thick rain lines
    List<double> kh = [
      0.35,
      0.25,
      0.35,
      0.25,
      0.5
    ]; // line length ( % of screen height )
    List<double> kdh = [
      0.0,
      0.75,
      0.5,
      -0.1,
      0.5
    ]; // line offscreen offset ( % of line length )
    p.strokeWidth = 2.0;
    double h, dh, dw = 0;
    for (int i = 0; i < N; i++) {
      h = height * kh[i]; // line length
      dh = h * kdh[i]; // line offscreen offset
      canvas.drawLine(Offset(w * (2 * i + 1) - dw, -dh),
          Offset(w * (2 * i + 1) - dw, -dh + h), p);
      canvas.drawLine(Offset(w * (2 * i + 1) - dw, -height - dh),
          Offset(w * (2 * i + 1) - dw, -height - dh + h), p);
    }

    // draw thin rain lines
    kh = [
      0.35,
      0.15,
      0.20,
      0.55,
      0.3
    ]; // size of rain lines ( % of screen size )
    kdh = [-1.0, 1.75, -1.5, 1.1, 1.5]; // rain line offset ( % of line length )
    p.strokeWidth = 1.0;
    dw = w / 2;
    canvas.translate(0, animValue * height);
    for (int i = 0; i < N; i++) {
      h = height * kh[i];
      dh = h * kdh[i];
      canvas.drawLine(Offset(w * (2 * i + 1) - dw, -dh),
          Offset(w * (2 * i + 1) - dw, -dh + h), p);
      canvas.drawLine(Offset(w * (2 * i + 1) - dw, -height - dh),
          Offset(w * (2 * i + 1) - dw, -height - dh + h), p);
    }

    canvas.restore();

    // splashes imitation

    // draw ovals (3:1)
    double cx, cy;
    double dr = w * 0.4; // radius "step"
    double maxRadius = w;
    kh = [0.0, 1.0, 0.3, 0.7, 0.8]; // offset from the bottom to randomize 'y'
    for (int i = 0; i < N; i++) {
      // center
      cx = (2 * i + 1) * w -
          dw; // use -dw to compensate canvas rotation and lines angle
      cy = height - w * kh[i];

      var r = dr * animValue; // start radius
      while (r < maxRadius) {
//          canvas.drawCircle(Offset(cx, cy), r, p);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 3.0, height: r),
            p); // oval (3:1)
        r += dr;
      }
    }
  }

  @override
  bool shouldRepaint(WeatherPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.time != time ||
        oldDelegate.id != id;
  }
}
