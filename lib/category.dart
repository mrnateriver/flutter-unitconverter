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

import 'package:intl/number_symbols_data.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'conversions.dart';
import 'strings.dart';

typedef void UnitTapCallback(UnitSystem system, Unit unit);

class ConverterUnit extends StatefulWidget {

  ConverterUnit({
    @required this.unitSystem,
    @required this.unit,
    this.value: null,
    this.reference: false,
    this.callback: null
  });

  final UnitSystem unitSystem;
  final Unit unit;
  final double value;
  final bool reference;
  final UnitTapCallback callback;

  @override
  State createState() => new ConverterUnitState();

}

class ConverterUnitState extends State<ConverterUnit> with SingleTickerProviderStateMixin {

  AnimationController _referenceAnimationController;

  @override
  void initState() {
    super.initState();

    _referenceAnimationController = new AnimationController(
      upperBound: 5.0,
      duration: const Duration(milliseconds: 200),
      vsync: this
    );
  }

  @override
  void dispose() {
    _referenceAnimationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConverterStrings strings = ConverterStrings.of(context);

    List<Widget> rowWidgets = [];

    if (widget.unit.shortTitleKey == null) {
      rowWidgets.add(new Text(strings.getString(widget.unit.titleKey)));
    } else {
      rowWidgets.add(new Row(
          children: <Widget> [
            new Text(strings.getString(widget.unit.titleKey)),
            new Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: new Text(strings.getString(widget.unit.shortTitleKey), style: new TextStyle(fontSize: 12.0, color: Colors.black38))
            ),
          ]
      ));
    }

    if (widget.reference) {
      _referenceAnimationController.forward();
    } else {
      _referenceAnimationController.reverse();
    }

    if (widget.value != null) {
      String value;
      if (widget.value.isInfinite) {
        value = "\u221E";
      } else {
        NumberFormat format;
        if ((widget.value != 0 && widget.value.abs() < 0.000001) || widget.value > 10000000000) {
          format = new NumberFormat("0.######E0", Intl.canonicalizedLocale(ConverterStrings.of(context).language));
        } else {
          format = new NumberFormat("#0.######", Intl.canonicalizedLocale(ConverterStrings.of(context).language));
        }
        value = format.format(widget.value);
      }

      rowWidgets.add(new Expanded(child: new Container()));
      rowWidgets.add(new Text(value, style: new TextStyle(fontWeight: FontWeight.w500)));
    }

    return new AnimatedBuilder(
        animation: _referenceAnimationController,
        builder: (BuildContext context, _) {
          return _buildUnitRow(context, rowWidgets);
        }
    );
  }

  Widget _buildUnitRow(BuildContext context, List<Widget> rowWidgets) {
    var inkWell = new InkWell(
      key: new ValueKey(widget.unit),
      onTap: () {
        widget.callback == null ? null : widget.callback(widget.unitSystem, widget.unit);
      },
      child: new Padding(
          padding: new EdgeInsets.fromLTRB(10.0 + _referenceAnimationController.value, 15.0, 10.0, 15.0),
          child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: rowWidgets
          )
      ),
    );

    return _referenceAnimationController.value > 0 ? new DecoratedBox(
      child: inkWell,
      decoration: new BoxDecoration(
        border: new Border(left: new BorderSide(width: _referenceAnimationController.value, color: Theme.of(context).accentColor)),
      ),
    ) : inkWell;
  }

}

class ConverterCategory extends StatefulWidget {

  ConverterCategory(this.category);

  final ConversionCategory category;

  @override
  State createState() => new ConverterCategoryState();

}

class ConverterCategoryState extends State<ConverterCategory> {

  double inputValue;

  UnitSystem selectedSystem;
  Unit selectedUnit;

  final TextEditingController _inputController = new TextEditingController();
  final ScrollController _mainScrollController = new ScrollController();
  final FocusNode _inputFocusNode = new FocusNode();

  static const double _keypadCloseScrollThreshold = 30.0;

  bool _inputKeypadOpened = false;
  double _previousScrollOffset = 0.0;

  String _decimalSeparator;

  @override
  void initState() {
    super.initState();

    selectedUnit = widget.category.referenceUnit;
    selectedSystem = widget.category.unitSystems.firstWhere(
        (UnitSystem system) => system.units.firstWhere((Unit unit) => unit == selectedUnit, orElse: () => null) != null,
        orElse: () => null
    );
  }

  void _onMainScroll() {
    if ((_mainScrollController.offset - _previousScrollOffset).abs() >= _keypadCloseScrollThreshold && _inputKeypadOpened) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _inputKeypadOpened = false;
    }
    _previousScrollOffset = _mainScrollController.offset;
  }

  void _unitTap(UnitSystem system, Unit unit) {
    setState(() {
      selectedSystem = system;
      selectedUnit   = unit;

      FocusScope.of(context)..requestFocus(_inputFocusNode)
                            ..reparentIfNeeded(_inputFocusNode);

      SystemChannels.textInput.invokeMethod('TextInput.show');
      _inputKeypadOpened = true;
    });
  }

  Widget _buildUnitsList(BuildContext context, UnitSystem system) {
    return new Column(
      children: system.units.map(
        (Unit unit) {
          double value;
          if (inputValue != null && selectedUnit != null) {

            if ((unit.specialId != null || selectedUnit.specialId != null) &&
                widget.category.converter != null) {
              value = widget.category.converter(widget.category, selectedUnit, inputValue, unit);

            } else {
              value = (inputValue / selectedUnit.ratio) * unit.ratio;
            }

            value = double.parse(value.toStringAsPrecision(7));
          }

          return new ConverterUnit(
            unitSystem: system,
            unit: unit,
            reference: (system == selectedSystem && unit == selectedUnit),
            value: value,
            callback: _unitTap,
          );
        }
      ).toList()
    );
  }

  Widget _buildUnits(BuildContext context, UnitSystem system) {
    List<Widget> cardChildren = [
      new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: new Text(
              ConverterStrings.of(context).getString(system.titleKey),
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 16.0)
          )
      )
    ];

    if (system.memoTextKey != null) {
      cardChildren.add(new Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
          child: new Text(
              ConverterStrings.of(context).getString(system.memoTextKey),
              style: new TextStyle(color: Colors.black54, fontSize: 12.0)
          )
      ));
    }

    cardChildren.add(_buildUnitsList(context, system));

    return new Card(
      elevation: 1.0,
      key: new ValueKey(system),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardChildren
      )
    );
  }

  void _onInputChanged(String text) {
    //first of all, try to convert to double
    double val;
    try {
      //we can't use 'text' argument, because it may contain filtered characters
      val = double.parse(_inputController.text.replaceAll(new RegExp("\\$_decimalSeparator"), '.'));
    } on FormatException {
      assert(() {
        print("FormatException: input value is invalid");
        return true;
      });
    }

    //now recalculate all units
    setState(() {
      inputValue = val;
    });
  }

  Widget _buildSliverBody(BuildContext context) {

    if (_decimalSeparator == null) {
      String locale = Intl.canonicalizedLocale(ConverterStrings.of(context).language);
      _decimalSeparator = numberFormatSymbols[locale].DECIMAL_SEP;

      assert(() {
        print("ConverterCategoryState.build: locale: $locale separator: $_decimalSeparator");
        return true;
      });
    }

    MediaQueryData mediaData = MediaQuery.of(context);

    String referenceUnitText = "";
    if (selectedUnit != null) {
      if (selectedUnit.shortTitleKey != null) {
        referenceUnitText = ConverterStrings.of(context).getString(selectedUnit.shortTitleKey);
      } else {
        referenceUnitText = ConverterStrings.of(context).getString(selectedUnit.titleKey);
      }
    }

    Widget appBar = new SliverAppBar(
      title: new Text(ConverterStrings.of(context).getString(widget.category.titleKey)),
      floating: true,
      pinned: true,

      bottom: new PreferredSize(
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Material(
                type: MaterialType.card,
                elevation: 2.0,
                borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
                child: new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                          child: new TextField(
                            controller: _inputController,
                            inputFormatters: [
                              TextInputFormatter.withFunction((_, TextEditingValue newValue) {
                                return (newValue.text.isEmpty || new RegExp("^\\-?\\d+\\$_decimalSeparator?\\d*\$").firstMatch(newValue.text) != null ? newValue : _);
                              })
                            ],
                            focusNode: _inputFocusNode,
                            //keyboardType: TextInputType.number, //removed due to that some platforms can't even offer decimal point, nevermind minus sign
                            textAlign: TextAlign.left,
                            decoration: new InputDecoration.collapsed(
                                hintText: ConverterStrings
                                    .of(context)
                                    .unitValueInputLabel
                            ),
                            onChanged: _onInputChanged,
                          ),
                        ),
                        new ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 70.0),
                          child: new Text(referenceUnitText, textAlign: TextAlign.right, style: new TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        )
                      ],
                    )
                )
            ),
          ),
          preferredSize: new Size(mediaData.size.width, 60.0)
      ),
    );

    Widget body;
    var sliverDelegate = new SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return _buildUnits(context, widget.category.unitSystems[index]);
      },
      childCount: widget.category.unitSystems.length,
    );

    int numberOfColumns = (mediaData.size.width / 300).floor();

    if ((mediaData.orientation == Orientation.landscape && numberOfColumns > 1) || numberOfColumns > 2) {
      double cardWidth = (mediaData.size.width / numberOfColumns).floorToDouble() - 5.0 /*padding*/;

      List<List<UnitSystem>> columns = [];
      for (int i = 0; i < numberOfColumns; i++) {
        columns.add([]);
      }

      widget.category.unitSystems.asMap().forEach(
          (int index, UnitSystem system) {
            columns[index % numberOfColumns].add(system);
          }
      );

      List<Widget> columnChildren = [];
      for (int i = 0; i < numberOfColumns; i++) {
        columnChildren.add(new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: columns[i].map(
                    (UnitSystem system) => new ConstrainedBox(constraints: new BoxConstraints(maxWidth: cardWidth), child: _buildUnits(context, system))
            ).toList()
        ));
      }

      body = new SliverToBoxAdapter(
          child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren
          )
      );

    } else {
      body = new SliverList(
          delegate: sliverDelegate
      );
    }

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      //we need to hide keypad on scroll down
      _mainScrollController.addListener(_onMainScroll);
    }

    return new CustomScrollView(
      controller: _mainScrollController,
      slivers: [
        appBar,
        new SliverPadding(
            padding: const EdgeInsets.all(5.0),
            sliver: body
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _buildSliverBody(context)
    );
  }

}
