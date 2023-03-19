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
 
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class PersistentAppBarDelegate extends SliverPersistentHeaderDelegate {

  PersistentAppBarDelegate({
    @required this.leading,
    @required this.title,
    @required this.actions,
    @required this.flexibleSpace,
    @required this.bottom,
    @required this.elevation,
    @required this.forceElevated,
    @required this.backgroundColor,
    @required this.brightness,
    @required this.iconTheme,
    @required this.textTheme,
    @required this.primary,
    @required this.centerTitle,
    @required this.expandedHeight,
    @required this.collapsedHeight,
    @required this.topPadding,
    @required this.pinned
  }) : _bottomHeight = bottom?.preferredSize?.height ?? 0.0 {
    assert(primary || topPadding == 0.0);
  }

  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final double elevation;
  final bool forceElevated;
  final Color backgroundColor;
  final Brightness brightness;
  final IconThemeData iconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double expandedHeight;
  final double collapsedHeight;
  final double topPadding;
  final bool pinned;

  final double _bottomHeight;

  @override
  double get minExtent => collapsedHeight ?? (topPadding + kToolbarHeight + _bottomHeight);

  @override
  double get maxExtent => math.max(topPadding + (expandedHeight ?? kToolbarHeight + _bottomHeight), minExtent);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double visibleMainHeight = maxExtent - shrinkOffset - topPadding;
    final double toolbarOpacity = pinned ? 1.0 : ((visibleMainHeight - _bottomHeight) / kToolbarHeight).clamp(0.0, 1.0);

    final Widget appBar = FlexibleSpaceBar.createSettings(
      minExtent: minExtent,
      maxExtent: maxExtent,
      currentExtent: math.max(minExtent, maxExtent - shrinkOffset),
      toolbarOpacity: toolbarOpacity,
      child: new AppBar(
        leading: leading,
        title: title,
        actions: actions,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        elevation: forceElevated || overlapsContent || (pinned && shrinkOffset > maxExtent - minExtent) ? elevation ?? 4.0 : 0.0,
        backgroundColor: backgroundColor,
        brightness: brightness,
        iconTheme: iconTheme,
        textTheme: textTheme,
        primary: primary,
        centerTitle: centerTitle,
        toolbarOpacity: toolbarOpacity,
        bottomOpacity: pinned ? 1.0 : (visibleMainHeight / _bottomHeight).clamp(0.0, 1.0),
      ),
    );
    return appBar;
  }

  @override
  bool shouldRebuild(covariant PersistentAppBarDelegate oldDelegate) {
    return leading != oldDelegate.leading
        || title != oldDelegate.title
        || actions != oldDelegate.actions
        || flexibleSpace != oldDelegate.flexibleSpace
        || bottom != oldDelegate.bottom
        || _bottomHeight != oldDelegate._bottomHeight
        || elevation != oldDelegate.elevation
        || backgroundColor != oldDelegate.backgroundColor
        || brightness != oldDelegate.brightness
        || iconTheme != oldDelegate.iconTheme
        || textTheme != oldDelegate.textTheme
        || primary != oldDelegate.primary
        || centerTitle != oldDelegate.centerTitle
        || expandedHeight != oldDelegate.expandedHeight
        || topPadding != oldDelegate.topPadding
        || pinned != oldDelegate.pinned
        || snapConfiguration != oldDelegate.snapConfiguration;
  }

  @override
  String toString() {
    return '$runtimeType#$hashCode(topPadding: ${topPadding.toStringAsFixed(1)}, bottomHeight: ${_bottomHeight.toStringAsFixed(1)}, ...)';
  }

}

class PersistentAppBar extends StatefulWidget {

  const PersistentAppBar({
    Key key,
    this.leading,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.forceElevated = false,
    this.backgroundColor,
    this.brightness,
    this.iconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.expandedHeight,
    this.pinned = false,
    this.snap = false,
  }) : super(key: key);

  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final double elevation;
  final bool forceElevated;
  final Color backgroundColor;
  final Brightness brightness;
  final IconThemeData iconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double expandedHeight;
  final bool pinned;
  final bool snap;

  @override
  _PersistentAppBarState createState() => new _PersistentAppBarState();

}

class _PersistentAppBarState extends State<PersistentAppBar> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    assert(!widget.primary || debugCheckHasMediaQuery(context));
    final double topPadding = widget.primary ? MediaQuery.of(context).padding.top : 0.0;
    final double collapsedHeight = (widget.pinned && widget.bottom != null) ? widget.bottom.preferredSize.height + topPadding : topPadding;

    return new SliverPersistentHeader(
      floating: false,
      pinned: widget.pinned,
      delegate: new PersistentAppBarDelegate(
        leading: widget.leading,
        title: widget.title,
        actions: widget.actions,
        flexibleSpace: widget.flexibleSpace,
        bottom: widget.bottom,
        elevation: widget.elevation,
        forceElevated: widget.forceElevated,
        backgroundColor: widget.backgroundColor,
        brightness: widget.brightness,
        iconTheme: widget.iconTheme,
        textTheme: widget.textTheme,
        primary: widget.primary,
        centerTitle: widget.centerTitle,
        expandedHeight: widget.expandedHeight,
        collapsedHeight: collapsedHeight,
        topPadding: topPadding,
        pinned: widget.pinned
      ),
    );
  }

}

