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
import 'package:flutter/material.dart';
import 'data.dart';

typedef double NonLinearUnitConverter(ConversionCategory category, Unit inputUnit, double inputValue, Unit outputUnit);

double _convertTemperature(_, Unit inputUnit, double inputValue, Unit outputUnit) {
  if (inputUnit == outputUnit) {
    return inputValue;
  }

  double kelvinValue = 0.0;
  if (inputUnit.specialId == 0) {
    //celsius
    kelvinValue = inputValue + 273.15;
  } else if (inputUnit.specialId == 1) {
    //fahrenheit
    kelvinValue = (((inputValue - 32) * 5) / 9) + 273.15;
  } else if (inputUnit.specialId == 2) {
    //kelvin
    kelvinValue = inputValue;
  } else if (inputUnit.specialId == 3) {
    //reaumur
    kelvinValue = (inputValue * 1.25) + 273.15;
  } else if (inputUnit.specialId == 4) {
    //rankine
    kelvinValue = inputValue / 1.8;
  } else {
    kelvinValue = inputValue;
  }

  double result = 0.0;
  if (outputUnit.specialId == 0) {
    //celsius
    result = kelvinValue - 273.15;
  } else if (outputUnit.specialId == 1) {
    //fahrenheit
    result = (((kelvinValue - 273.15) * 9) / 5) + 32;
  } else if (outputUnit.specialId == 2) {
    //kelvin
    result = kelvinValue;
  } else if (outputUnit.specialId == 3) {
    //reaumur
    result = (kelvinValue - 273.15) * 0.8;
  } else if (outputUnit.specialId == 4) {
    //rankine
    result = kelvinValue * 1.8;
  } else {
    result = kelvinValue;
  }

  return result;
}

double _convertFuelConsumption(_, Unit inputUnit, double inputValue, Unit outputUnit) {
  if (inputUnit == outputUnit) {
    return inputValue;
  }

  //litres = 3.785412 * US gallons
  //litres = 4.546099 * UK gallons
  //km = 1.609344 * miles
  double litresPerKmValue = 0.0;
  if (inputUnit.specialId == 0) {
    //litres per 100 km
    litresPerKmValue = inputValue;
  } else if (inputUnit.specialId == 1) {
    //km per litre
    litresPerKmValue = 100 / inputValue;
  } else if (inputUnit.specialId == 2) {
    //miles per US gallon
    litresPerKmValue = (3.785412 * 100) / (inputValue * 1.609344);
  } else if (inputUnit.specialId == 3) {
    //US gallons per 100 miles
    litresPerKmValue = (inputValue * 3.785412) / 1.609344;
  } else if (inputUnit.specialId == 4) {
    //miles per UK gallon
    litresPerKmValue = (4.546099 * 100) / (inputValue * 1.609344);
  } else if (inputUnit.specialId == 5) {
    //UK gallons per 100 miles
    litresPerKmValue = (inputValue * 4.546099) / 1.609344;
  } else if (inputUnit.specialId == 6) {
    //litres per 100 miles
    litresPerKmValue = inputValue / 1.609344;
  }

  double result = 0.0;
  if (outputUnit.specialId == 0) {
    //litres per 100 km
    result = litresPerKmValue;
  } else if (outputUnit.specialId == 1) {
    //km per litre
    result = 100 / litresPerKmValue;
  } else if (outputUnit.specialId == 2) {
    //miles per US gallon
    result = (3.785412 * 100) / (litresPerKmValue * 1.609344);
  } else if (outputUnit.specialId == 3) {
    //US gallons per 100 miles
    result = (litresPerKmValue * 1.609344) / 3.785412;
  } else if (outputUnit.specialId == 4) {
    //miles per UK gallon
    result = (4.546099 * 100) / (litresPerKmValue * 1.609344);
  } else if (outputUnit.specialId == 5) {
    //UK gallons per 100 miles
    result = (litresPerKmValue * 1.609344) / 4.546099;
  } else if (outputUnit.specialId == 6) {
    //litres per 100 miles
    result = litresPerKmValue * 1.609344;
  }

  return result;
}

double _convertInverseRelation(ConversionCategory category, Unit inputUnit, double inputValue, Unit outputUnit) {
  if (inputUnit == outputUnit) {
    return inputValue;
  }

  if (inputUnit.specialId != null && outputUnit.specialId != null) {
    Unit referenceUnit = category.referenceUnit;

    double ref = (inputUnit.ratio * referenceUnit.ratio) / inputValue;
    ref = (referenceUnit.ratio * outputUnit.ratio) / ref;

    return ref;

  } else {
    double ref = inputValue / inputUnit.ratio;
    return outputUnit.ratio / ref;
  }
}

class Unit {

  const Unit({
    @required this.titleKey,
    this.shortTitleKey: null,
    this.ratio: 1.0,
    this.specialId: null
  });

  final String titleKey;
  final String shortTitleKey;
  final num ratio;
  final int specialId;

  @override
  bool operator == (dynamic other) {
    if (other is Unit) {
      return titleKey == other.titleKey;
    } else {
      return this == other;
    }
  }

  @override
  int get hashCode => titleKey.hashCode;

}

class UnitSystem {

  const UnitSystem({
    @required this.titleKey,
    @required this.units,
    this.memoTextKey: null
  });

  final String titleKey;
  final List<Unit> units;
  final String memoTextKey;

  @override
  bool operator == (dynamic other) {
    if (other is UnitSystem) {
      return titleKey == other.titleKey;
    } else {
      return this == other;
    }
  }

  @override
  int get hashCode => titleKey.hashCode;

}

class ConversionCategory {

  const ConversionCategory({
    @required this.titleKey,
    @required this.iconData,
    @required referenceUnit,
    @required this.unitSystems,
    this.converter: null,
    this.previewUnits: const []

  }): this._referenceUnit = referenceUnit;

  final String titleKey;
  final IconData iconData;
  final List<UnitSystem> unitSystems;
  final NonLinearUnitConverter converter;
  final List<Unit> previewUnits;

  final Unit _referenceUnit;
  Unit get referenceUnit => allUnits.firstWhere((Unit unit) => unit == _referenceUnit);

  List<Unit> get allUnits {
    var result = <Unit> [];
    unitSystems.forEach((UnitSystem system) {
      result.addAll(system.units);
    });
    return result;
  }

}

class ConversionCategories {

  static const List<ConversionCategory> categories = const [

    //Weight and mass
    const ConversionCategory(
        titleKey: StringKey.weightAndMass,
        iconData: Icons.fitness_center,
        referenceUnit: const Unit(titleKey: StringKey.weightMetricSystem_gram),
        previewUnits: const <Unit> [
          const Unit(
              titleKey: StringKey.weightMetricSystem_kilogram,
              shortTitleKey: StringKey.weightMetricSystem_kilogram_short,
          ),
          const Unit(
              titleKey: StringKey.weightMetricSystem_gram,
              shortTitleKey: StringKey.weightMetricSystem_gram_short,
          ),
          const Unit(
              titleKey: StringKey.weightAvoirdupoisUSUKSystem_pound,
              shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_pound_short,
          ),
          const Unit(
              titleKey: StringKey.weightAvoirdupoisUSUKSystem_ounce,
              shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_ounce_short,
          )
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.weightMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.weightMetricSystem_kilotonne,
                    shortTitleKey: StringKey.weightMetricSystem_kilotonne_short,
                    ratio: 1e-9
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_tonne,
                    shortTitleKey: StringKey.weightMetricSystem_tonne_short,
                    ratio: 0.000001
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_centner,
                    ratio: 0.00001
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_kilogram,
                    shortTitleKey: StringKey.weightMetricSystem_kilogram_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_gram,
                    shortTitleKey: StringKey.weightMetricSystem_gram_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_centigram,
                    shortTitleKey: StringKey.weightMetricSystem_centigram_short,
                    ratio: 100
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_milligram,
                    shortTitleKey: StringKey.weightMetricSystem_milligram_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_microgram,
                    shortTitleKey: StringKey.weightMetricSystem_microgram_short,
                    ratio: 1000000
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_atomicMassUnit,
                    shortTitleKey: StringKey.weightMetricSystem_atomicMassUnit_short,
                    ratio: 6.022142e+23
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_kilonewton,
                    shortTitleKey: StringKey.weightMetricSystem_kilonewton_short,
                    ratio: 0.000009806652
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_newton,
                    shortTitleKey: StringKey.weightMetricSystem_newton_short,
                    ratio: 0.009806652
                ),
                const Unit(
                    titleKey: StringKey.weightMetricSystem_carat,
                    shortTitleKey: StringKey.weightMetricSystem_carat_short,
                    ratio: 5
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.weightAvoirdupoisUSUKSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_longTon,
                    ratio: 9.842065e-7
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_shortTon,
                    ratio: 0.000001102311
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_longHundredweight,
                    ratio: 0.00001968413
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_shortHundredweight,
                    ratio: 0.00002204623
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_stone,
                    shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_stone_short,
                    ratio: 0.000157473
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_pound,
                    shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_pound_short,
                    ratio: 0.002204623
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_ounce,
                    shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_ounce_short,
                    ratio: 0.03527396
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_dram,
                    shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_dram_short,
                    ratio: 0.5643834
                ),
                const Unit(
                    titleKey: StringKey.weightAvoirdupoisUSUKSystem_grain,
                    shortTitleKey: StringKey.weightAvoirdupoisUSUKSystem_grain_short,
                    ratio: 15.43236
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.weightTroyWeightSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_pound,
                    ratio: 0.002679229
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_ounce,
                    ratio: 0.03215075
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_pennyweight,
                    ratio: 0.6430149
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_carat,
                    ratio: 4.878049
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_grain,
                    ratio: 15.43236
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_mite,
                    ratio: 308.6472
                ),
                const Unit(
                    titleKey: StringKey.weightTroyWeightSystem_doite,
                    ratio: 7407.532
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.weightApothecariesWeightSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.weightApothecariesWeightSystem_pound,
                    ratio: 0.002679229
                ),
                const Unit(
                    titleKey: StringKey.weightApothecariesWeightSystem_ounce,
                    ratio: 0.03215075
                ),
                const Unit(
                    titleKey: StringKey.weightApothecariesWeightSystem_dram,
                    ratio: 0.257206
                ),
                const Unit(
                    titleKey: StringKey.weightApothecariesWeightSystem_scruple,
                    ratio: 0.7716179
                ),
                const Unit(
                    titleKey: StringKey.weightApothecariesWeightSystem_grain,
                    ratio: 15.43236
                ),
              ]
          ),
        ]
    ),

    //Distance and length
    const ConversionCategory(
        titleKey: StringKey.distanceAndLength,
        iconData: Icons.space_bar,
        referenceUnit: const Unit(titleKey: StringKey.distanceMetricSystem_meter),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.distanceMetricSystem_kilometer,
              shortTitleKey: StringKey.distanceMetricSystem_kilometer_short,
          ),
          const Unit(
              titleKey: StringKey.distanceMetricSystem_meter,
              shortTitleKey: StringKey.distanceMetricSystem_meter_short,
          ),
          const Unit(
              titleKey: StringKey.distanceUSBritishUnitsSystem_mile,
              shortTitleKey: StringKey.distanceUSBritishUnitsSystem_mile_short,
          ),
          const Unit(
              titleKey: StringKey.distanceUSBritishUnitsSystem_foot,
              shortTitleKey: StringKey.distanceUSBritishUnitsSystem_foot_short,
          ),
          const Unit(
              titleKey: StringKey.distanceUSBritishUnitsSystem_inch,
              shortTitleKey: StringKey.distanceUSBritishUnitsSystem_inch_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.distanceMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_kilometer,
                    shortTitleKey: StringKey.distanceMetricSystem_kilometer_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_meter,
                    shortTitleKey: StringKey.distanceMetricSystem_meter_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_decimeter,
                    shortTitleKey: StringKey.distanceMetricSystem_decimeter_short,
                    ratio: 10
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_centimeter,
                    shortTitleKey: StringKey.distanceMetricSystem_centimeter_short,
                    ratio: 100
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_millimeter,
                    shortTitleKey: StringKey.distanceMetricSystem_millimeter_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_micrometre,
                    shortTitleKey: StringKey.distanceMetricSystem_micrometre_short,
                    ratio: 1000000
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_nanometer,
                    shortTitleKey: StringKey.distanceMetricSystem_nanometer_short,
                    ratio: 1000000000
                ),
                const Unit(
                    titleKey: StringKey.distanceMetricSystem_angstrom,
                    shortTitleKey: StringKey.distanceMetricSystem_angstrom_short,
                    ratio: 10000000000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.distanceUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_league,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_league_short,
                    ratio: 0.0002071237
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_mile,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_mile_short,
                    ratio: 0.0006213712
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_furlong,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_furlong_short,
                    ratio: 0.00497097
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_chain,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_chain_short,
                    ratio: 0.04970969
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_rodperch,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_rodperch_short,
                    ratio: 0.1988388
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_yard,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_yard_short,
                    ratio: 1.093613
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_foot,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_foot_short,
                    ratio: 3.28084
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_surveyFoot,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_surveyFoot_short,
                    ratio: 3.280833
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_link,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_link_short,
                    ratio: 4.970969
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_hand,
                    ratio: 9.84252
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_inch,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_inch_short,
                    ratio: 39.37008
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_line,
                    ratio: 472.4409
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_mil,
                    ratio: 39370.08
                ),
                const Unit(
                    titleKey: StringKey.distanceUSBritishUnitsSystem_microinch,
                    shortTitleKey: StringKey.distanceUSBritishUnitsSystem_microinch_short,
                    ratio: 39370080
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.distanceNauticalUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.distanceNauticalUnitsSystem_seaLeague,
                    shortTitleKey: StringKey.distanceNauticalUnitsSystem_seaLeague_short,
                    ratio: 0.0001799856
                ),
                const Unit(
                    titleKey: StringKey.distanceNauticalUnitsSystem_seaMile,
                    shortTitleKey: StringKey.distanceNauticalUnitsSystem_seaMile_short,
                    ratio: 0.0005399568
                ),
                const Unit(
                    titleKey: StringKey.distanceNauticalUnitsSystem_cable,
                    shortTitleKey: StringKey.distanceNauticalUnitsSystem_cable_short,
                    ratio: 0.004556722
                ),
                const Unit(
                    titleKey: StringKey.distanceNauticalUnitsSystem_shortCable,
                    shortTitleKey: StringKey.distanceNauticalUnitsSystem_shortCable_short,
                    ratio: 0.005399568
                ),
                const Unit(
                    titleKey: StringKey.distanceNauticalUnitsSystem_fathom,
                    shortTitleKey: StringKey.distanceNauticalUnitsSystem_fathom_short,
                    ratio: 0.5468066
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.distanceAstronomicalUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_redShift,
                    shortTitleKey: StringKey.distanceAstronomicalUnitsSystem_redShift_short,
                    ratio: 7.675934e-27
                ),
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_parsec,
                    shortTitleKey: StringKey.distanceAstronomicalUnitsSystem_parsec_short,
                    ratio: 3.240779e-17
                ),
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_lightYear,
                    ratio: 1.057023e-16
                ),
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_astronomicalUnit,
                    shortTitleKey: StringKey.distanceAstronomicalUnitsSystem_astronomicalUnit_short,
                    ratio: 6.684587e-12
                ),
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_lightMinute,
                    ratio: 5.559402e-11
                ),
                const Unit(
                    titleKey: StringKey.distanceAstronomicalUnitsSystem_lightSecond,
                    ratio: 3.335641e-9
                ),
              ]
          ),
        ]
    ),

    //Capacity and volume
    const ConversionCategory(
        titleKey: StringKey.capacityAndVolume,
        iconData: Icons.filter_none,
        referenceUnit: const Unit(titleKey: StringKey.capacityMetricSystem_cubicMeter),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.capacityMetricSystem_cubicMeter,
              shortTitleKey: StringKey.capacityMetricSystem_cubicMeter_short,
          ),
          const Unit(
              titleKey: StringKey.capacityMetricSystem_liter,
              shortTitleKey: StringKey.capacityMetricSystem_liter_short,
          ),
          const Unit(
              titleKey: StringKey.capacityMetricSystem_milliliter,
              shortTitleKey: StringKey.capacityMetricSystem_milliliter_short,
          ),
          const Unit(
              titleKey: StringKey.capacityUSLiquidMeasureSystem_gallon,
              shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_gallon_short,
          ),
          const Unit(
              titleKey: StringKey.capacityUSLiquidMeasureSystem_fluidOunce,
              shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_fluidOunce_short,
          ),
          const Unit(
              titleKey: StringKey.capacityUSBritishUnitsSystem_cubicFoot,
              shortTitleKey: StringKey.capacityUSBritishUnitsSystem_cubicFoot_short,
          ),
          const Unit(
              titleKey: StringKey.capacityUSBritishUnitsSystem_cubicInch,
              shortTitleKey: StringKey.capacityUSBritishUnitsSystem_cubicInch_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.capacityMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_cubicKilometer,
                    shortTitleKey: StringKey.capacityMetricSystem_cubicKilometer_short,
                    ratio: 1e-9
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_cubicMeter,
                    shortTitleKey: StringKey.capacityMetricSystem_cubicMeter_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_cubicDecimeter,
                    shortTitleKey: StringKey.capacityMetricSystem_cubicDecimeter_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_cubicCentimeter,
                    shortTitleKey: StringKey.capacityMetricSystem_cubicCentimeter_short,
                    ratio: 1000000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_cubicMillimeter,
                    shortTitleKey: StringKey.capacityMetricSystem_cubicMillimeter_short,
                    ratio: 1000000000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_hectoliter,
                    shortTitleKey: StringKey.capacityMetricSystem_hectoliter_short,
                    ratio: 10
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_decaliter,
                    shortTitleKey: StringKey.capacityMetricSystem_decaliter_short,
                    ratio: 100
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_liter,
                    shortTitleKey: StringKey.capacityMetricSystem_liter_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_deciliter,
                    shortTitleKey: StringKey.capacityMetricSystem_deciliter_short,
                    ratio: 10000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_centiliter,
                    shortTitleKey: StringKey.capacityMetricSystem_centiliter_short,
                    ratio: 100000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_milliliter,
                    shortTitleKey: StringKey.capacityMetricSystem_milliliter_short,
                    ratio: 1000000
                ),
                const Unit(
                    titleKey: StringKey.capacityMetricSystem_microliter,
                    shortTitleKey: StringKey.capacityMetricSystem_microliter_short,
                    ratio: 1000000000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityUSLiquidMeasureSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_acreFoot,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_acreFoot_short,
                    ratio: 0.0008107132
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_oilBarrel,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_oilBarrel_short,
                    ratio: 6.289811
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_gallon,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_gallon_short,
                    ratio: 264.1721
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_quart,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_quart_short,
                    ratio: 1056.688
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_pint,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_pint_short,
                    ratio: 2113.376
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_gill,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_gill_short,
                    ratio: 8453.506
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_fluidOunce,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_fluidOunce_short,
                    ratio: 33814.02
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_fluidDram,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_fluidDram_short,
                    ratio: 270512.2
                ),
                const Unit(
                    titleKey: StringKey.capacityUSLiquidMeasureSystem_minim,
                    shortTitleKey: StringKey.capacityUSLiquidMeasureSystem_minim_short,
                    ratio: 16230730
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityUSDryMeasureSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_barrel,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_barrel_short,
                    ratio: 8.64849
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_bushel,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_bushel_short,
                    ratio: 28.37759
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_peck,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_peck_short,
                    ratio: 113.5104
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_gallon,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_gallon_short,
                    ratio: 227.0207
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_quart,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_quart_short,
                    ratio: 908.083
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_pint,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_pint_short,
                    ratio: 1816.166
                ),
                const Unit(
                    titleKey: StringKey.capacityUSDryMeasureSystem_gill,
                    shortTitleKey: StringKey.capacityUSDryMeasureSystem_gill_short,
                    ratio: 7264.664
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_perch,
                    ratio: 1.426855
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_barrel,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_barrel_short,
                    ratio: 6.110602
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_bushel,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_bushel_short,
                    ratio: 27.4961
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_peck,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_peck_short,
                    ratio: 109.9844
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_gallon,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_gallon_short,
                    ratio: 219.9688
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_quart,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_quart_short,
                    ratio: 879.8752
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_pint,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_pint_short,
                    ratio: 1759.75
                ),
                const Unit(
                    titleKey: StringKey.capacityBritishUnitsSystem_fluidOunce,
                    shortTitleKey: StringKey.capacityBritishUnitsSystem_fluidOunce_short,
                    ratio: 35195.01
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityUSBritishUnitsSystem_cubicYard,
                    shortTitleKey: StringKey.capacityUSBritishUnitsSystem_cubicYard_short,
                    ratio: 1.307951
                ),
                const Unit(
                    titleKey: StringKey.capacityUSBritishUnitsSystem_cubicFoot,
                    shortTitleKey: StringKey.capacityUSBritishUnitsSystem_cubicFoot_short,
                    ratio: 35.31467
                ),
                const Unit(
                    titleKey: StringKey.capacityUSBritishUnitsSystem_cubicInch,
                    shortTitleKey: StringKey.capacityUSBritishUnitsSystem_cubicInch_short,
                    ratio: 61023.74
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityCookingUSSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityCookingUSSystem_cup,
                    shortTitleKey: StringKey.capacityCookingUSSystem_cup_short,
                    ratio: 4226.753
                ),
                const Unit(
                    titleKey: StringKey.capacityCookingUSSystem_tablespoon,
                    shortTitleKey: StringKey.capacityCookingUSSystem_tablespoon_short,
                    ratio: 67628.04
                ),
                const Unit(
                    titleKey: StringKey.capacityCookingUSSystem_teaspoon,
                    shortTitleKey: StringKey.capacityCookingUSSystem_teaspoon_short,
                    ratio: 202884.1
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.capacityCookingInternationalSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.capacityCookingInternationalSystem_cup,
                    ratio: 4166.667
                ),
                const Unit(
                    titleKey: StringKey.capacityCookingInternationalSystem_tablespoon,
                    ratio: 66666.67
                ),
                const Unit(
                    titleKey: StringKey.capacityCookingInternationalSystem_teaspoon,
                    ratio: 200000
                ),
              ]
          ),
        ]
    ),

    //Area
    const ConversionCategory(
        titleKey: StringKey.area,
        iconData: Icons.fullscreen,
        referenceUnit: const Unit(titleKey: StringKey.areaMetricSystem_squareMeter),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.areaMetricSystem_squareMeter,
              shortTitleKey: StringKey.areaMetricSystem_squareMeter_short,
          ),
          const Unit(
              titleKey: StringKey.areaMetricSystem_hectare,
              shortTitleKey: StringKey.areaMetricSystem_hectare_short,
          ),
          const Unit(
              titleKey: StringKey.areaUSBritishUnitsSystem_acre,
          ),
          const Unit(
              titleKey: StringKey.areaUSBritishUnitsSystem_squareFoot,
              shortTitleKey: StringKey.areaUSBritishUnitsSystem_squareFoot_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.areaMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.areaMetricSystem_squareKilometer,
                    shortTitleKey: StringKey.areaMetricSystem_squareKilometer_short,
                    ratio: 0.000001
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_squareMeter,
                    shortTitleKey: StringKey.areaMetricSystem_squareMeter_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_squareCentimeter,
                    shortTitleKey: StringKey.areaMetricSystem_squareCentimeter_short,
                    ratio: 10000
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_squareMillimeter,
                    shortTitleKey: StringKey.areaMetricSystem_squareMillimeter_short,
                    ratio: 1000000
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_hectare,
                    shortTitleKey: StringKey.areaMetricSystem_hectare_short,
                    ratio: 0.0001
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_decaredunam,
                    shortTitleKey: StringKey.areaMetricSystem_decaredunam_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_are,
                    shortTitleKey: StringKey.areaMetricSystem_are_short,
                    ratio: 0.01
                ),
                const Unit(
                    titleKey: StringKey.areaMetricSystem_barn,
                    shortTitleKey: StringKey.areaMetricSystem_barn_short,
                    ratio: 1e+28
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.areaUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_township,
                    shortTitleKey: StringKey.areaUSBritishUnitsSystem_township_short,
                    ratio: 1.072506e-8
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_squareMile,
                    shortTitleKey: StringKey.areaUSBritishUnitsSystem_squareMile_short,
                    ratio: 3.861022e-7
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_homestead,
                    ratio: 0.000001544409
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_acre,
                    ratio: 0.0002471054
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_rood,
                    ratio: 0.0009884215
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_squareRodperch,
                    ratio: 0.03953686
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_square,
                    ratio: 0.1076391
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_squareYard,
                    shortTitleKey: StringKey.areaUSBritishUnitsSystem_squareYard_short,
                    ratio: 1.19599
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_squareFoot,
                    shortTitleKey: StringKey.areaUSBritishUnitsSystem_squareFoot_short,
                    ratio: 10.76391
                ),
                const Unit(
                    titleKey: StringKey.areaUSBritishUnitsSystem_squareInch,
                    shortTitleKey: StringKey.areaUSBritishUnitsSystem_squareInch_short,
                    ratio: 1550.003
                ),
              ]
          ),
        ]
    ),

    //Speed
    const ConversionCategory(
        titleKey: StringKey.speed,
        iconData: Icons.directions_run,
        referenceUnit: const Unit(titleKey: StringKey.speedMetricSystem_meterPerSecond),
        converter: _convertInverseRelation,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.speedMetricSystem_kilometerPerHour,
              shortTitleKey: StringKey.speedMetricSystem_kilometerPerHour_short,
          ),
          const Unit(
              titleKey: StringKey.speedUSBritishUnitsSystem_milePerHour,
              shortTitleKey: StringKey.speedUSBritishUnitsSystem_milePerHour_short,
          ),
          const Unit(
              titleKey: StringKey.speedRunningJoggingUnitsSystem_secondPer100Metres,
          ),
          const Unit(
              titleKey: StringKey.speedRunningJoggingUnitsSystem_minutePerKilometer,
          ),
          const Unit(
              titleKey: StringKey.speedRunningJoggingUnitsSystem_minutePerMile,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.speedMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.speedMetricSystem_kilometerPerSecond,
                    shortTitleKey: StringKey.speedMetricSystem_kilometerPerSecond_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.speedMetricSystem_meterPerSecond,
                    shortTitleKey: StringKey.speedMetricSystem_meterPerSecond_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.speedMetricSystem_kilometerPerHour,
                    shortTitleKey: StringKey.speedMetricSystem_kilometerPerHour_short,
                    ratio: 3.6
                ),
                const Unit(
                    titleKey: StringKey.speedMetricSystem_meterPerMinute,
                    shortTitleKey: StringKey.speedMetricSystem_meterPerMinute_short,
                    ratio: 60
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.speedUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.speedUSBritishUnitsSystem_milePerHour,
                    shortTitleKey: StringKey.speedUSBritishUnitsSystem_milePerHour_short,
                    ratio: 2.236936
                ),
                const Unit(
                    titleKey: StringKey.speedUSBritishUnitsSystem_milePerSecond,
                    ratio: 0.0006213712
                ),
                const Unit(
                    titleKey: StringKey.speedUSBritishUnitsSystem_footPerMinute,
                    shortTitleKey: StringKey.speedUSBritishUnitsSystem_footPerMinute_short,
                    ratio: 196.8504
                ),
                const Unit(
                    titleKey: StringKey.speedUSBritishUnitsSystem_footPerSecond,
                    shortTitleKey: StringKey.speedUSBritishUnitsSystem_footPerSecond_short,
                    ratio: 3.28084
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.speedRunningJoggingUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_minutePerKilometer,
                    ratio: 16.66667,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_secondPerKilometer,
                    ratio: 1000,
                    specialId: 1,
                ),
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_secondPer100Metres,
                    ratio: 100,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_minutePerMile,
                    ratio: 26.8224,
                    specialId: 3,
                ),
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_secondPerMile,
                    ratio: 1609.344,
                    specialId: 4,
                ),
                const Unit(
                    titleKey: StringKey.speedRunningJoggingUnitsSystem_secondPer100Yards,
                    ratio: 91.44,
                    specialId: 5,
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.speedNauticalUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.speedNauticalUnitsSystem_knot,
                    shortTitleKey: StringKey.speedNauticalUnitsSystem_knot_short,
                    ratio: 1.943844
                ),
                const Unit(
                    titleKey: StringKey.speedNauticalUnitsSystem_nauticalMilePerHour,
                    shortTitleKey: StringKey.speedNauticalUnitsSystem_nauticalMilePerHour_short,
                    ratio: 1.943844
                ),
              ]
          ),
        ]
    ),

    //Acceleration
    const ConversionCategory(
        titleKey: StringKey.acceleration,
        iconData: Icons.directions_car,
        referenceUnit: const Unit(titleKey: StringKey.accelerationMetricSystem_meterPerSecondSquared),
        converter: _convertInverseRelation,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.accelerationMetricSystem_meterPerSecondSquared,
              shortTitleKey: StringKey.accelerationMetricSystem_meterPerSecondSquared_short,
          ),
          const Unit(
              titleKey: StringKey.accelerationUSBritishUnitsSystem_footPerSecondSquared,
              shortTitleKey: StringKey.accelerationUSBritishUnitsSystem_footPerSecondSquared_short,
          ),
          const Unit(
              titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To100Kmh,
          ),
          const Unit(
              titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To60Mph,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.accelerationMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.accelerationMetricSystem_kmPerSecondSquared,
                    shortTitleKey: StringKey.accelerationMetricSystem_kmPerSecondSquared_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.accelerationMetricSystem_meterPerSecondSquared,
                    shortTitleKey: StringKey.accelerationMetricSystem_meterPerSecondSquared_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.accelerationMetricSystem_mmPerSecondSquared,
                    shortTitleKey: StringKey.accelerationMetricSystem_mmPerSecondSquared_short,
                    ratio: 1000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.accelerationUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.accelerationUSBritishUnitsSystem_milePerSecondSquared,
                    ratio: 0.0006213712
                ),
                const Unit(
                    titleKey: StringKey.accelerationUSBritishUnitsSystem_footPerSecondSquared,
                    shortTitleKey: StringKey.accelerationUSBritishUnitsSystem_footPerSecondSquared_short,
                    ratio: 3.28084
                ),
                const Unit(
                    titleKey: StringKey.accelerationUSBritishUnitsSystem_inchPerSecondSquared,
                    shortTitleKey: StringKey.accelerationUSBritishUnitsSystem_inchPerSecondSquared_short,
                    ratio: 39.37008
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.accelerationOtherUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.accelerationOtherUnitsSystem_galileo,
                    shortTitleKey: StringKey.accelerationOtherUnitsSystem_galileo_short,
                    ratio: 100
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.accelerationCarPerformanceSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To100Kmh,
                    ratio: 27.77778,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To60Mph,
                    ratio: 26.8224,
                    specialId: 1,
                ),
                const Unit(
                    titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To100Mph,
                    ratio: 44.704,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.accelerationCarPerformanceSystem_secondsFrom0To200Mph,
                    ratio: 89.408,
                    specialId: 3,
                ),
              ]
          ),
        ]
    ),

    //Time
    const ConversionCategory(
        titleKey: StringKey.time,
        iconData: Icons.access_time,
        referenceUnit: const Unit(titleKey: StringKey.timeCommonUnitsSystem_day),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_calendarMonth,
          ),
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_week,
          ),
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_day,
          ),
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_hour,
              shortTitleKey: StringKey.timeCommonUnitsSystem_hour_short,
          ),
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_minute,
              shortTitleKey: StringKey.timeCommonUnitsSystem_minute_short,
          ),
          const Unit(
              titleKey: StringKey.timeCommonUnitsSystem_second,
              shortTitleKey: StringKey.timeCommonUnitsSystem_second_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.timeCommonUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_century,
                    ratio: 0.00002737909
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_gregorianYear,
                    ratio: 0.002737909
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_julianYear,
                    ratio: 0.002737851
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_calendarMonth,
                    ratio: 0.03285491
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_week,
                    ratio: 0.1428571
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_day,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_hour,
                    shortTitleKey: StringKey.timeCommonUnitsSystem_hour_short,
                    ratio: 24
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_minute,
                    shortTitleKey: StringKey.timeCommonUnitsSystem_minute_short,
                    ratio: 1440
                ),
                const Unit(
                    titleKey: StringKey.timeCommonUnitsSystem_second,
                    shortTitleKey: StringKey.timeCommonUnitsSystem_second_short,
                    ratio: 86400
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.timeAstronomicalUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_anomalisticYear,
                    ratio: 0.002737778
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_siderealYear,
                    ratio: 0.002737803
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_tropicYear,
                    ratio: 0.002737909
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_draconicYear,
                    ratio: 0.002885003
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_synodicMonth,
                    ratio: 0.03386319
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_siderealMonth,
                    ratio: 0.03660099
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_tropicalMonth,
                    ratio: 0.036601101649
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_anomalisticMonth,
                    ratio: 0.03629165
                ),
                const Unit(
                    titleKey: StringKey.timeAstronomicalUnitsSystem_draconicMonth,
                    ratio: 0.03674871
                ),
              ]
          ),
        ]
    ),

    //Pressure and stress
    const ConversionCategory(
        titleKey: StringKey.pressureAndStress,
        iconData: Icons.vertical_align_bottom,
        referenceUnit: const Unit(titleKey: StringKey.pressureMetricSystem_pascal),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.pressureMetricSystem_millibar,
              shortTitleKey: StringKey.pressureMetricSystem_millibar_short,
          ),
          const Unit(
              titleKey: StringKey.pressureMetricSystem_kilopascal,
              shortTitleKey: StringKey.pressureMetricSystem_kilopascal_short,
          ),
          const Unit(
              titleKey: StringKey.pressureMetricSystem_kgforcePerSqMeter,
              shortTitleKey: StringKey.pressureMetricSystem_kgforcePerSqMeter_short,
          ),
          const Unit(
              titleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareInch,
              shortTitleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareInch_short,
          ),
          const Unit(
              titleKey: StringKey.pressureMercurySystem_mmOfMercury,
              shortTitleKey: StringKey.pressureMercurySystem_mmOfMercury_short,
          ),
          const Unit(
              titleKey: StringKey.pressureAtmosphereSystem_physicalAtmosphere,
              shortTitleKey: StringKey.pressureAtmosphereSystem_physicalAtmosphere_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.pressureMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_bar,
                    ratio: 0.00001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_millibar,
                    shortTitleKey: StringKey.pressureMetricSystem_millibar_short,
                    ratio: 0.01
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_megapascal,
                    shortTitleKey: StringKey.pressureMetricSystem_megapascal_short,
                    ratio: 0.000001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_hectopascal,
                    shortTitleKey: StringKey.pressureMetricSystem_hectopascal_short,
                    ratio: 0.01
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_kilopascal,
                    shortTitleKey: StringKey.pressureMetricSystem_kilopascal_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_pascal,
                    shortTitleKey: StringKey.pressureMetricSystem_pascal_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_kgforcePerSqMeter,
                    shortTitleKey: StringKey.pressureMetricSystem_kgforcePerSqMeter_short,
                    ratio: 0.1019716
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_kgforcePerSqCm,
                    shortTitleKey: StringKey.pressureMetricSystem_kgforcePerSqCm_short,
                    ratio: 0.00001019716
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_meganewtonPerSqMeter,
                    shortTitleKey: StringKey.pressureMetricSystem_meganewtonPerSqMeter_short,
                    ratio: 0.000001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_kilonewtonPerSqMeter,
                    shortTitleKey: StringKey.pressureMetricSystem_kilonewtonPerSqMeter_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_newtonPerSquareMeter,
                    shortTitleKey: StringKey.pressureMetricSystem_newtonPerSquareMeter_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_newtonPerSquareCentimeter,
                    shortTitleKey: StringKey.pressureMetricSystem_newtonPerSquareCentimeter_short,
                    ratio: 0.0001
                ),
                const Unit(
                    titleKey: StringKey.pressureMetricSystem_newtonPerSquareMillimeter,
                    shortTitleKey: StringKey.pressureMetricSystem_newtonPerSquareMillimeter_short,
                    ratio: 0.000001
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.pressureUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareFoot,
                    shortTitleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareFoot_short,
                    ratio: 0.02088543
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_1000PoundsforcePerSquareInch,
                    shortTitleKey: StringKey.pressureUSBritishUnitsSystem_1000PoundsforcePerSquareInch_short,
                    ratio: 1.450377e-7
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareInch,
                    shortTitleKey: StringKey.pressureUSBritishUnitsSystem_poundforcePerSquareInch_short,
                    ratio: 0.0001450377
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_shortTonUSAPerSquareFoot,
                    ratio: 0.00001044272
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_shortTonUSAPerSquareInch,
                    ratio: 7.251887e-8
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_longTonUKPerSquareFoot,
                    ratio: 0.000009323854
                ),
                const Unit(
                    titleKey: StringKey.pressureUSBritishUnitsSystem_longTonUKPerSquareInch,
                    ratio: 6.474899e-8
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.pressureMercurySystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.pressureMercurySystem_centimeterOfMercury,
                    ratio: 0.0007500616
                ),
                const Unit(
                    titleKey: StringKey.pressureMercurySystem_mmOfMercury,
                    shortTitleKey: StringKey.pressureMercurySystem_mmOfMercury_short,
                    ratio: 0.007500616
                ),
                const Unit(
                    titleKey: StringKey.pressureMercurySystem_inchOfMercury,
                    ratio: 0.0002952998
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.pressureAtmosphereSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.pressureAtmosphereSystem_physicalAtmosphere,
                    shortTitleKey: StringKey.pressureAtmosphereSystem_physicalAtmosphere_short,
                    ratio: 0.000009869233
                ),
                const Unit(
                    titleKey: StringKey.pressureAtmosphereSystem_technicalAtmosphere,
                    shortTitleKey: StringKey.pressureAtmosphereSystem_technicalAtmosphere_short,
                    ratio: 0.00001019716
                ),
              ]
          ),
        ]
    ),

    //Energy and work
    const ConversionCategory(
        titleKey: StringKey.energyAndWork,
        iconData: Icons.battery_charging_full,
        referenceUnit: const Unit(titleKey: StringKey.energyInternationalSISystem_joule),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.energyInternationalSISystem_joule,
              shortTitleKey: StringKey.energyInternationalSISystem_joule_short,
          ),
          const Unit(
              titleKey: StringKey.energyCommonUnitsSystem_calorie,
              shortTitleKey: StringKey.energyCommonUnitsSystem_calorie_short,
          ),
          const Unit(
              titleKey: StringKey.energyCommonUnitsSystem_watthour,
              shortTitleKey: StringKey.energyCommonUnitsSystem_watthour_short,
          ),
          const Unit(
              titleKey: StringKey.energyCommonUnitsSystem_electronvolt,
              shortTitleKey: StringKey.energyCommonUnitsSystem_electronvolt_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.energyInternationalSISystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.energyInternationalSISystem_megajoule,
                    shortTitleKey: StringKey.energyInternationalSISystem_megajoule_short,
                    ratio: 0.000001
                ),
                const Unit(
                    titleKey: StringKey.energyInternationalSISystem_kilojoule,
                    shortTitleKey: StringKey.energyInternationalSISystem_kilojoule_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.energyInternationalSISystem_joule,
                    shortTitleKey: StringKey.energyInternationalSISystem_joule_short,
                    ratio: 1
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.energyCommonUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_megacalorie,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_megacalorie_short,
                    ratio: 2.388459e-7
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_kilocalorie,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_kilocalorie_short,
                    ratio: 0.0002388459
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_calorie,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_calorie_short,
                    ratio: 0.2388459
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_meterkilogram,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_meterkilogram_short,
                    ratio: 0.1026082
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_kilowatthour,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_kilowatthour_short,
                    ratio: 2.777778e-7
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_watthour,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_watthour_short,
                    ratio: 0.0002777778
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_wattsecond,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_wattsecond_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_erg,
                    ratio: 10000000
                ),
                const Unit(
                    titleKey: StringKey.energyCommonUnitsSystem_electronvolt,
                    shortTitleKey: StringKey.energyCommonUnitsSystem_electronvolt_short,
                    ratio: 6241450000000000000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.energyUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.energyUSBritishUnitsSystem_quad,
                    ratio: 9.478134e-19
                ),
                const Unit(
                    titleKey: StringKey.energyUSBritishUnitsSystem_therm,
                    ratio: 9.478134e-9
                ),
                const Unit(
                    titleKey: StringKey.energyUSBritishUnitsSystem_britishThermalUnit,
                    shortTitleKey: StringKey.energyUSBritishUnitsSystem_britishThermalUnit_short,
                    ratio: 0.0009478134
                ),
                const Unit(
                    titleKey: StringKey.energyUSBritishUnitsSystem_millionBTU,
                    shortTitleKey: StringKey.energyUSBritishUnitsSystem_millionBTU_short,
                    ratio: 9.478134e-10
                ),
                const Unit(
                    titleKey: StringKey.energyUSBritishUnitsSystem_footpound,
                    shortTitleKey: StringKey.energyUSBritishUnitsSystem_footpound_short,
                    ratio: 0.7375825
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.energyTNTEnergyEquivalentSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.energyTNTEnergyEquivalentSystem_metricTonOfTNT,
                    ratio: 2.168224e-10
                ),
                const Unit(
                    titleKey: StringKey.energyTNTEnergyEquivalentSystem_uSATonOfTNT,
                    ratio: 2.390057e-10
                ),
                const Unit(
                    titleKey: StringKey.energyTNTEnergyEquivalentSystem_kilogramOfTNT,
                    ratio: 2.168224e-7
                ),
              ]
          ),
        ]
    ),

    //Temperature
    const ConversionCategory(
        titleKey: StringKey.temperature,
        iconData: Icons.wb_sunny,
        referenceUnit: const Unit(titleKey: StringKey.temperatureStandardScalesSystem_celsiusDegree),
        converter: _convertTemperature,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.temperatureStandardScalesSystem_celsiusDegree,
              shortTitleKey: StringKey.temperatureStandardScalesSystem_celsiusDegree_short,
          ),
          const Unit(
              titleKey: StringKey.temperatureStandardScalesSystem_fahrenheitDegree,
              shortTitleKey: StringKey.temperatureStandardScalesSystem_fahrenheitDegree_short,
          ),
          const Unit(
              titleKey: StringKey.temperatureStandardScalesSystem_kelvin,
              shortTitleKey: StringKey.temperatureStandardScalesSystem_kelvin_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.temperatureStandardScalesSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.temperatureStandardScalesSystem_celsiusDegree,
                    shortTitleKey: StringKey.temperatureStandardScalesSystem_celsiusDegree_short,
                    ratio: 1,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.temperatureStandardScalesSystem_fahrenheitDegree,
                    shortTitleKey: StringKey.temperatureStandardScalesSystem_fahrenheitDegree_short,
                    ratio: 1,
                    specialId: 1,
                ),
                const Unit(
                    titleKey: StringKey.temperatureStandardScalesSystem_kelvin,
                    shortTitleKey: StringKey.temperatureStandardScalesSystem_kelvin_short,
                    ratio: 1,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.temperatureStandardScalesSystem_reaumurDegree,
                    shortTitleKey: StringKey.temperatureStandardScalesSystem_reaumurDegree_short,
                    ratio: 1,
                    specialId: 3,
                ),
                const Unit(
                    titleKey: StringKey.temperatureStandardScalesSystem_rankineDegree,
                    shortTitleKey: StringKey.temperatureStandardScalesSystem_rankineDegree_short,
                    ratio: 1,
                    specialId: 4,
                ),
              ]
          ),
        ]
    ),

    //Fuel consumption
    const ConversionCategory(
        titleKey: StringKey.fuelConsumption,
        iconData: Icons.local_gas_station,
        referenceUnit: const Unit(titleKey: StringKey.fuelMetricSystem_literPer100Km),
        converter: _convertFuelConsumption,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.fuelMetricSystem_literPer100Km,
              shortTitleKey: StringKey.fuelMetricSystem_literPer100Km_short,
          ),
          const Unit(
              titleKey: StringKey.fuelMetricSystem_kilometerPerLiter,
              shortTitleKey: StringKey.fuelMetricSystem_kilometerPerLiter_short,
          ),
          const Unit(
              titleKey: StringKey.fuelUSUnitsSystem_milePerGallon,
              shortTitleKey: StringKey.fuelUSUnitsSystem_milePerGallon_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.fuelMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.fuelMetricSystem_literPer100Km,
                    shortTitleKey: StringKey.fuelMetricSystem_literPer100Km_short,
                    ratio: 1,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.fuelMetricSystem_kilometerPerLiter,
                    shortTitleKey: StringKey.fuelMetricSystem_kilometerPerLiter_short,
                    ratio: 1,
                    specialId: 1,
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.fuelUSUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.fuelUSUnitsSystem_milePerGallon,
                    shortTitleKey: StringKey.fuelUSUnitsSystem_milePerGallon_short,
                    ratio: 1,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.fuelUSUnitsSystem_gallonPer100Miles,
                    ratio: 1,
                    specialId: 3,
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.fuelBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.fuelBritishUnitsSystem_milePerGallon,
                    shortTitleKey: StringKey.fuelBritishUnitsSystem_milePerGallon_short,
                    ratio: 1,
                    specialId: 4,
                ),
                const Unit(
                    titleKey: StringKey.fuelBritishUnitsSystem_gallonPer100Miles,
                    ratio: 1,
                    specialId: 5,
                ),
                const Unit(
                    titleKey: StringKey.fuelBritishUnitsSystem_literPer100Miles,
                    ratio: 1,
                    specialId: 6,
                ),
              ]
          ),
        ]
    ),

    //Power
    const ConversionCategory(
        titleKey: StringKey.power,
        iconData: Icons.power,
        referenceUnit: const Unit(titleKey: StringKey.powerInternationalSISystem_kilowatt),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.powerInternationalSISystem_watt,
              shortTitleKey: StringKey.powerInternationalSISystem_watt_short,
          ),
          const Unit(
              titleKey: StringKey.powerInternationalSISystem_voltampere,
              shortTitleKey: StringKey.powerInternationalSISystem_voltampere_short,
          ),
          const Unit(
              titleKey: StringKey.powerCommonUnitsSystem_horsepower,
              shortTitleKey: StringKey.powerCommonUnitsSystem_horsepower_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.powerInternationalSISystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.powerInternationalSISystem_megawatt,
                    shortTitleKey: StringKey.powerInternationalSISystem_megawatt_short,
                    ratio: 0.001
                ),
                const Unit(
                    titleKey: StringKey.powerInternationalSISystem_kilowatt,
                    shortTitleKey: StringKey.powerInternationalSISystem_kilowatt_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.powerInternationalSISystem_watt,
                    shortTitleKey: StringKey.powerInternationalSISystem_watt_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.powerInternationalSISystem_voltampere,
                    shortTitleKey: StringKey.powerInternationalSISystem_voltampere_short,
                    ratio: 1000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.powerCommonUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_gigacaloriesPerSecond,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_gigacaloriesPerSecond_short,
                    ratio: 2.388459e-7
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_kilocaloriesPerSecond,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_kilocaloriesPerSecond_short,
                    ratio: 0.2388459
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_caloriesPerSecond,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_caloriesPerSecond_short,
                    ratio: 238.8459
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_gigacaloriesPerHour,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_gigacaloriesPerHour_short,
                    ratio: 0.0008598452
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_kilocaloriesPerHour,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_kilocaloriesPerHour_short,
                    ratio: 859.8452
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_caloriesPerHour,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_caloriesPerHour_short,
                    ratio: 859845.2
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_boilerHorsepower,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_boilerHorsepower_short,
                    ratio: 0.1019589
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_electricHorsepower,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_electricHorsepower_short,
                    ratio: 1.34048
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_horsepower,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_horsepower_short,
                    ratio: 1.359619
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_metricHorsepower,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_metricHorsepower_short,
                    ratio: 1.35962
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_kgforcemeterPerSec,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_kgforcemeterPerSec_short,
                    ratio: 101.9716
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_joulePerSecond,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_joulePerSecond_short,
                    ratio: 1000
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_joulePerHour,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_joulePerHour_short,
                    ratio: 3600000
                ),
                const Unit(
                    titleKey: StringKey.powerCommonUnitsSystem_ergPerSecond,
                    shortTitleKey: StringKey.powerCommonUnitsSystem_ergPerSecond_short,
                    ratio: 10000000000
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.powerUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.powerUSBritishUnitsSystem_britishThermalUnitPerSecond,
                    ratio: 0.9478134
                ),
                const Unit(
                    titleKey: StringKey.powerUSBritishUnitsSystem_britishThermalUnitPerMinute,
                    ratio: 56.8688
                ),
                const Unit(
                    titleKey: StringKey.powerUSBritishUnitsSystem_britishThermalUnitPerHour,
                    ratio: 3412.128
                ),
                const Unit(
                    titleKey: StringKey.powerUSBritishUnitsSystem_footpoundforcePerSecond,
                    shortTitleKey: StringKey.powerUSBritishUnitsSystem_footpoundforcePerSecond_short,
                    ratio: 737.5621
                ),
              ]
          ),
        ]
    ),

    //Torque
    const ConversionCategory(
        titleKey: StringKey.torque,
        iconData: Icons.rotate_left,
        referenceUnit: const Unit(titleKey: StringKey.torqueMetricSystem_newtonmeter),
        previewUnits: const [
          const Unit(
              titleKey: StringKey.torqueMetricSystem_newtonmeter,
              shortTitleKey: StringKey.torqueMetricSystem_newtonmeter_short,
          ),
          const Unit(
              titleKey: StringKey.torqueUSBritishUnitsSystem_poundForcefoot,
              shortTitleKey: StringKey.torqueUSBritishUnitsSystem_poundForcefoot_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.torqueMetricSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_newtonmeter,
                    shortTitleKey: StringKey.torqueMetricSystem_newtonmeter_short,
                    ratio: 1
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_newtoncentimeter,
                    shortTitleKey: StringKey.torqueMetricSystem_newtoncentimeter_short,
                    ratio: 100
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_dynemeter,
                    shortTitleKey: StringKey.torqueMetricSystem_dynemeter_short,
                    ratio: 100000
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_dynecentimeter,
                    shortTitleKey: StringKey.torqueMetricSystem_dynecentimeter_short,
                    ratio: 10000000
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_kilogramForceMeter,
                    shortTitleKey: StringKey.torqueMetricSystem_kilogramForceMeter_short,
                    ratio: 0.1019716
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_kilogramForceCentimeter,
                    shortTitleKey: StringKey.torqueMetricSystem_kilogramForceCentimeter_short,
                    ratio: 10.19716
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_gramForcemeter,
                    shortTitleKey: StringKey.torqueMetricSystem_gramForcemeter_short,
                    ratio: 101.9716
                ),
                const Unit(
                    titleKey: StringKey.torqueMetricSystem_gramForceCentimeter,
                    shortTitleKey: StringKey.torqueMetricSystem_gramForceCentimeter_short,
                    ratio: 10197.16
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.torqueUSBritishUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.torqueUSBritishUnitsSystem_longTonForcefoot,
                    ratio: 0.0003292688
                ),
                const Unit(
                    titleKey: StringKey.torqueUSBritishUnitsSystem_shortTonForcefoot,
                    ratio: 0.0003687811
                ),
                const Unit(
                    titleKey: StringKey.torqueUSBritishUnitsSystem_poundForcefoot,
                    shortTitleKey: StringKey.torqueUSBritishUnitsSystem_poundForcefoot_short,
                    ratio: 0.7375622
                ),
                const Unit(
                    titleKey: StringKey.torqueUSBritishUnitsSystem_poundForceinch,
                    shortTitleKey: StringKey.torqueUSBritishUnitsSystem_poundForceinch_short,
                    ratio: 8.850746
                ),
                const Unit(
                    titleKey: StringKey.torqueUSBritishUnitsSystem_ounceForceinch,
                    shortTitleKey: StringKey.torqueUSBritishUnitsSystem_ounceForceinch_short,
                    ratio: 141.6119
                ),
              ]
          ),
        ]
    ),

    //Computer storage
    const ConversionCategory(
        titleKey: StringKey.computerStorage,
        iconData: Icons.sd_storage,
        referenceUnit: const Unit(titleKey: StringKey.computerDataStorageTransmissionSystem_byte),
        converter: _convertInverseRelation,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.computerDataStorageTransmissionSystem_megabit,
              shortTitleKey: StringKey.computerDataStorageTransmissionSystem_megabit_short,
          ),
          const Unit(
              titleKey: StringKey.computerDataStorageTransmissionSystem_megabyte,
              shortTitleKey: StringKey.computerDataStorageTransmissionSystem_megabyte_short,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              memoTextKey: StringKey.computerDataStorageTransmissionSystemMemoText,
              titleKey: StringKey.computerDataStorageTransmissionSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_exabit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_exabit_short,
                    ratio: 6.938894e-18,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_petabit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_petabit_short,
                    ratio: 7.105427e-15,
                    specialId: 1,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_terabit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_terabit_short,
                    ratio: 7.275958e-12,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_gigabit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_gigabit_short,
                    ratio: 7.45058e-9,
                    specialId: 3,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_megabit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_megabit_short,
                    ratio: 0.000007629395,
                    specialId: 4,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_kilobit,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_kilobit_short,
                    ratio: 0.0078125,
                    specialId: 5,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_bit,
                    ratio: 8,
                    specialId: 6,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_exabyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_exabyte_short,
                    ratio: 8.673617e-19,
                    specialId: 7,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_petabyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_petabyte_short,
                    ratio: 8.881784e-16,
                    specialId: 8,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_terabyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_terabyte_short,
                    ratio: 9.094947e-13,
                    specialId: 9,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_gigabyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_gigabyte_short,
                    ratio: 9.313226e-10,
                    specialId: 10,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_megabyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_megabyte_short,
                    ratio: 9.536743e-7,
                    specialId: 11,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_kilobyte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_kilobyte_short,
                    ratio: 0.0009765625,
                    specialId: 12,
                ),
                const Unit(
                    titleKey: StringKey.computerDataStorageTransmissionSystem_byte,
                    shortTitleKey: StringKey.computerDataStorageTransmissionSystem_byte_short,
                    ratio: 1,
                    specialId: 13,
                ),
              ]
          ),
        ]
    ),

    //Data transfer rate
    const ConversionCategory(
        titleKey: StringKey.dataTransferRate,
        iconData: Icons.settings_ethernet,
        referenceUnit: const Unit(titleKey: StringKey.dataBytebasedUnitsSystem_bytePerSecond),
        converter: _convertInverseRelation,
        previewUnits: const [
          const Unit(
              titleKey: StringKey.dataBasicUnitsSystem_megabitPerSecond,
              shortTitleKey: StringKey.dataBasicUnitsSystem_megabitPerSecond_short,
          ),
          const Unit(
              titleKey: StringKey.dataBytebasedUnitsSystem_megabytePerSecond,
              shortTitleKey: StringKey.dataBytebasedUnitsSystem_megabytePerSecond_short,
          ),
          const Unit(
              titleKey: StringKey.dataDataTransferTimeSystem_minutePerMegabyte,
          ),
        ],
        unitSystems: const <UnitSystem> [
          const UnitSystem(
              titleKey: StringKey.dataBasicUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.dataBasicUnitsSystem_terabitPerSecond,
                    shortTitleKey: StringKey.dataBasicUnitsSystem_terabitPerSecond_short,
                    ratio: 8e-12
                ),
                const Unit(
                    titleKey: StringKey.dataBasicUnitsSystem_gigabitPerSecond,
                    shortTitleKey: StringKey.dataBasicUnitsSystem_gigabitPerSecond_short,
                    ratio: 8e-9
                ),
                const Unit(
                    titleKey: StringKey.dataBasicUnitsSystem_megabitPerSecond,
                    shortTitleKey: StringKey.dataBasicUnitsSystem_megabitPerSecond_short,
                    ratio: 0.000008
                ),
                const Unit(
                    titleKey: StringKey.dataBasicUnitsSystem_kilobitPerSecond,
                    shortTitleKey: StringKey.dataBasicUnitsSystem_kilobitPerSecond_short,
                    ratio: 0.008
                ),
                const Unit(
                    titleKey: StringKey.dataBasicUnitsSystem_bitPerSecond,
                    shortTitleKey: StringKey.dataBasicUnitsSystem_bitPerSecond_short,
                    ratio: 8
                ),
              ]
          ),
          const UnitSystem(
              memoTextKey: StringKey.computerDataStorageTransmissionSystemMemoText,
              titleKey: StringKey.dataBytebasedUnitsSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.dataBytebasedUnitsSystem_terabytePerSecond,
                    shortTitleKey: StringKey.dataBytebasedUnitsSystem_terabytePerSecond_short,
                    ratio: 9.094947e-13
                ),
                const Unit(
                    titleKey: StringKey.dataBytebasedUnitsSystem_gigabytePerSecond,
                    shortTitleKey: StringKey.dataBytebasedUnitsSystem_gigabytePerSecond_short,
                    ratio: 9.313226e-10
                ),
                const Unit(
                    titleKey: StringKey.dataBytebasedUnitsSystem_megabytePerSecond,
                    shortTitleKey: StringKey.dataBytebasedUnitsSystem_megabytePerSecond_short,
                    ratio: 9.536743e-7
                ),
                const Unit(
                    titleKey: StringKey.dataBytebasedUnitsSystem_kilobytePerSecond,
                    shortTitleKey: StringKey.dataBytebasedUnitsSystem_kilobytePerSecond_short,
                    ratio: 0.0009765625
                ),
                const Unit(
                    titleKey: StringKey.dataBytebasedUnitsSystem_bytePerSecond,
                    shortTitleKey: StringKey.dataBytebasedUnitsSystem_bytePerSecond_short,
                    ratio: 1
                ),
              ]
          ),
          const UnitSystem(
              titleKey: StringKey.dataDataTransferTimeSystem,
              units: const <Unit> [
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_secondPerMegabyte,
                    ratio: 1048576,
                    specialId: 0,
                ),
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_secondPerGigabyte,
                    ratio: 1073742000,
                    specialId: 1,
                ),
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_minutePerMegabyte,
                    ratio: 17476.27,
                    specialId: 2,
                ),
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_minutePerGigabyte,
                    ratio: 17895700,
                    specialId: 3,
                ),
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_hourPerMegabyte,
                    ratio: 291.2711,
                    specialId: 4,
                ),
                const Unit(
                    titleKey: StringKey.dataDataTransferTimeSystem_hourPerGigabyte,
                    ratio: 298261.6,
                    specialId: 5,
                ),
              ]
          ),
        ]
    ),

  ];

}
