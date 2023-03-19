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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class SliverGridDelegateWithFixedCrossAxisExtent extends SliverGridDelegate {

  const SliverGridDelegateWithFixedCrossAxisExtent({
    @required this.crossAxisCount,
    @required this.mainAxisExtent
  });

  final double mainAxisExtent;
  final int crossAxisCount;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double usableCrossAxisExtent = constraints.crossAxisExtent;
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = mainAxisExtent;

    return new SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent,
      crossAxisStride: childCrossAxisExtent,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedCrossAxisExtent oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount
        || oldDelegate.mainAxisExtent != mainAxisExtent;
  }
}
