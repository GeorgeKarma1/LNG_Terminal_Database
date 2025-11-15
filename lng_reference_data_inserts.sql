-- ============================================================================
-- LNG TERMINAL DATABASE - REFERENCE DATA INSERTS
-- ============================================================================
-- Comprehensive reference data for measurement units and lookup tables
-- ============================================================================
-- Version: 1.0
-- Created: 2025-11-15
-- ============================================================================

-- ============================================================================
-- TEMPERATURE STANDARDS
-- ============================================================================

INSERT INTO ref_temperature_standard (temp_std_code, temp_std_name, temp_value_c, temp_value_f, temp_value_k, is_iso_standard, description) VALUES
('T0C', '0°C', 0.00, 32.00, 273.15, true, 'Zero degrees Celsius - ISO 6976 reference'),
('T15C', '15°C', 15.00, 59.00, 288.15, true, 'Fifteen degrees Celsius - ISO 6976 standard'),
('T20C', '20°C', 20.00, 68.00, 293.15, true, 'Twenty degrees Celsius'),
('T25C', '25°C', 25.00, 77.00, 298.15, false, 'Twenty-five degrees Celsius'),
('T32F', '32°F', 0.00, 32.00, 273.15, false, 'Thirty-two degrees Fahrenheit (freezing point)'),
('T60F', '60°F', 15.56, 60.00, 288.71, true, 'Sixty degrees Fahrenheit - ASTM standard'),
('T68F', '68°F', 20.00, 68.00, 293.15, false, 'Sixty-eight degrees Fahrenheit');

-- ============================================================================
-- ENERGY UNITS
-- ============================================================================

INSERT INTO ref_energy_unit (energy_unit_code, energy_unit_name, energy_unit_symbol, to_mj_conversion, description) VALUES
('MJ', 'Megajoule', 'MJ', 1.0000000000, 'SI unit of energy'),
('BTU', 'British Thermal Unit', 'Btu', 0.0010551, 'Imperial unit - ISO BTU'),
('BTUIT', 'British Thermal Unit (IT)', 'Btu(IT)', 0.0010550559, 'International Table BTU'),
('BTU59F', 'British Thermal Unit at 59°F', 'Btu₅₉', 0.0010548, 'BTU at 59°F'),
('BTU60F', 'British Thermal Unit at 60°F', 'Btu₆₀', 0.00105506, 'BTU at 60°F'),
('KWH', 'Kilowatt-hour', 'kWh', 3.6000000000, 'Electrical energy unit'),
('KCAL', 'Kilocalorie', 'kcal', 0.0041868, 'Thermochemical calorie'),
('KCAL15', 'Kilocalorie at 15°C', 'kcal₁₅', 0.0041855, 'Calorie at 15°C'),
('THERM', 'Thermie', 'th', 4.1868000000, 'Metric thermie = 1000 kcal'),
('GJ', 'Gigajoule', 'GJ', 1000.0000000000, 'One thousand megajoules'),
('MMBTU', 'Million BTU', 'MMBtu', 1055.0600000000, 'One million BTU');

-- ============================================================================
-- MASS UNITS
-- ============================================================================

INSERT INTO ref_mass_unit (mass_unit_code, mass_unit_name, mass_unit_symbol, to_kg_conversion, description) VALUES
('KG', 'Kilogram', 'kg', 1.0000000000, 'SI base unit of mass'),
('LBM', 'Pound Mass', 'lbm', 0.45359237, 'Imperial unit of mass'),
('LB', 'Pound', 'lb', 0.45359237, 'Pound (same as lbm)'),
('MT', 'Metric Ton', 'mt', 1000.0000000000, 'Tonne = 1000 kg'),
('T', 'Tonne', 't', 1000.0000000000, 'Metric tonne'),
('LT', 'Long Ton', 'lt', 1016.0469088, 'Imperial ton (UK)'),
('ST', 'Short Ton', 'st', 907.18474, 'US ton'),
('G', 'Gram', 'g', 0.0010000000, 'Gram'),
('MG', 'Milligram', 'mg', 0.0000010000, 'Milligram'),
('UG', 'Microgram', 'μg', 0.0000000010, 'Microgram');

-- ============================================================================
-- VOLUME UNITS
-- ============================================================================

INSERT INTO ref_volume_unit (volume_unit_code, volume_unit_name, volume_unit_symbol, is_standard_condition, reference_temp_c, reference_pressure_kpa, to_m3_conversion, description) VALUES
-- Actual Volume Units
('M3', 'Cubic Meter', 'm³', false, NULL, NULL, 1.0000000000, 'SI unit of volume'),
('FT3', 'Cubic Foot', 'ft³', false, NULL, NULL, 0.0283168466, 'Imperial volume unit'),
('L', 'Liter', 'L', false, NULL, NULL, 0.0010000000, 'Liter'),
('GAL', 'US Gallon', 'gal', false, NULL, NULL, 0.0037854118, 'US gallon'),
('IGAL', 'Imperial Gallon', 'Imp gal', false, NULL, NULL, 0.0045460900, 'UK imperial gallon'),
('BBL', 'Barrel', 'bbl', false, NULL, NULL, 0.1589872949, 'Barrel (petroleum)'),

-- Standard Volume Units (ISO 6976: 15°C, 101.325 kPa)
('SM3', 'Standard Cubic Meter', 'Sm³', true, 15.00, 101.325, 1.0000000000, 'Standard conditions: 15°C, 101.325 kPa'),
('SM3_0C', 'Standard Cubic Meter at 0°C', 'Sm³(0°C)', true, 0.00, 101.325, 1.0000000000, 'Standard conditions: 0°C, 101.325 kPa'),
('SM3_25C', 'Standard Cubic Meter at 25°C', 'Sm³(25°C)', true, 25.00, 101.325, 1.0000000000, 'Standard conditions: 25°C, 101.325 kPa'),

-- Standard Cubic Feet (US standard: 60°F, 14.696 psi = 101.325 kPa)
('SCF', 'Standard Cubic Foot', 'scf', true, 15.56, 101.325, 0.0283168466, 'Standard conditions: 60°F, 14.696 psia'),
('SCF_32F', 'Standard Cubic Foot at 32°F', 'scf(32°F)', true, 0.00, 101.325, 0.0283168466, 'Standard conditions: 32°F, 14.696 psia'),
('SCF_60F', 'Standard Cubic Foot at 60°F', 'scf(60°F)', true, 15.56, 101.325, 0.0283168466, 'Standard conditions: 60°F, 14.696 psia'),

-- Normal Volume Units (ISO 2533: 0°C, 101.325 kPa)
('NM3', 'Normal Cubic Meter', 'Nm³', true, 0.00, 101.325, 1.0000000000, 'Normal conditions: 0°C, 101.325 kPa'),
('NCF', 'Normal Cubic Foot', 'Ncf', true, 0.00, 101.325, 0.0283168466, 'Normal conditions: 0°C, 101.325 kPa');

-- ============================================================================
-- HEATING VALUE MASS UNITS (Energy per Mass)
-- ============================================================================

-- MJ/kg combinations at different temperatures
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'MJ_KG_0C', 'MJ/kg at 0°C', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'MJ0/kg', 1.0000000000, true, 'Megajoules per kilogram at 0°C'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T0C';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'MJ_KG_15C', 'MJ/kg at 15°C', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'MJ1/kg', 1.0000000000, true, 'Megajoules per kilogram at 15°C (ISO 6976)'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'MJ_KG_25C', 'MJ/kg at 25°C', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'MJ2/kg', 1.0000000000, true, 'Megajoules per kilogram at 25°C'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T25C';

-- BTU/kg combinations
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'BTU_KG_60F', 'Btu/kg at 60°F', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'B6/kg', 0.0010550559, true, 'BTU per kilogram at 60°F'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'BTU' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T60F';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'BTU_KG', 'Btu/kg', e.energy_unit_id, m.mass_unit_id, NULL, 'Btu/kg', 0.0010550559, true, 'BTU per kilogram'
FROM ref_energy_unit e, ref_mass_unit m
WHERE e.energy_unit_code = 'BTU' AND m.mass_unit_code = 'KG';

-- BTU/lbm combinations
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'BTU_LBM_60F', 'Btu/lbm at 60°F', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'B6/lbm', 0.0023260, true, 'BTU per pound-mass at 60°F'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'BTU' AND m.mass_unit_code = 'LBM' AND t.temp_std_code = 'T60F';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'BTU_LBM', 'Btu/lbm', e.energy_unit_id, m.mass_unit_id, NULL, 'Btu/lbm', 0.0023260, true, 'BTU per pound-mass'
FROM ref_energy_unit e, ref_mass_unit m
WHERE e.energy_unit_code = 'BTU' AND m.mass_unit_code = 'LBM';

-- kWh/kg combinations
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'KWH_KG_15C', 'kWh/kg at 15°C', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'kWh1/kg', 3.6000000000, false, 'Kilowatt-hours per kilogram at 15°C'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'KWH' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'KWH_KG', 'kWh/kg', e.energy_unit_id, m.mass_unit_id, NULL, 'kWh/kg', 3.6000000000, false, 'Kilowatt-hours per kilogram'
FROM ref_energy_unit e, ref_mass_unit m
WHERE e.energy_unit_code = 'KWH' AND m.mass_unit_code = 'KG';

-- kcal/kg combinations
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'KCAL_KG_15C', 'kcal/kg at 15°C', e.energy_unit_id, m.mass_unit_id, t.temp_std_id, 'kcal1/kg', 0.0041855, false, 'Kilocalories per kilogram at 15°C'
FROM ref_energy_unit e, ref_mass_unit m, ref_temperature_standard t
WHERE e.energy_unit_code = 'KCAL15' AND m.mass_unit_code = 'KG' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'KCAL_KG', 'kcal/kg', e.energy_unit_id, m.mass_unit_id, NULL, 'kcal/kg', 0.0041868, false, 'Kilocalories per kilogram'
FROM ref_energy_unit e, ref_mass_unit m
WHERE e.energy_unit_code = 'KCAL' AND m.mass_unit_code = 'KG';

-- Thermie/kg combinations
INSERT INTO ref_heating_value_mass_unit (unit_code, unit_display, energy_unit_id, mass_unit_id, temp_std_id, abbreviated_form, to_mj_kg_conversion, is_common, description)
SELECT 'THERM_KG', 'th/kg', e.energy_unit_id, m.mass_unit_id, NULL, 'th/kg', 4.1868000000, false, 'Thermie per kilogram'
FROM ref_energy_unit e, ref_mass_unit m
WHERE e.energy_unit_code = 'THERM' AND m.mass_unit_code = 'KG';

-- ============================================================================
-- HEATING VALUE VOLUME UNITS (Energy per Volume)
-- ============================================================================

-- MJ/Sm³ combinations at different temperatures
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'MJ_SM3_0C', 'MJ/Sm³ at 0°C', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'MJ0/Sm3', 1.0000000000, true, 'Megajoules per standard cubic meter at 0°C'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND v.volume_unit_code = 'SM3_0C' AND t.temp_std_code = 'T0C';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'MJ_SM3_15C', 'MJ/Sm³ at 15°C', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'MJ1/Sm3', 1.0000000000, true, 'Megajoules per standard cubic meter at 15°C (ISO 6976)'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND v.volume_unit_code = 'SM3' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'MJ_SM3_25C', 'MJ/Sm³ at 25°C', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'MJ2/Sm3', 1.0000000000, false, 'Megajoules per standard cubic meter at 25°C'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'MJ' AND v.volume_unit_code = 'SM3_25C' AND t.temp_std_code = 'T25C';

-- MJ/m³ (actual volume)
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'MJ_M3', 'MJ/m³', e.energy_unit_id, v.volume_unit_id, NULL, 'MJ/m3', 1.0000000000, false, 'Megajoules per actual cubic meter'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'MJ' AND v.volume_unit_code = 'M3';

-- BTU/scf combinations
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'BTU_SCF_60F', 'Btu/scf at 60°F', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'B6/Scf', 0.0372589, true, 'BTU per standard cubic foot at 60°F'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'BTU' AND v.volume_unit_code = 'SCF_60F' AND t.temp_std_code = 'T60F';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'BTU_SCF', 'Btu/scf', e.energy_unit_id, v.volume_unit_id, NULL, 'Btu/scf', 0.0372589, true, 'BTU per standard cubic foot'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'BTU' AND v.volume_unit_code = 'SCF';

-- BTU/ft³ (actual volume)
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'BTU_FT3_60F', 'Btu/ft³ at 60°F', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'B6/ft3', 0.0372589, false, 'BTU per actual cubic foot at 60°F'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'BTU' AND v.volume_unit_code = 'FT3' AND t.temp_std_code = 'T60F';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'BTU_FT3', 'Btu/ft³', e.energy_unit_id, v.volume_unit_id, NULL, 'Btu/ft3', 0.0372589, false, 'BTU per actual cubic foot'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'BTU' AND v.volume_unit_code = 'FT3';

-- BTU/m³
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'BTU_M3', 'Btu/m³', e.energy_unit_id, v.volume_unit_id, NULL, 'Btu/m3', 0.0010550559, false, 'BTU per cubic meter'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'BTU' AND v.volume_unit_code = 'M3';

-- kWh/m³ combinations
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'KWH_SM3_15C', 'kWh/Sm³ at 15°C', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'kWh1/Sm3', 3.6000000000, false, 'Kilowatt-hours per standard cubic meter at 15°C'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'KWH' AND v.volume_unit_code = 'SM3' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'KWH_M3', 'kWh/m³', e.energy_unit_id, v.volume_unit_id, NULL, 'kWh/m3', 3.6000000000, false, 'Kilowatt-hours per cubic meter'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'KWH' AND v.volume_unit_code = 'M3';

-- kcal/m³ combinations
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'KCAL_SM3_15C', 'kcal/Sm³ at 15°C', e.energy_unit_id, v.volume_unit_id, t.temp_std_id, 'kcal1/Sm3', 0.0041855, false, 'Kilocalories per standard cubic meter at 15°C'
FROM ref_energy_unit e, ref_volume_unit v, ref_temperature_standard t
WHERE e.energy_unit_code = 'KCAL15' AND v.volume_unit_code = 'SM3' AND t.temp_std_code = 'T15C';

INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'KCAL_M3', 'kcal/m³', e.energy_unit_id, v.volume_unit_id, NULL, 'kcal/m3', 0.0041868, false, 'Kilocalories per cubic meter'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'KCAL' AND v.volume_unit_code = 'M3';

-- Thermie/m³ combinations
INSERT INTO ref_heating_value_volume_unit (unit_code, unit_display, energy_unit_id, volume_unit_id, temp_std_id, abbreviated_form, to_mj_sm3_conversion, is_common, description)
SELECT 'THERM_M3', 'th/m³', e.energy_unit_id, v.volume_unit_id, NULL, 'th/m3', 4.1868000000, false, 'Thermie per cubic meter'
FROM ref_energy_unit e, ref_volume_unit v
WHERE e.energy_unit_code = 'THERM' AND v.volume_unit_code = 'M3';

-- ============================================================================
-- PRESSURE UNITS
-- ============================================================================

INSERT INTO ref_pressure_unit (pressure_unit_code, pressure_unit_name, pressure_unit_symbol, to_kpa_conversion, is_absolute, description) VALUES
('KPA', 'Kilopascal', 'kPa', 1.0000000000, true, 'SI unit of pressure'),
('KPAA', 'Kilopascal Absolute', 'kPa(a)', 1.0000000000, true, 'Absolute pressure in kPa'),
('KPAG', 'Kilopascal Gauge', 'kPa(g)', 1.0000000000, false, 'Gauge pressure in kPa'),
('MPA', 'Megapascal', 'MPa', 1000.0000000000, true, 'Megapascal'),
('MPAA', 'Megapascal Absolute', 'MPa(a)', 1000.0000000000, true, 'Absolute pressure in MPa'),
('MPAG', 'Megapascal Gauge', 'MPa(g)', 1000.0000000000, false, 'Gauge pressure in MPa'),
('BAR', 'Bar', 'bar', 100.0000000000, true, 'Bar'),
('BARA', 'Bar Absolute', 'bar(a)', 100.0000000000, true, 'Absolute pressure in bar'),
('BARG', 'Bar Gauge', 'bar(g)', 100.0000000000, false, 'Gauge pressure in bar'),
('MBAR', 'Millibar', 'mbar', 0.1000000000, true, 'Millibar'),
('MBARA', 'Millibar Absolute', 'mbar(a)', 0.1000000000, true, 'Absolute pressure in mbar'),
('MBARG', 'Millibar Gauge', 'mbar(g)', 0.1000000000, false, 'Gauge pressure in mbar'),
('PSI', 'Pounds per Square Inch', 'psi', 6.8947572932, true, 'Imperial pressure unit'),
('PSIA', 'PSI Absolute', 'psia', 6.8947572932, true, 'Absolute pressure in psi'),
('PSIG', 'PSI Gauge', 'psig', 6.8947572932, false, 'Gauge pressure in psi'),
('ATM', 'Atmosphere', 'atm', 101.3250000000, true, 'Standard atmosphere'),
('MMHG', 'Millimeter of Mercury', 'mmHg', 0.1333223684, true, 'Torr'),
('INH2O', 'Inch of Water', 'inH₂O', 0.2490820000, false, 'Inch of water column'),
('PA', 'Pascal', 'Pa', 0.0010000000, true, 'Pascal');

-- ============================================================================
-- LENGTH UNITS
-- ============================================================================

INSERT INTO ref_length_unit (length_unit_code, length_unit_name, length_unit_symbol, to_m_conversion, description) VALUES
('M', 'Meter', 'm', 1.0000000000, 'SI unit of length'),
('CM', 'Centimeter', 'cm', 0.0100000000, 'Centimeter'),
('MM', 'Millimeter', 'mm', 0.0010000000, 'Millimeter'),
('KM', 'Kilometer', 'km', 1000.0000000000, 'Kilometer'),
('FT', 'Foot', 'ft', 0.3048000000, 'Imperial foot'),
('IN', 'Inch', 'in', 0.0254000000, 'Inch'),
('YD', 'Yard', 'yd', 0.9144000000, 'Yard'),
('MI', 'Mile', 'mi', 1609.3440000000, 'Statute mile'),
('NM', 'Nautical Mile', 'nm', 1852.0000000000, 'International nautical mile');

-- ============================================================================
-- SPEED UNITS
-- ============================================================================

INSERT INTO ref_speed_unit (speed_unit_code, speed_unit_name, speed_unit_symbol, to_ms_conversion, description) VALUES
('MS', 'Meters per Second', 'm/s', 1.0000000000, 'SI unit of speed'),
('KMH', 'Kilometers per Hour', 'km/h', 0.2777777778, 'Kilometers per hour'),
('KN', 'Knots', 'kn', 0.5144444444, 'Nautical miles per hour'),
('MPH', 'Miles per Hour', 'mph', 0.4470400000, 'Statute miles per hour'),
('FTS', 'Feet per Second', 'ft/s', 0.3048000000, 'Feet per second'),
('CMS', 'Centimeters per Second', 'cm/s', 0.0100000000, 'Centimeters per second');

-- ============================================================================
-- FLOW RATE UNITS - LIQUID
-- ============================================================================

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'M3H', 'm³/hr', volume_unit_id, 'hour', 1.0000000000, 'Cubic meters per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'M3';

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'M3D', 'm³/day', volume_unit_id, 'day', 0.0416666667, 'Cubic meters per day'
FROM ref_volume_unit WHERE volume_unit_code = 'M3';

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'LH', 'L/hr', volume_unit_id, 'hour', 0.0010000000, 'Liters per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'L';

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'GPM', 'GPM', volume_unit_id, 'minute', 0.2271247, 'US gallons per minute'
FROM ref_volume_unit WHERE volume_unit_code = 'GAL';

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'BBLH', 'bbl/hr', volume_unit_id, 'hour', 0.1589872949, 'Barrels per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'BBL';

INSERT INTO ref_flow_rate_liquid_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'FT3H', 'ft³/hr', volume_unit_id, 'hour', 0.0283168466, 'Cubic feet per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'FT3';

-- ============================================================================
-- FLOW RATE UNITS - VAPOR
-- ============================================================================

INSERT INTO ref_flow_rate_vapor_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'SM3H', 'Sm³/hr', volume_unit_id, 'hour', 1.0000000000, 'Standard cubic meters per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'SM3';

INSERT INTO ref_flow_rate_vapor_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'SCFH', 'scf/hr', volume_unit_id, 'hour', 0.0283168466, 'Standard cubic feet per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'SCF';

INSERT INTO ref_flow_rate_vapor_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'SCFM', 'scfm', volume_unit_id, 'minute', 1.6990108, 'Standard cubic feet per minute'
FROM ref_volume_unit WHERE volume_unit_code = 'SCF';

INSERT INTO ref_flow_rate_vapor_unit (unit_code, unit_display, volume_unit_id, time_period, to_m3h_conversion, description)
SELECT 'NM3H', 'Nm³/hr', volume_unit_id, 'hour', 1.0000000000, 'Normal cubic meters per hour'
FROM ref_volume_unit WHERE volume_unit_code = 'NM3';

-- ============================================================================
-- TERMINAL TYPES
-- ============================================================================

INSERT INTO ref_terminal_type (terminal_type_code, terminal_type_name, description) VALUES
('LOAD', 'Loading Terminal', 'LNG liquefaction and export terminal'),
('DISCHARGE', 'Discharging Terminal', 'LNG import and regasification terminal'),
('DUAL', 'Dual Purpose Terminal', 'Terminal capable of both loading and discharging'),
('FSRU', 'FSRU', 'Floating Storage and Regasification Unit'),
('FSLU', 'FSLU', 'Floating Storage and Liquefaction Unit');

-- ============================================================================
-- TERMINAL STATUS
-- ============================================================================

INSERT INTO ref_terminal_status (status_code, status_name, description) VALUES
('OPERATIONAL', 'In Operation', 'Terminal is currently operational'),
('CONSTRUCTION', 'Under Construction', 'Terminal is under construction'),
('PLANNED', 'Planned', 'Terminal is in planning phase'),
('COMMISSIONING', 'Commissioning', 'Terminal is being commissioned'),
('MAINTENANCE', 'Under Maintenance', 'Terminal is temporarily out of service for maintenance'),
('DECOMMISSIONED', 'Decommissioned', 'Terminal has been decommissioned'),
('SUSPENDED', 'Suspended Operations', 'Terminal operations are temporarily suspended');

-- ============================================================================
-- BERTHING SIDES
-- ============================================================================

INSERT INTO ref_berthing_side (side_code, side_name, description) VALUES
('PORT', 'Port Side', 'Vessel berths on port side'),
('STBD', 'Starboard Side', 'Vessel berths on starboard side'),
('BOTH', 'Both Sides', 'Vessel can berth on either side');

-- ============================================================================
-- BERTHING TIME RESTRICTIONS
-- ============================================================================

INSERT INTO ref_berthing_time (time_code, time_name, description) VALUES
('DAY', 'Daylight Only', 'Berthing operations during daylight hours only'),
('NIGHT', 'Night Only', 'Berthing operations during night hours only'),
('DAYNIGHT', 'Day/Night', 'Berthing operations permitted day or night with restrictions'),
('H24', '24 Hours', 'Berthing operations permitted 24 hours a day'),
('RESTRICTED', 'Time Restricted', 'Specific time window restrictions apply');

-- ============================================================================
-- MANIFOLD CONFIGURATIONS
-- ============================================================================

INSERT INTO ref_manifold_configuration (config_code, config_name, liquid_connections, vapor_connections, configuration_order, description) VALUES
('L_V_L', 'L-V-L', 2, 1, 'L-V-L', 'Two liquid connections with vapor in center'),
('L_L_V_L', 'L-L-V-L', 3, 1, 'L-L-V-L', 'Three liquid connections with vapor'),
('L_V_L_L', 'L-V-L-L', 3, 1, 'L-V-L-L', 'Three liquid connections with vapor'),
('L_L_V_L_L', 'L-L-V-L-L', 4, 1, 'L-L-V-L-L', 'Four liquid connections with vapor'),
('V_L_L', 'V-L-L', 2, 1, 'V-L-L', 'Two liquid connections with vapor at end'),
('L_L_V', 'L-L-V', 2, 1, 'L-L-V', 'Two liquid connections with vapor at end'),
('L_V_V_L', 'L-V-V-L', 2, 2, 'L-V-V-L', 'Two liquid and two vapor connections'),
('L_L_V_V_L', 'L-L-V-V-L', 3, 2, 'L-L-V-V-L', 'Three liquid and two vapor connections');

-- ============================================================================
-- FLANGE STANDARDS
-- ============================================================================

INSERT INTO ref_flange_standard (flange_code, flange_name, standard_type, pressure_rating, nominal_size_in, nominal_size_mm, description) VALUES
('ANSI_150_16IN', '16" ANSI 150', 'ANSI', '150', 16.00, 406.40, '16 inch ANSI Class 150 flange'),
('ANSI_150_16IN_RF', '16" ANSI 150 RF', 'ANSI', '150', 16.00, 406.40, '16 inch ANSI Class 150 raised face'),
('ANSI_300_16IN', '16" ANSI 300', 'ANSI', '300', 16.00, 406.40, '16 inch ANSI Class 300 flange'),
('ANSI_150_12IN', '12" ANSI 150', 'ANSI', '150', 12.00, 304.80, '12 inch ANSI Class 150 flange'),
('ANSI_150_10IN', '10" ANSI 150', 'ANSI', '150', 10.00, 254.00, '10 inch ANSI Class 150 flange'),
('JIS_10K_16IN', '16" JIS 10K', 'JIS', '10K', 16.00, 406.40, '16 inch JIS 10K flange'),
('JIS_20K_16IN', '16" JIS 20K', 'JIS', '20K', 16.00, 406.40, '16 inch JIS 20K flange'),
('BS10_TBL_D_16IN', '16" BS10 Table D', 'BS', 'TABLE_D', 16.00, 406.40, '16 inch BS10 Table D flange'),
('DIN_PN10_16IN', '16" DIN PN10', 'DIN', 'PN10', 16.00, 406.40, '16 inch DIN PN10 flange'),
('DIN_PN16_16IN', '16" DIN PN16', 'DIN', 'PN16', 16.00, 406.40, '16 inch DIN PN16 flange');

-- ============================================================================
-- FLANGE SURFACE FINISHES
-- ============================================================================

INSERT INTO ref_flange_surface_finish (finish_code, finish_name, description) VALUES
('RF', 'Raised Face', 'Raised face flange surface'),
('FF', 'Flat Face', 'Flat face flange surface'),
('RTJ', 'Ring Type Joint', 'Ring type joint groove'),
('SIGTTO', 'SIGTTO Standard', 'SIGTTO recommended surface finish'),
('CUSTOM', 'Custom Finish', 'Custom surface finish specification');

-- ============================================================================
-- GASKET SUPPLY RESPONSIBILITY
-- ============================================================================

INSERT INTO ref_gasket_supply (supply_code, supply_name, description) VALUES
('SHIP', 'Ship Supplied', 'Gaskets supplied by the vessel'),
('SHORE', 'Shore Supplied', 'Gaskets supplied by the terminal'),
('EITHER', 'Either Party', 'Gaskets can be supplied by either party'),
('NEGOTIABLE', 'Negotiable', 'Supply responsibility to be negotiated');

-- ============================================================================
-- MONITORING SYSTEM TYPES
-- ============================================================================

INSERT INTO ref_monitoring_system_type (system_code, system_name, description) VALUES
('OPTICAL', 'Optical Fiber', 'Optical fiber monitoring system'),
('ELECTRICAL', 'Electrical', 'Electrical monitoring system'),
('PNEUMATIC', 'Pneumatic', 'Pneumatic monitoring system'),
('HYDRAULIC', 'Hydraulic', 'Hydraulic monitoring system'),
('MECHANICAL', 'Mechanical', 'Mechanical monitoring system'),
('NONE', 'None', 'No monitoring system');

-- ============================================================================
-- LNG COMPONENTS
-- ============================================================================

INSERT INTO ref_lng_component (component_code, component_name, chemical_formula, molecular_weight, component_group, display_order, description) VALUES
('CH4', 'Methane', 'CH₄', 16.04246, 'Hydrocarbon', 1, 'Primary component of LNG'),
('C2H6', 'Ethane', 'C₂H₆', 30.06904, 'Hydrocarbon', 2, 'Second hydrocarbon component'),
('C3H8', 'Propane', 'C₃H₈', 44.09562, 'Hydrocarbon', 3, 'Heavier hydrocarbon component'),
('IC4H10', 'iso-Butane', 'i-C₄H₁₀', 58.1222, 'Hydrocarbon', 4, 'Branched butane isomer'),
('NC4H10', 'n-Butane', 'n-C₄H₁₀', 58.1222, 'Hydrocarbon', 5, 'Normal butane'),
('IC5H12', 'iso-Pentane', 'i-C₅H₁₂', 72.14878, 'Heavy', 6, 'Branched pentane isomer'),
('NC5H12', 'n-Pentane', 'n-C₅H₁₂', 72.14878, 'Heavy', 7, 'Normal pentane'),
('C6PLUS', 'Hexanes Plus (C6+)', 'C₆+', 86.17536, 'Heavy', 8, 'Hexanes and heavier hydrocarbons'),
('N2', 'Nitrogen', 'N₂', 28.0134, 'Inert', 9, 'Inert component'),
('CO2', 'Carbon Dioxide', 'CO₂', 44.0095, 'Inert', 10, 'Carbon dioxide'),
('H2S', 'Hydrogen Sulfide', 'H₂S', 34.08088, 'Contaminant', 11, 'Sulfur compound'),
('HE', 'Helium', 'He', 4.002602, 'Inert', 12, 'Helium'),
('O2', 'Oxygen', 'O₂', 31.9988, 'Contaminant', 13, 'Oxygen'),
('H2O', 'Water', 'H₂O', 18.01528, 'Contaminant', 14, 'Water vapor'),
('HG', 'Mercury', 'Hg', 200.59, 'Contaminant', 15, 'Mercury contamination');

-- ============================================================================
-- SAMPLE COUNTRY DATA (Top LNG countries)
-- ============================================================================

INSERT INTO ref_country (country_code_iso2, country_code_iso3, country_name, country_name_official, region, sub_region) VALUES
('QA', 'QAT', 'Qatar', 'State of Qatar', 'Asia', 'Western Asia'),
('AU', 'AUS', 'Australia', 'Commonwealth of Australia', 'Oceania', 'Australia and New Zealand'),
('US', 'USA', 'United States', 'United States of America', 'Americas', 'Northern America'),
('JP', 'JPN', 'Japan', 'Japan', 'Asia', 'Eastern Asia'),
('IN', 'IND', 'India', 'Republic of India', 'Asia', 'Southern Asia'),
('CN', 'CHN', 'China', 'People''s Republic of China', 'Asia', 'Eastern Asia'),
('KR', 'KOR', 'South Korea', 'Republic of Korea', 'Asia', 'Eastern Asia'),
('GB', 'GBR', 'United Kingdom', 'United Kingdom of Great Britain and Northern Ireland', 'Europe', 'Northern Europe'),
('ES', 'ESP', 'Spain', 'Kingdom of Spain', 'Europe', 'Southern Europe'),
('FR', 'FRA', 'France', 'French Republic', 'Europe', 'Western Europe'),
('IT', 'ITA', 'Italy', 'Italian Republic', 'Europe', 'Southern Europe'),
('TW', 'TWN', 'Taiwan', 'Taiwan', 'Asia', 'Eastern Asia'),
('OM', 'OMN', 'Oman', 'Sultanate of Oman', 'Asia', 'Western Asia'),
('MY', 'MYS', 'Malaysia', 'Malaysia', 'Asia', 'South-Eastern Asia'),
('NO', 'NOR', 'Norway', 'Kingdom of Norway', 'Europe', 'Northern Europe'),
('DZ', 'DZA', 'Algeria', 'People''s Democratic Republic of Algeria', 'Africa', 'Northern Africa'),
('AE', 'ARE', 'United Arab Emirates', 'United Arab Emirates', 'Asia', 'Western Asia'),
('NG', 'NGA', 'Nigeria', 'Federal Republic of Nigeria', 'Africa', 'Western Africa'),
('TT', 'TTO', 'Trinidad and Tobago', 'Republic of Trinidad and Tobago', 'Americas', 'Caribbean'),
('EG', 'EGY', 'Egypt', 'Arab Republic of Egypt', 'Africa', 'Northern Africa'),
('RU', 'RUS', 'Russia', 'Russian Federation', 'Europe', 'Eastern Europe'),
('ID', 'IDN', 'Indonesia', 'Republic of Indonesia', 'Asia', 'South-Eastern Asia'),
('BN', 'BRN', 'Brunei', 'Brunei Darussalam', 'Asia', 'South-Eastern Asia'),
('PE', 'PER', 'Peru', 'Republic of Peru', 'Americas', 'South America'),
('PG', 'PNG', 'Papua New Guinea', 'Independent State of Papua New Guinea', 'Oceania', 'Melanesia'),
('CL', 'CHL', 'Chile', 'Republic of Chile', 'Americas', 'South America'),
('BR', 'BRA', 'Brazil', 'Federative Republic of Brazil', 'Americas', 'South America'),
('AR', 'ARG', 'Argentina', 'Argentine Republic', 'Americas', 'South America'),
('MX', 'MEX', 'Mexico', 'United Mexican States', 'Americas', 'Central America'),
('PK', 'PAK', 'Pakistan', 'Islamic Republic of Pakistan', 'Asia', 'Southern Asia'),
('BD', 'BGD', 'Bangladesh', 'People''s Republic of Bangladesh', 'Asia', 'Southern Asia'),
('TH', 'THA', 'Thailand', 'Kingdom of Thailand', 'Asia', 'South-Eastern Asia'),
('SG', 'SGP', 'Singapore', 'Republic of Singapore', 'Asia', 'South-Eastern Asia'),
('PL', 'POL', 'Poland', 'Republic of Poland', 'Europe', 'Eastern Europe'),
('LT', 'LTU', 'Lithuania', 'Republic of Lithuania', 'Europe', 'Northern Europe'),
('BE', 'BEL', 'Belgium', 'Kingdom of Belgium', 'Europe', 'Western Europe'),
('NL', 'NLD', 'Netherlands', 'Kingdom of the Netherlands', 'Europe', 'Western Europe'),
('PT', 'PRT', 'Portugal', 'Portuguese Republic', 'Europe', 'Southern Europe'),
('GR', 'GRC', 'Greece', 'Hellenic Republic', 'Europe', 'Southern Europe'),
('TR', 'TUR', 'Turkey', 'Republic of Turkey', 'Asia', 'Western Asia');

-- ============================================================================
-- END OF REFERENCE DATA
-- ============================================================================

-- Create indexes on reference tables for better query performance
CREATE INDEX idx_temp_std_code ON ref_temperature_standard(temp_std_code);
CREATE INDEX idx_energy_unit_code ON ref_energy_unit(energy_unit_code);
CREATE INDEX idx_mass_unit_code ON ref_mass_unit(mass_unit_code);
CREATE INDEX idx_volume_unit_code ON ref_volume_unit(volume_unit_code);
CREATE INDEX idx_hv_mass_common ON ref_heating_value_mass_unit(is_common) WHERE is_common = true;
CREATE INDEX idx_hv_vol_common ON ref_heating_value_volume_unit(is_common) WHERE is_common = true;
CREATE INDEX idx_country_iso2 ON ref_country(country_code_iso2);
CREATE INDEX idx_country_iso3 ON ref_country(country_code_iso3);
CREATE INDEX idx_component_code ON ref_lng_component(component_code);
CREATE INDEX idx_component_display ON ref_lng_component(display_order);
