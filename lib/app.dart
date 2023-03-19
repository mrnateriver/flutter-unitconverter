/*
 * Copyright (c) 2016 Evgenii Dobrovidov
 * This file is part of "Unit Converter".
 *
 * "Unit Converter" is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * "Unit Converter" is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with "Unit Converter".  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'strings.dart';
import 'globals.dart';
import 'home.dart';

class ConverterApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ConverterApplicationState();
}

class ConverterApplicationState extends State<ConverterApplication> {
  ConverterStrings _localeData = new ConverterStrings();

  Future<LocaleQueryData> _onLocaleChanged(Locale locale) async {
    setState(() {
      _localeData = new ConverterStrings(language: locale.languageCode);
    });
    return _localeData;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      print("window.locale: ${window.locale.languageCode}");
      return true;
    });

    return new MaterialApp(
      debugShowCheckedModeBanner: false,

      title: _localeData.applicationTitle,
      theme: ConverterGlobals.theme,

      home: new ConverterHome(),

      onLocaleChanged: _onLocaleChanged
    );
  }
}
