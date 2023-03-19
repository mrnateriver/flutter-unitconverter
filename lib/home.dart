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
import 'fixed_sliver_grid_delegate.dart';
import 'strings.dart';
import 'conversions.dart';
import 'persistent_appbar.dart';
import 'category.dart';

class ConverterLogo extends StatefulWidget {

  const ConverterLogo({this.height, this.t, this.opacityT});

  final double height;
  final double t;
  final double opacityT;

  @override
  ConverterLogoState createState() => new ConverterLogoState();

}

class ConverterLogoState extends State<ConverterLogo> {

  //native sizes for logo and its image/text components.
  static const double imageHeight = 48.0;
  static const double imageWidth = 48.0;

  static const double textHeight = 20.0;
  static const double textWidth = 220.0;

  static const double logoHeight = 72.0;
  static const double logoWidth = 220.0;

  final RectTween textRectTween = new RectTween(
      begin: new Rect.fromLTWH(0.0, logoHeight, textWidth, textHeight),
      end: new Rect.fromLTWH(0.0, imageHeight, textWidth, textHeight)
  );

  final RectTween imageRectTween = new RectTween(
    begin: new Rect.fromLTWH(logoWidth / 2 - imageWidth / 2, 0.0, imageWidth, logoHeight),
    end: new Rect.fromLTWH(logoWidth / 2 - imageWidth / 2, 0.0, imageWidth, imageHeight),
  );

  final Tween imageOpacityTween = new Tween<double>(begin: 1.0, end: 0.0);

  final Curve textOpacity = const Interval(0.4, 1.0, curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return new Opacity(opacity: imageOpacityTween.lerp(widget.opacityT), child: new Transform(
      transform: new Matrix4.identity()..scale(widget.height / logoHeight),
      alignment: FractionalOffset.topCenter,
      child: new SizedBox(
        width: textWidth,
        child: new Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            new Positioned.fromRect(
              rect: imageRectTween.lerp(widget.t),
              child: new Image.asset("assets/logo.png", fit: BoxFit.contain)
            ),
            new Positioned.fromRect(
              rect: textRectTween.lerp(widget.t),
              child: new Opacity(
                opacity: ((textOpacity.transform(widget.t) * 100).roundToDouble() / 100),
                child: new Text(
                    ConverterStrings.of(context).applicationTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.title
                ),
              ),
            ),
          ],
        )
      )
    ));
  }

}

class ConverterHome extends StatelessWidget {

  static const expandedAppBarHeight = 98.0;

  Widget _buildCategory(BuildContext context, ConversionCategory category) {
    assert(() {
      print("buildCategory");
      return true;
    });

    ConverterStrings strings = ConverterStrings.of(context);

    Widget previewUnits;
    if (category.previewUnits.isNotEmpty) {
      previewUnits = new Text(category.previewUnits.fold('', (prev, entry) => prev + strings.getString(entry.titleKey) + "   "),
          style: new TextStyle(color: Colors.grey, fontSize: 10.0),
          overflow: TextOverflow.ellipsis
      );
    }

    return new Card(
        key: new ValueKey(category),
        child: new InkWell(
            onTap: () {
              Navigator.push(context, new MaterialPageRoute<Null>(
                settings: const RouteSettings(name: "/category"),
                builder: (BuildContext context) => new ConverterCategory(category),
              ));
            },
            child: new Padding(
                padding: const EdgeInsets.all(10.0), child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Icon(
                      category.iconData, size: 32.0, color: Colors.black54),
                  new Expanded(child: new Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: previewUnits == null ? [
                            new Text(strings.getString(category.titleKey),
                                style: new TextStyle(fontSize: 14.0))
                          ] : [
                            new Text(strings.getString(category.titleKey),
                                style: new TextStyle(fontSize: 14.0)),
                            previewUnits
                          ]
                      )
                  ))
                ]
            ))
        )
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    _buildList() {
      MediaQueryData mediaQueryData = MediaQuery.of(context);

      assert(() {
        print("window size: ${mediaQueryData.size}");
        return true;
      });

      int crossAxisCount = (mediaQueryData.size.width / 300).floor();

      if (mediaQueryData.orientation == Orientation.landscape || crossAxisCount > 1) {
        return new SliverGrid(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisExtent(
              crossAxisCount: crossAxisCount < 2 ? 2 : crossAxisCount,
              mainAxisExtent: 60.0
          ),
          delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
            return _buildCategory(context, ConversionCategories.categories[index]);
          },
            childCount: ConversionCategories.categories.length,
          ),
        );
      } else {
        return new SliverFixedExtentList(
            delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return _buildCategory(context, ConversionCategories.categories[index]);
              },
              childCount: ConversionCategories.categories.length,
            ),
            itemExtent: 65.0
        );
      }
    }
    return _buildList();
  }

  Widget _buildAppBar(BuildContext context) {
    assert(() {
      print("pixelRatio: ${MediaQuery.of(context).devicePixelRatio}");
      return true;
    });

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return new PersistentAppBar(
      pinned: true,
      expandedHeight: expandedAppBarHeight,

      flexibleSpace: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

          final Size size           = constraints.biggest;
          final double appBarHeight = size.height - statusBarHeight;

          //'t' is coefficient of current AppBar height relative to its maximum height
          //this means that when 't' is 1.0 the AppBar is fully expanded, whereas when 't' is 0.0 - it's fully collapsed
          final double t = (appBarHeight - kToolbarHeight) / (expandedAppBarHeight - kToolbarHeight);
          final double extraPadding = new Tween<double>(begin: 5.0, end: 15.0).lerp(t).clamp(0.0, 15.0);

          final double minLogoHeight = ConverterLogoState.logoHeight / 4 * 3;
          double topCollapse = 0.0;
          double opacityT = 0.0;

          double logoHeight = (appBarHeight - 1.5 * extraPadding);
          if (logoHeight < minLogoHeight) {
            opacityT    = (logoHeight - minLogoHeight).abs() / minLogoHeight;
            topCollapse = Curves.easeIn.flipped.transform((logoHeight - minLogoHeight).abs() / minLogoHeight) * statusBarHeight;

            logoHeight = minLogoHeight;
          }

          return new Padding(
            padding: new EdgeInsets.only(
              top: statusBarHeight + 0.5 * extraPadding - topCollapse,
              bottom: extraPadding,
            ),
            child: new Center(
                child: new ConverterLogo(height: logoHeight, t: t.clamp(0.0, 1.0), opacityT: opacityT)
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return new CustomScrollView(
        slivers: [
          _buildAppBar(context),
          new SliverPadding(
              padding: const EdgeInsets.all(5.0),
              sliver: _buildCategoriesList(context)
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildBody(context)
    );
  }

}
