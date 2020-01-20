// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analog_clock/info.dart';
import 'package:analog_clock/umbrella_clock.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  text_selected,
  clock_outline,
  clock_fill,
  clock_hand,
  clock_digit,
  clock_sector
}

final _lightTheme = {
  _Element.background: Color(0xff8a6799),
  _Element.text: Color(0xffee919c),
  _Element.text_selected: Color(0xffffffff),
  _Element.clock_outline: Color(0xffff2754),
  _Element.clock_fill: Color(0x7fff2754),
  _Element.clock_hand: Color(0xff352d41),
  _Element.clock_digit: Color(0xffffffff),
};

final _darkTheme = {
  _Element.background: Color(0xff3a144d),
  _Element.text: Color(0xffcdcdcd),
  _Element.text_selected: Color(0xffffffff),
  _Element.clock_outline: Color(0xffec2965),
  _Element.clock_fill: Color(0x7fec2965),
  _Element.clock_hand: Color(0xff1b1b1b),
  _Element.clock_digit: Color(0xffdc9ffe),
};

// A basic analog clock for Flutter Clock Challenge 2020

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  Animation<double> _animation;
  AnimationController controller;
  double animValue;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
    _createController();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  void _createController() {
    controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //controller.reverse();
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    final time = DateFormat.Hms().format(DateTime.now());

    _animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          animValue = _animation.value;
        });
      });

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
          color: Colors.black, // ~ smart clock physical frame color
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100.0),
              color: colors[_Element.background],
            ),
            child: Row(
              children: <Widget>[
                // device ratio 5:3 => 3x3 clock, 2x3 info
                Flexible(
                  flex: 3,
                  child: Container(
                      child: UmbrellaClock(
                    hour: _now.hour,
                    min: _now.minute,
                    second: _now.second,
                    animValue: animValue,
                    outlineColor: colors[_Element.clock_outline],
                    fillColor: colors[_Element.clock_fill],
                    handColor: colors[_Element.clock_hand],
                    digitColor: colors[_Element.clock_digit],
                  )),
                ),
                Expanded(
                  flex: 2,
                  child: Info(
                    temperature: _temperature,
                    temperatureRange: _temperatureRange,
                    condition: _condition,
                    location: _location,
                    animValue: animValue,
                    textColor: colors[_Element.text],
                    textSelectedColor: colors[_Element.text_selected],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
