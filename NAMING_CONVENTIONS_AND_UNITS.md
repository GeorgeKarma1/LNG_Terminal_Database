# LNG Terminal Database - Naming Conventions and Unit Measurements

## Table of Contents
1. [Overview](#overview)
2. [Naming Conventions](#naming-conventions)
3. [Unit Measurement Standards](#unit-measurement-standards)
4. [Temperature References](#temperature-references)
5. [Energy Units](#energy-units)
6. [Mass Units](#mass-units)
7. [Volume Units](#volume-units)
8. [Combined Units - Heating Values](#combined-units---heating-values)
9. [Pressure Units](#pressure-units)
10. [Length and Speed Units](#length-and-speed-units)
11. [Flow Rate Units](#flow-rate-units)
12. [Abbreviation Reference](#abbreviation-reference)

---

## Overview

This document provides comprehensive guidance on naming conventions and unit measurements used throughout the LNG Terminal Database. The database follows international standards (ISO, ASTM, SIGTTO) and industry best practices for LNG operations.

### Design Principles

1. **Snake_case convention**: All table and column names use lowercase with underscores
2. **Unit suffixes**: Physical measurements include unit suffixes for clarity
3. **Standardized abbreviations**: Consistent abbreviations across the database
4. **Dual units**: Both metric and imperial units stored where relevant
5. **Historical versioning**: All critical data maintains version history

---

## Naming Conventions

### General Rules

#### Table Names
- Use lowercase with underscores (snake_case)
- Use singular form for entity tables: `terminal`, `vessel`, `port_call`
- Use descriptive prefixes:
  - `ref_` for reference/lookup tables
  - No prefix for core entity tables
  - Table name describes the relationship for junction tables

#### Column Names
- Use lowercase with underscores (snake_case)
- Include unit suffix for physical measurements
- Format: `{property}_{unit}_{condition}`

Examples:
```sql
max_loa_m                    -- Maximum Length Overall in meters
max_loa_ft                   -- Maximum Length Overall in feet
arrival_temp_c_min           -- Minimum arrival temperature in Celsius
ghv_mj_kg                    -- Gross heating value in MJ/kg
water_density_kgm3           -- Water density in kg/m³
```

### Unit Suffix Standards

| Measurement Type | Unit Suffix | Example Column Name | Description |
|-----------------|-------------|---------------------|-------------|
| **Length** | `_m`, `_ft`, `_in`, `_nm` | `max_draft_m` | Meters, feet, inches, nautical miles |
| **Mass** | `_kg`, `_mt`, `_lbm`, `_lt` | `deadweight_mt` | Kilograms, metric tons, pounds, long tons |
| **Volume** | `_cbm`, `_m3`, `_ft3`, `_l` | `cargo_capacity_cbm` | Cubic meters, liters |
| **Pressure** | `_mbar`, `_kpa`, `_psi`, `_mpa` | `arrival_svp_mbar` | Millibar, kilopascal, PSI, megapascal |
| **Temperature** | `_c`, `_f`, `_k` | `arrival_temp_c` | Celsius, Fahrenheit, Kelvin |
| **Speed** | `_kn`, `_ms`, `_kmh` | `max_transit_speed_kn` | Knots, m/s, km/h |
| **Density** | `_kgm3`, `_lbft3` | `density_liquid_kgm3` | kg/m³, lb/ft³ |
| **Flow Rate** | `_m3h`, `_m3hr`, `_gpm` | `liquid_rate_m3h` | m³/hour, gallons/min |
| **Energy** | `_mj`, `_btu`, `_kwh` | `ghv_mj` | Megajoules, BTU, kWh |
| **Heating Value (mass)** | `_mj_kg`, `_btu_lbm` | `ghv_mj_kg` | MJ/kg, Btu/lbm |
| **Heating Value (volume)** | `_mj_sm3`, `_btu_scf` | `ghv_mj_sm3` | MJ/Sm³, Btu/scf |

### Abbreviations

#### Common Property Abbreviations
- `max` - Maximum
- `min` - Minimum
- `avg` - Average
- `std` - Standard
- `ref` - Reference
- `temp` - Temperature
- `svp` - Saturated Vapor Pressure
- `loa` - Length Overall
- `dwt` - Deadweight
- `cbm` - Cubic meters (volume capacity)
- `ghv` - Gross Heating Value
- `nhv` - Net Heating Value
- `hv` - Heating Value
- `vol` - Volume
- `liq` - Liquid
- `vap` - Vapor

---

## Unit Measurement Standards

### ISO and International Standards

The database follows these international standards:

1. **ISO 6976**: Natural gas - Calculation of calorific values, density, relative density and Wobbe indices from composition
2. **ISO 2533**: Standard Atmosphere
3. **ASTM D3588**: Standard Practice for Calculating Heat Value, Compressibility Factor, and Relative Density of Gaseous Fuels
4. **SIGTTO**: Society of International Gas Tanker and Terminal Operators standards

---

## Temperature References

Temperature reference standards are critical for gas calculations. Different standards use different reference temperatures.

### Standard Temperature References

| Code | Temperature | Standard | Description | Use Case |
|------|------------|----------|-------------|----------|
| **T0C** | 0°C (32°F, 273.15K) | ISO 6976 | Zero degrees Celsius | European/ISO standard |
| **T15C** | 15°C (59°F, 288.15K) | ISO 6976 | Fifteen degrees Celsius | Most common ISO reference |
| **T20C** | 20°C (68°F, 293.15K) | ISO | Twenty degrees Celsius | Alternative reference |
| **T25C** | 25°C (77°F, 298.15K) | - | Twenty-five degrees Celsius | Some regions/applications |
| **T60F** | 60°F (15.56°C, 288.71K) | ASTM | Sixty degrees Fahrenheit | US/ASTM standard |

### Temperature Naming in Abbreviated Forms

- `0` = 0°C
- `1` = 15°C (most common)
- `2` = 25°C
- `6` = 60°F

Examples:
- `MJ0/kg` = MJ/kg at 0°C
- `MJ1/Sm3` = MJ/Sm³ at 15°C
- `B6/Scf` = Btu/scf at 60°F

---

## Energy Units

Energy units are used for heating values and energy content calculations.

### Energy Unit Conversion Table

| Unit | Symbol | Code | To MJ Conversion | Description |
|------|--------|------|------------------|-------------|
| **Megajoule** | MJ | `MJ` | 1.0 | SI unit of energy |
| **British Thermal Unit** | Btu | `BTU` | 0.0010551 | Imperial unit (ISO BTU) |
| **BTU (IT)** | Btu(IT) | `BTUIT` | 0.0010550559 | International Table BTU |
| **BTU at 60°F** | Btu₆₀ | `BTU60F` | 0.00105506 | BTU at 60°F (ASTM) |
| **Kilowatt-hour** | kWh | `KWH` | 3.6 | Electrical energy unit |
| **Kilocalorie** | kcal | `KCAL` | 0.0041868 | Thermochemical calorie |
| **Kilocalorie at 15°C** | kcal₁₅ | `KCAL15` | 0.0041855 | Calorie at 15°C |
| **Thermie** | th | `THERM` | 4.1868 | Metric thermie (1000 kcal) |
| **Gigajoule** | GJ | `GJ` | 1000.0 | 1,000 megajoules |
| **Million BTU** | MMBtu | `MMBTU` | 1055.06 | One million BTU |

### Conversion Examples

```
1 MJ = 947.817 Btu
1 Btu = 0.0010551 MJ
1 kWh = 3.6 MJ = 3412.14 Btu
1 kcal = 0.0041868 MJ = 3.96832 Btu
```

---

## Mass Units

### Mass Unit Conversion Table

| Unit | Symbol | Code | To kg Conversion | Description |
|------|--------|------|------------------|-------------|
| **Kilogram** | kg | `KG` | 1.0 | SI base unit of mass |
| **Pound Mass** | lbm | `LBM` | 0.45359237 | Imperial unit of mass |
| **Metric Ton (Tonne)** | mt, t | `MT` | 1000.0 | 1,000 kg |
| **Long Ton** | lt | `LT` | 1016.0469088 | Imperial ton (UK) |
| **Short Ton** | st | `ST` | 907.18474 | US ton (2,000 lbs) |
| **Gram** | g | `G` | 0.001 | Gram |
| **Milligram** | mg | `MG` | 0.000001 | Milligram |

### Conversion Examples

```
1 mt = 1,000 kg = 2,204.62 lbm
1 lt = 1,016.047 kg = 1.016047 mt
1 st = 907.185 kg = 0.907185 mt
1 lbm = 0.453592 kg
```

---

## Volume Units

Volume units are divided into **actual volume** and **standard volume** (at reference conditions).

### Actual Volume Units

| Unit | Symbol | Code | To m³ Conversion | Description |
|------|--------|------|------------------|-------------|
| **Cubic Meter** | m³ | `M3` | 1.0 | SI unit of volume |
| **Cubic Foot** | ft³ | `FT3` | 0.0283168466 | Imperial volume unit |
| **Liter** | L | `L` | 0.001 | Liter |
| **US Gallon** | gal | `GAL` | 0.0037854118 | US gallon |
| **Imperial Gallon** | Imp gal | `IGAL` | 0.0045460900 | UK imperial gallon |
| **Barrel** | bbl | `BBL` | 0.1589872949 | Barrel (petroleum) |

### Standard Volume Units

Standard volumes are measured at specific reference conditions (temperature and pressure).

| Unit | Symbol | Code | Reference Conditions | Description |
|------|--------|------|---------------------|-------------|
| **Standard Cubic Meter** | Sm³ | `SM3` | 15°C, 101.325 kPa | ISO 6976 standard |
| **Sm³ at 0°C** | Sm³(0°C) | `SM3_0C` | 0°C, 101.325 kPa | Alternative reference |
| **Sm³ at 25°C** | Sm³(25°C) | `SM3_25C` | 25°C, 101.325 kPa | Alternative reference |
| **Standard Cubic Foot** | scf | `SCF` | 60°F, 14.696 psia | US/ASTM standard |
| **scf at 60°F** | scf(60°F) | `SCF_60F` | 60°F, 14.696 psia | Explicit 60°F reference |
| **Normal Cubic Meter** | Nm³ | `NM3` | 0°C, 101.325 kPa | ISO 2533 normal conditions |
| **Normal Cubic Foot** | Ncf | `NCF` | 0°C, 101.325 kPa | Normal conditions |

### Reference Conditions Summary

| Volume Type | Temperature | Pressure | Standard |
|-------------|-------------|----------|----------|
| **Sm³ (ISO)** | 15°C (59°F) | 101.325 kPa (14.696 psia) | ISO 6976 |
| **scf (ASTM)** | 60°F (15.56°C) | 14.696 psia (101.325 kPa) | ASTM |
| **Nm³ (Normal)** | 0°C (32°F) | 101.325 kPa (14.696 psia) | ISO 2533 |

---

## Combined Units - Heating Values

Heating values (calorific values) are expressed as energy per unit mass or energy per unit volume.

### Heating Value by Mass

Format: `{Energy Unit} / {Mass Unit} at {Temperature Reference}`

#### Complete List of Mass-Based Heating Value Units

| Unit Display | Code | Abbreviated Form | Common | Description |
|--------------|------|------------------|--------|-------------|
| **MJ/kg at 0°C** | `MJ_KG_0C` | `MJ0/kg` | ✓ | Megajoules per kg at 0°C |
| **MJ/kg at 15°C** | `MJ_KG_15C` | `MJ1/kg` | ✓ | Megajoules per kg at 15°C (ISO standard) |
| **MJ/kg at 25°C** | `MJ_KG_25C` | `MJ2/kg` | ✓ | Megajoules per kg at 25°C |
| **Btu/kg at 60°F** | `BTU_KG_60F` | `B6/kg` | ✓ | BTU per kg at 60°F |
| **Btu/kg** | `BTU_KG` | `Btu/kg` | ✓ | BTU per kg |
| **Btu/lbm at 60°F** | `BTU_LBM_60F` | `B6/lbm` | ✓ | BTU per pound-mass at 60°F (common in US) |
| **Btu/lbm** | `BTU_LBM` | `Btu/lbm` | ✓ | BTU per pound-mass |
| **kWh/kg at 15°C** | `KWH_KG_15C` | `kWh1/kg` | | Kilowatt-hours per kg at 15°C |
| **kWh/kg** | `KWH_KG` | `kWh/kg` | | Kilowatt-hours per kg |
| **kcal/kg at 15°C** | `KCAL_KG_15C` | `kcal1/kg` | | Kilocalories per kg at 15°C |
| **kcal/kg** | `KCAL_KG` | `kcal/kg` | | Kilocalories per kg |
| **th/kg** | `THERM_KG` | `th/kg` | | Thermie per kg |

### Heating Value by Volume

Format: `{Energy Unit} / {Volume Unit} at {Temperature Reference}`

#### Complete List of Volume-Based Heating Value Units

| Unit Display | Code | Abbreviated Form | Common | Description |
|--------------|------|------------------|--------|-------------|
| **MJ/Sm³ at 0°C** | `MJ_SM3_0C` | `MJ0/Sm3` | ✓ | MJ per Sm³ at 0°C |
| **MJ/Sm³ at 15°C** | `MJ_SM3_15C` | `MJ1/Sm3` | ✓ | MJ per Sm³ at 15°C (ISO standard) |
| **MJ/Sm³ at 25°C** | `MJ_SM3_25C` | `MJ2/Sm3` | | MJ per Sm³ at 25°C |
| **MJ/m³** | `MJ_M3` | `MJ/m3` | | MJ per actual m³ |
| **Btu/scf at 60°F** | `BTU_SCF_60F` | `B6/Scf` | ✓ | Btu per scf at 60°F (common in US) |
| **Btu/scf** | `BTU_SCF` | `Btu/scf` | ✓ | Btu per standard cubic foot |
| **Btu/ft³ at 60°F** | `BTU_FT3_60F` | `B6/ft3` | | Btu per actual ft³ at 60°F |
| **Btu/ft³** | `BTU_FT3` | `Btu/ft3` | | Btu per actual cubic foot |
| **Btu/m³** | `BTU_M3` | `Btu/m3` | | Btu per cubic meter |
| **kWh/Sm³ at 15°C** | `KWH_SM3_15C` | `kWh1/Sm3` | | kWh per Sm³ at 15°C |
| **kWh/m³** | `KWH_M3` | `kWh/m3` | | kWh per cubic meter |
| **kcal/Sm³ at 15°C** | `KCAL_SM3_15C` | `kcal1/Sm3` | | kcal per Sm³ at 15°C |
| **kcal/m³** | `KCAL_M3` | `kcal/m3` | | kcal per cubic meter |
| **th/m³** | `THERM_M3` | `th/m3` | | Thermie per cubic meter |

### Conversion Examples

#### By Mass
```
1 MJ/kg = 429.923 Btu/lbm
1 Btu/lbm = 0.002326 MJ/kg
1 MJ/kg = 0.2778 kWh/kg
```

#### By Volume
```
1 MJ/Sm³ (at 15°C) ≈ 26.84 Btu/scf (at 60°F)  [depends on gas composition]
1 Btu/scf (at 60°F) ≈ 0.0373 MJ/Sm³ (at 15°C)
```

---

## Pressure Units

### Pressure Unit Conversion Table

Pressure can be expressed as **absolute** (referenced to perfect vacuum) or **gauge** (referenced to atmospheric pressure).

| Unit | Symbol | Code | To kPa Conversion | Type | Description |
|------|--------|------|-------------------|------|-------------|
| **Kilopascal** | kPa | `KPA` | 1.0 | Absolute | SI unit of pressure |
| **kPa Absolute** | kPa(a) | `KPAA` | 1.0 | Absolute | Explicit absolute pressure |
| **kPa Gauge** | kPa(g) | `KPAG` | 1.0 | Gauge | Gauge pressure |
| **Megapascal** | MPa | `MPA` | 1000.0 | Absolute | 1,000 kPa |
| **Bar** | bar | `BAR` | 100.0 | Absolute | Bar |
| **bar Absolute** | bar(a) | `BARA` | 100.0 | Absolute | Explicit absolute |
| **bar Gauge** | bar(g) | `BARG` | 100.0 | Gauge | Gauge pressure |
| **Millibar** | mbar | `MBAR` | 0.1 | Absolute | Millibar |
| **mbar Absolute** | mbar(a) | `MBARA` | 0.1 | Absolute | Explicit absolute |
| **mbar Gauge** | mbar(g) | `MBARG` | 0.1 | Gauge | Gauge pressure |
| **PSI** | psi | `PSI` | 6.8947572932 | Absolute | Pounds per square inch |
| **psia** | psia | `PSIA` | 6.8947572932 | Absolute | Absolute pressure |
| **psig** | psig | `PSIG` | 6.8947572932 | Gauge | Gauge pressure |
| **Atmosphere** | atm | `ATM` | 101.325 | Absolute | Standard atmosphere |
| **mmHg (Torr)** | mmHg | `MMHG` | 0.1333223684 | Absolute | Millimeter of mercury |

### Pressure Conversion Examples

```
1 bar = 100 kPa = 14.5038 psi = 1000 mbar
1 MPa = 1000 kPa = 10 bar = 145.038 psi
1 atm = 101.325 kPa = 1.01325 bar = 14.696 psi
1 psi = 6.89476 kPa = 0.0689476 bar = 68.9476 mbar
```

### Absolute vs Gauge Pressure

- **Absolute Pressure (a)**: Measured relative to perfect vacuum
  - `P(absolute) = P(gauge) + P(atmospheric)`
  - Used for: Vapor pressure, critical pressure, thermodynamic calculations

- **Gauge Pressure (g)**: Measured relative to atmospheric pressure
  - `P(gauge) = P(absolute) - P(atmospheric)`
  - Used for: Tank pressures, line pressures, equipment ratings

---

## Length and Speed Units

### Length Units

| Unit | Symbol | Code | To m Conversion | Description |
|------|--------|------|-----------------|-------------|
| **Meter** | m | `M` | 1.0 | SI unit of length |
| **Centimeter** | cm | `CM` | 0.01 | Centimeter |
| **Millimeter** | mm | `MM` | 0.001 | Millimeter |
| **Kilometer** | km | `KM` | 1000.0 | Kilometer |
| **Foot** | ft | `FT` | 0.3048 | Imperial foot |
| **Inch** | in | `IN` | 0.0254 | Inch |
| **Yard** | yd | `YD` | 0.9144 | Yard |
| **Statute Mile** | mi | `MI` | 1609.344 | Land mile |
| **Nautical Mile** | nm | `NM` | 1852.0 | Sea mile |

### Speed Units

| Unit | Symbol | Code | To m/s Conversion | Description |
|------|--------|------|-------------------|-------------|
| **Meters per Second** | m/s | `MS` | 1.0 | SI unit of speed |
| **Kilometers per Hour** | km/h | `KMH` | 0.2777777778 | km/h |
| **Knots** | kn | `KN` | 0.5144444444 | Nautical miles/hour |
| **Miles per Hour** | mph | `MPH` | 0.4470400000 | Statute miles/hour |
| **Feet per Second** | ft/s | `FTS` | 0.3048 | Feet/second |

### Conversion Examples

```
1 m = 3.28084 ft = 39.3701 in
1 nm = 1.852 km = 1.15078 mi
1 kn = 1.852 km/h = 0.514444 m/s = 1.15078 mph
```

---

## Flow Rate Units

Flow rates are critical for loading/discharging operations.

### Liquid Flow Rate Units

| Unit Display | Code | Time Period | To m³/h Conversion | Description |
|--------------|------|-------------|-------------------|-------------|
| **m³/hr** | `M3H` | hour | 1.0 | Cubic meters per hour |
| **m³/day** | `M3D` | day | 0.0416666667 | Cubic meters per day |
| **L/hr** | `LH` | hour | 0.001 | Liters per hour |
| **GPM** | `GPM` | minute | 0.2271247 | US gallons per minute |
| **bbl/hr** | `BBLH` | hour | 0.1589872949 | Barrels per hour |
| **ft³/hr** | `FT3H` | hour | 0.0283168466 | Cubic feet per hour |

### Vapor Flow Rate Units

| Unit Display | Code | Time Period | To m³/h Conversion | Description |
|--------------|------|-------------|-------------------|-------------|
| **Sm³/hr** | `SM3H` | hour | 1.0 | Standard cubic meters per hour |
| **scf/hr** | `SCFH` | hour | 0.0283168466 | Standard cubic feet per hour |
| **scfm** | `SCFM` | minute | 1.6990108 | Standard cubic feet per minute |
| **Nm³/hr** | `NM3H` | hour | 1.0 | Normal cubic meters per hour |

### Flow Rate Conversion Examples

```
1 m³/hr = 4.4029 GPM = 0.5886 bbl/hr = 35.3147 ft³/hr
1,000 m³/hr = 4,403 GPM (common terminal liquid rate)
10,000 Sm³/hr (typical vapor return rate)
```

---

## Abbreviation Reference

### Quick Reference Table - Common Abbreviations

#### Measurement Abbreviations in Column Names

| Abbreviation | Meaning | Example Usage |
|--------------|---------|---------------|
| **_m** | meters | `max_loa_m`, `max_draft_m` |
| **_ft** | feet | `max_loa_ft`, `max_draft_ft` |
| **_mt** | metric tons | `deadweight_mt`, `bollard_pull_mt` |
| **_cbm** | cubic meters (volume) | `cargo_capacity_cbm`, `shore_tank_capacity_cbm` |
| **_m3** | cubic meters | `density_liquid_kgm3` (in compound units) |
| **_kn** | knots | `max_transit_speed_kn`, `max_wind_speed_kn` |
| **_kpa** | kilopascals | `vapor_pressure_kpa` |
| **_mbar** | millibars | `arrival_svp_mbar` |
| **_c** | Celsius | `arrival_temp_c`, `reference_temp_c` |
| **_f** | Fahrenheit | `temp_value_f` |
| **_m3h** | cubic meters per hour | `liquid_rate_m3h_max` |
| **_mj_kg** | megajoules per kilogram | `ghv_mj_kg`, `nhv_mj_kg` |
| **_mj_sm3** | MJ per standard cubic meter | `ghv_mj_sm3`, `wobbe_index_mj_sm3` |

#### Energy/Heating Value Abbreviated Forms

| Full Form | Abbreviated Form | Temperature | Basis |
|-----------|------------------|-------------|-------|
| MJ/kg at 0°C | MJ0/kg | 0°C | Mass |
| MJ/kg at 15°C | MJ1/kg | 15°C | Mass |
| MJ/kg at 25°C | MJ2/kg | 25°C | Mass |
| Btu/lbm at 60°F | B6/lbm | 60°F | Mass |
| MJ/Sm³ at 0°C | MJ0/Sm3 | 0°C | Volume |
| MJ/Sm³ at 15°C | MJ1/Sm3 | 15°C | Volume |
| MJ/Sm³ at 25°C | MJ2/Sm3 | 25°C | Volume |
| Btu/scf at 60°F | B6/Scf | 60°F | Volume |

#### Compound Unit Patterns

```
Pattern: {value}_{primaryunit}{secondaryunit}

Examples:
kgm3         = kg/m³ (density)
m3h          = m³/hour (flow rate)
mj_kg        = MJ/kg (specific energy)
btu_scf      = Btu/scf (volumetric energy)
knm          = kN·m (moment/torque)
```

### Property/Attribute Abbreviations

| Abbreviation | Full Term |
|--------------|-----------|
| **loa** | Length Overall |
| **dwt** | Deadweight Tonnage |
| **grt** | Gross Registered Tonnage |
| **nrt** | Net Registered Tonnage |
| **cbm** | Cubic Meters (capacity) |
| **bog** | Boil-Off Gas |
| **svp** | Saturated Vapor Pressure |
| **ghv** | Gross Heating Value |
| **nhv** | Net Heating Value (Lower Heating Value) |
| **hv** | Heating Value |
| **nbp** | Normal Boiling Point |
| **swl** | Safe Working Load |
| **mbl** | Minimum Breaking Load |
| **cou** | Conditions of Use |
| **pla** | Port Liability Agreement |
| **tsa** | Terminal Services Agreement |
| **nor** | Notice of Readiness |
| **eta** | Estimated Time of Arrival |
| **ata** | Actual Time of Arrival |
| **etd** | Estimated Time of Departure |
| **atd** | Actual Time of Departure |
| **utc** | Coordinated Universal Time |
| **imo** | International Maritime Organization |
| **mmsi** | Maritime Mobile Service Identity |

---

## Usage Guidelines

### When Storing Data

1. **Always store in base SI units AND common imperial units**
   - Example: Store both `max_draft_m` and `max_draft_ft`
   - Enables queries without conversion calculations

2. **Use standardized columns for heating values**
   - Store original value with original unit
   - Also store converted value in standard unit (MJ/kg or MJ/Sm³)

3. **Include unit reference IDs**
   - Link to `ref_heating_value_mass_unit` or `ref_heating_value_volume_unit`
   - Preserves exact unit and temperature reference

4. **Temperature references matter**
   - Always specify temperature for heating values
   - Use appropriate `temp_std_id` foreign key

### Query Examples

#### Example 1: Find all terminals accepting vessels over 300m

```sql
SELECT terminal_name, max_loa_m, max_loa_ft
FROM v_terminal_current
WHERE max_loa_m >= 300
ORDER BY max_loa_m DESC;
```

#### Example 2: Get cargo heating values in multiple units

```sql
SELECT
    cb.cargo_name,
    cb.sample_date,
    chv.ghv_mj_kg AS ghv_mj_per_kg,
    chv.ghv_mj_kg * 429.923 AS ghv_btu_per_lbm,
    chv.ghv_mj_sm3 AS ghv_mj_per_sm3,
    chv.wobbe_index_mj_sm3
FROM lng_cargo_batch cb
JOIN lng_cargo_heating_value chv ON cb.cargo_batch_id = chv.cargo_batch_id
WHERE cb.is_current = true;
```

#### Example 3: Find compatible terminals for a specific vessel draft

```sql
SELECT
    t.terminal_name,
    tdr.max_draft_m,
    tdr.depth_at_berth_m,
    (tdr.depth_at_berth_m - 12.5) AS underkeel_clearance_m
FROM terminal t
JOIN terminal_dimension_restriction tdr
    ON t.terminal_id = tdr.terminal_id
    AND tdr.is_current = true
WHERE tdr.max_draft_m >= 12.5  -- Vessel draft
    AND tdr.depth_at_berth_m >= 13.5  -- Minimum depth with UKC
ORDER BY tdr.max_draft_m;
```

---

## Summary of Key Principles

1. **Consistency**: All measurements follow the same naming pattern throughout the database
2. **Clarity**: Unit suffixes make it immediately clear what unit is being used
3. **Dual Units**: Critical measurements stored in both metric and imperial
4. **Standards Compliance**: Follows ISO, ASTM, and SIGTTO standards
5. **Traceability**: Unit reference tables provide complete conversion factors
6. **Flexibility**: Supports all common unit combinations used in LNG industry
7. **Historical Accuracy**: Temperature references preserved for accurate comparisons

---

## Reference Standards

- **ISO 6976:2016** - Natural gas — Calculation of calorific values, density, relative density and Wobbe indices from composition
- **ISO 2533:1975** - Standard Atmosphere
- **ASTM D3588** - Standard Practice for Calculating Heat Value, Compressibility Factor, and Relative Density of Gaseous Fuels
- **SIGTTO** - Liquefied Gas Handling Principles on Ships and in Terminals
- **GIIGNL** - International Group of Liquefied Natural Gas Importers
- **IGC Code** - International Code for the Construction and Equipment of Ships Carrying Liquefied Gases in Bulk

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Maintained By**: LNG Terminal Database Project
