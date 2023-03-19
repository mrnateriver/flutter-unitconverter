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
 
import 'package:meta/meta.dart' show required;
import 'package:flutter/widgets.dart';
import 'data.dart';

class ConverterStrings extends LocaleQueryData {

  static ConverterStrings of(BuildContext context) {
    var result = LocaleQuery.of(context);
    return result;
  }

  final language;

  ConverterStrings({this.language = "en"});

  String getString(@required String key, {language}) {
    final String requestedLanguage = language ?? this.language;
    return key == null ? null : 
    (applicationStrings.containsKey(key) ? 
      (applicationStrings[key][requestedLanguage] ?? applicationStrings[key]["en"]) : key);
  }

  String get applicationTitle {
    return getString(StringKey.applicationTitle);
  }

  String get unitValueInputLabel {
    return getString(StringKey.unitValueInputLabel);
  }

}
