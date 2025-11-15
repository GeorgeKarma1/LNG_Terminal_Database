-- ============================================================================
-- LNG TERMINAL DATABASE SCHEMA
-- ============================================================================
-- Comprehensive PostgreSQL database schema for LNG Loading and Discharging
-- Terminals, Cargo Quality Data, Vessel Interactions, and Port Feedback
-- ============================================================================
-- Version: 1.0
-- Created: 2025-11-15
-- ============================================================================

-- Enable UUID extension for generating unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS extension for geographic data (optional but recommended)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================================
-- REFERENCE TABLES - MEASUREMENT UNITS AND STANDARDS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Temperature Reference Standards
-- ----------------------------------------------------------------------------
CREATE TABLE ref_temperature_standard (
    temp_std_id SERIAL PRIMARY KEY,
    temp_std_code VARCHAR(10) UNIQUE NOT NULL,  -- e.g., 'T0C', 'T15C', 'T25C', 'T60F', 'T32F'
    temp_std_name VARCHAR(100) NOT NULL,        -- e.g., '0°C', '15°C', '25°C', '60°F', '32°F'
    temp_value_c NUMERIC(6,2) NOT NULL,         -- Temperature in Celsius
    temp_value_f NUMERIC(6,2) NOT NULL,         -- Temperature in Fahrenheit
    temp_value_k NUMERIC(6,2) NOT NULL,         -- Temperature in Kelvin
    is_iso_standard BOOLEAN DEFAULT false,      -- ISO standard reference
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_temperature_standard IS 'Reference temperature standards for LNG measurements';
COMMENT ON COLUMN ref_temperature_standard.temp_std_code IS 'Abbreviated code: T0C, T15C, T20C, T25C, T32F, T60F, T68F';

-- ----------------------------------------------------------------------------
-- Energy Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_energy_unit (
    energy_unit_id SERIAL PRIMARY KEY,
    energy_unit_code VARCHAR(20) UNIQUE NOT NULL,  -- e.g., 'MJ', 'BTU', 'KWH', 'KCAL', 'THERM'
    energy_unit_name VARCHAR(100) NOT NULL,         -- e.g., 'Megajoule', 'British Thermal Unit'
    energy_unit_symbol VARCHAR(20) NOT NULL,        -- e.g., 'MJ', 'Btu', 'kWh', 'kcal', 'therm'
    to_mj_conversion NUMERIC(20,10) NOT NULL,       -- Conversion factor to MJ
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_energy_unit IS 'Energy unit types for heating value measurements';

-- ----------------------------------------------------------------------------
-- Mass Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_mass_unit (
    mass_unit_id SERIAL PRIMARY KEY,
    mass_unit_code VARCHAR(20) UNIQUE NOT NULL,    -- e.g., 'KG', 'LBM', 'MT', 'LB', 'TON'
    mass_unit_name VARCHAR(100) NOT NULL,           -- e.g., 'Kilogram', 'Pound Mass'
    mass_unit_symbol VARCHAR(20) NOT NULL,          -- e.g., 'kg', 'lbm', 'mt', 'lb'
    to_kg_conversion NUMERIC(20,10) NOT NULL,       -- Conversion factor to kg
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_mass_unit IS 'Mass unit types for LNG measurements';

-- ----------------------------------------------------------------------------
-- Volume Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_volume_unit (
    volume_unit_id SERIAL PRIMARY KEY,
    volume_unit_code VARCHAR(20) UNIQUE NOT NULL,  -- e.g., 'M3', 'FT3', 'SM3', 'SCF', 'NM3', 'NCF'
    volume_unit_name VARCHAR(100) NOT NULL,         -- e.g., 'Cubic Meter', 'Standard Cubic Foot'
    volume_unit_symbol VARCHAR(20) NOT NULL,        -- e.g., 'm³', 'ft³', 'Sm³', 'scf'
    is_standard_condition BOOLEAN DEFAULT false,    -- Standard vs actual conditions
    reference_temp_c NUMERIC(6,2),                  -- Reference temperature if standard
    reference_pressure_kpa NUMERIC(10,3),           -- Reference pressure if standard
    to_m3_conversion NUMERIC(20,10) NOT NULL,       -- Conversion factor to m³
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_volume_unit IS 'Volume unit types including standard and actual conditions';
COMMENT ON COLUMN ref_volume_unit.is_standard_condition IS 'TRUE for Sm³, scf, Nm³, Ncf (standard conditions)';

-- ----------------------------------------------------------------------------
-- Combined Measurement Units (Energy per Mass)
-- ----------------------------------------------------------------------------
CREATE TABLE ref_heating_value_mass_unit (
    hv_mass_unit_id SERIAL PRIMARY KEY,
    unit_code VARCHAR(30) UNIQUE NOT NULL,          -- e.g., 'MJ_KG', 'BTU_LBM', 'KWH_KG'
    unit_display VARCHAR(50) NOT NULL,               -- e.g., 'MJ/kg', 'Btu/lbm', 'kWh/kg'
    energy_unit_id INTEGER REFERENCES ref_energy_unit(energy_unit_id),
    mass_unit_id INTEGER REFERENCES ref_mass_unit(mass_unit_id),
    temp_std_id INTEGER REFERENCES ref_temperature_standard(temp_std_id),
    abbreviated_form VARCHAR(30),                    -- e.g., 'MJ/kg@25C', 'B/L@60F'
    to_mj_kg_conversion NUMERIC(20,10) NOT NULL,    -- Conversion to MJ/kg standard
    is_common BOOLEAN DEFAULT false,                 -- Commonly used units
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_heating_value_mass_unit IS 'Combined energy/mass units for gross/net heating values';
COMMENT ON COLUMN ref_heating_value_mass_unit.abbreviated_form IS 'Short form: MJ0 (MJ@0°C), MJ1 (MJ@15°C), MJ2 (MJ@25°C), B6 (Btu@60°F)';

-- ----------------------------------------------------------------------------
-- Combined Measurement Units (Energy per Volume)
-- ----------------------------------------------------------------------------
CREATE TABLE ref_heating_value_volume_unit (
    hv_vol_unit_id SERIAL PRIMARY KEY,
    unit_code VARCHAR(30) UNIQUE NOT NULL,          -- e.g., 'MJ_SM3', 'BTU_SCF', 'BTU_M3'
    unit_display VARCHAR(50) NOT NULL,               -- e.g., 'MJ/Sm³', 'Btu/scf', 'kWh/m³'
    energy_unit_id INTEGER REFERENCES ref_energy_unit(energy_unit_id),
    volume_unit_id INTEGER REFERENCES ref_volume_unit(volume_unit_id),
    temp_std_id INTEGER REFERENCES ref_temperature_standard(temp_std_id),
    abbreviated_form VARCHAR(30),                    -- e.g., 'MJ1/Sm3', 'B6/Scf'
    to_mj_sm3_conversion NUMERIC(20,10) NOT NULL,   -- Conversion to MJ/Sm³ standard
    is_common BOOLEAN DEFAULT false,                 -- Commonly used units
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_heating_value_volume_unit IS 'Combined energy/volume units for heating values';
COMMENT ON COLUMN ref_heating_value_volume_unit.abbreviated_form IS 'Short form: MJ1/Sm3 (MJ 15°C/Sm³), B6/Scf (Btu 60°F/scf)';

-- ----------------------------------------------------------------------------
-- Pressure Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_pressure_unit (
    pressure_unit_id SERIAL PRIMARY KEY,
    pressure_unit_code VARCHAR(20) UNIQUE NOT NULL, -- e.g., 'MBAR', 'KPA', 'PSI', 'MPA', 'BAR'
    pressure_unit_name VARCHAR(100) NOT NULL,        -- e.g., 'Millibar', 'Kilopascal'
    pressure_unit_symbol VARCHAR(20) NOT NULL,       -- e.g., 'mbar', 'kPa', 'psi', 'MPa'
    to_kpa_conversion NUMERIC(20,10) NOT NULL,      -- Conversion factor to kPa
    is_absolute BOOLEAN DEFAULT false,               -- Absolute vs gauge pressure
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_pressure_unit IS 'Pressure unit types for LNG vapor and liquid pressures';

-- ----------------------------------------------------------------------------
-- Length/Distance Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_length_unit (
    length_unit_id SERIAL PRIMARY KEY,
    length_unit_code VARCHAR(20) UNIQUE NOT NULL,   -- e.g., 'M', 'FT', 'NM', 'KM', 'IN'
    length_unit_name VARCHAR(100) NOT NULL,          -- e.g., 'Meter', 'Foot', 'Nautical Mile'
    length_unit_symbol VARCHAR(20) NOT NULL,         -- e.g., 'm', 'ft', 'nm', 'km', 'in'
    to_m_conversion NUMERIC(20,10) NOT NULL,        -- Conversion factor to meters
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_length_unit IS 'Length/distance unit types';

-- ----------------------------------------------------------------------------
-- Speed/Velocity Unit Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_speed_unit (
    speed_unit_id SERIAL PRIMARY KEY,
    speed_unit_code VARCHAR(20) UNIQUE NOT NULL,    -- e.g., 'KN', 'MS', 'KMH', 'MPH'
    speed_unit_name VARCHAR(100) NOT NULL,           -- e.g., 'Knots', 'Meters per Second'
    speed_unit_symbol VARCHAR(20) NOT NULL,          -- e.g., 'kn', 'm/s', 'km/h'
    to_ms_conversion NUMERIC(20,10) NOT NULL,       -- Conversion factor to m/s
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_speed_unit IS 'Speed/velocity unit types for vessel and flow measurements';

-- ----------------------------------------------------------------------------
-- Flow Rate Unit Types (Liquid)
-- ----------------------------------------------------------------------------
CREATE TABLE ref_flow_rate_liquid_unit (
    flow_rate_liq_unit_id SERIAL PRIMARY KEY,
    unit_code VARCHAR(30) UNIQUE NOT NULL,          -- e.g., 'M3H', 'M3HR', 'GPMR', 'FTHR'
    unit_display VARCHAR(50) NOT NULL,               -- e.g., 'm³/hr', 'GPM', 'ft³/hr'
    volume_unit_id INTEGER REFERENCES ref_volume_unit(volume_unit_id),
    time_period VARCHAR(20) NOT NULL,                -- 'hour', 'minute', 'second', 'day'
    to_m3h_conversion NUMERIC(20,10) NOT NULL,      -- Conversion to m³/hour
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_flow_rate_liquid_unit IS 'Liquid flow rate units for discharge/loading rates';

-- ----------------------------------------------------------------------------
-- Flow Rate Unit Types (Vapor)
-- ----------------------------------------------------------------------------
CREATE TABLE ref_flow_rate_vapor_unit (
    flow_rate_vap_unit_id SERIAL PRIMARY KEY,
    unit_code VARCHAR(30) UNIQUE NOT NULL,          -- e.g., 'M3H', 'SCFH', 'NM3H'
    unit_display VARCHAR(50) NOT NULL,               -- e.g., 'm³/hr', 'scf/hr', 'Nm³/hr'
    volume_unit_id INTEGER REFERENCES ref_volume_unit(volume_unit_id),
    time_period VARCHAR(20) NOT NULL,                -- 'hour', 'minute', 'second', 'day'
    to_m3h_conversion NUMERIC(20,10) NOT NULL,      -- Conversion to m³/hour
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_flow_rate_vapor_unit IS 'Vapor flow rate units for BOG and vapor return';

-- ============================================================================
-- REFERENCE TABLES - ENUMERATIONS AND LOOKUP DATA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Terminal Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_terminal_type (
    terminal_type_id SERIAL PRIMARY KEY,
    terminal_type_code VARCHAR(20) UNIQUE NOT NULL, -- 'LOAD', 'DISCHARGE', 'DUAL'
    terminal_type_name VARCHAR(100) NOT NULL,        -- 'Loading', 'Discharging', 'Dual Purpose'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_terminal_type IS 'Terminal operation types: Loading, Discharging, or Dual Purpose';

-- ----------------------------------------------------------------------------
-- Terminal Status
-- ----------------------------------------------------------------------------
CREATE TABLE ref_terminal_status (
    terminal_status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(20) UNIQUE NOT NULL,        -- 'OPERATIONAL', 'CONSTRUCTION', 'PLANNED', 'DECOMMISSIONED'
    status_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_terminal_status IS 'Current operational status of terminals';

-- ----------------------------------------------------------------------------
-- Berthing Side
-- ----------------------------------------------------------------------------
CREATE TABLE ref_berthing_side (
    berthing_side_id SERIAL PRIMARY KEY,
    side_code VARCHAR(20) UNIQUE NOT NULL,          -- 'PORT', 'STBD', 'BOTH'
    side_name VARCHAR(50) NOT NULL,                  -- 'Port', 'Starboard', 'Both'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_berthing_side IS 'Preferred berthing side for vessels';

-- ----------------------------------------------------------------------------
-- Berthing Time Restriction
-- ----------------------------------------------------------------------------
CREATE TABLE ref_berthing_time (
    berthing_time_id SERIAL PRIMARY KEY,
    time_code VARCHAR(20) UNIQUE NOT NULL,          -- 'DAY', 'NIGHT', 'DAYNIGHT', 'H24'
    time_name VARCHAR(50) NOT NULL,                  -- 'Daylight Only', 'Night Only', 'Day/Night', '24 Hours'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_berthing_time IS 'Berthing time restrictions';

-- ----------------------------------------------------------------------------
-- Manifold Configuration Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_manifold_configuration (
    manifold_config_id SERIAL PRIMARY KEY,
    config_code VARCHAR(30) UNIQUE NOT NULL,        -- 'L_V_L', 'L_L_V_L', 'L_V_L_L', etc.
    config_name VARCHAR(100) NOT NULL,               -- Display name
    liquid_connections INTEGER NOT NULL,             -- Number of liquid connections
    vapor_connections INTEGER NOT NULL,              -- Number of vapor connections
    configuration_order VARCHAR(50),                 -- e.g., 'L-V-L' (from bow to stern)
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_manifold_configuration IS 'Standard manifold configurations (L=Liquid, V=Vapor)';
COMMENT ON COLUMN ref_manifold_configuration.configuration_order IS 'Arrangement from bow/forward looking aft';

-- ----------------------------------------------------------------------------
-- Flange Standards
-- ----------------------------------------------------------------------------
CREATE TABLE ref_flange_standard (
    flange_std_id SERIAL PRIMARY KEY,
    flange_code VARCHAR(50) UNIQUE NOT NULL,        -- 'ANSI_150_16IN', 'ANSI_300_16IN', 'JIS_10K_16IN'
    flange_name VARCHAR(100) NOT NULL,               -- '16" ANSI 150 RF'
    standard_type VARCHAR(50),                       -- 'ANSI', 'JIS', 'DIN', 'BS'
    pressure_rating VARCHAR(50),                     -- '150', '300', '600', '10K', '20K'
    nominal_size_in NUMERIC(6,2),                    -- Size in inches
    nominal_size_mm NUMERIC(6,2),                    -- Size in millimeters
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_flange_standard IS 'Flange standards and ratings';

-- ----------------------------------------------------------------------------
-- Flange Surface Finish
-- ----------------------------------------------------------------------------
CREATE TABLE ref_flange_surface_finish (
    surface_finish_id SERIAL PRIMARY KEY,
    finish_code VARCHAR(20) UNIQUE NOT NULL,        -- 'RF', 'FF', 'RTJ', 'SIGTTO'
    finish_name VARCHAR(100) NOT NULL,               -- 'Raised Face', 'Flat Face', 'Ring Type Joint'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_flange_surface_finish IS 'Flange surface finish types';

-- ----------------------------------------------------------------------------
-- Gasket Supply Responsibility
-- ----------------------------------------------------------------------------
CREATE TABLE ref_gasket_supply (
    gasket_supply_id SERIAL PRIMARY KEY,
    supply_code VARCHAR(20) UNIQUE NOT NULL,        -- 'SHIP', 'SHORE', 'EITHER'
    supply_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_gasket_supply IS 'Party responsible for gasket supply';

-- ----------------------------------------------------------------------------
-- Loading Arm Monitoring System Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_monitoring_system_type (
    monitoring_type_id SERIAL PRIMARY KEY,
    system_code VARCHAR(30) UNIQUE NOT NULL,        -- 'OPTICAL', 'ELECTRICAL', 'PNEUMATIC', 'NONE'
    system_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_monitoring_system_type IS 'Loading arm position monitoring system types';

-- ----------------------------------------------------------------------------
-- Countries
-- ----------------------------------------------------------------------------
CREATE TABLE ref_country (
    country_id SERIAL PRIMARY KEY,
    country_code_iso2 CHAR(2) UNIQUE NOT NULL,      -- ISO 3166-1 alpha-2
    country_code_iso3 CHAR(3) UNIQUE NOT NULL,      -- ISO 3166-1 alpha-3
    country_name VARCHAR(200) NOT NULL,
    country_name_official VARCHAR(300),
    region VARCHAR(100),                             -- Geographic region
    sub_region VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_country IS 'ISO 3166 country codes and names';

-- ----------------------------------------------------------------------------
-- LNG Component Types
-- ----------------------------------------------------------------------------
CREATE TABLE ref_lng_component (
    component_id SERIAL PRIMARY KEY,
    component_code VARCHAR(20) UNIQUE NOT NULL,     -- 'CH4', 'C2H6', 'C3H8', 'IC4H10', 'NC4H10', 'IC5H12', 'NC5H12', 'C6+', 'N2', 'CO2'
    component_name VARCHAR(100) NOT NULL,            -- 'Methane', 'Ethane', 'Propane', etc.
    chemical_formula VARCHAR(50),                    -- 'CH₄', 'C₂H₆', etc.
    molecular_weight NUMERIC(10,5),                  -- kg/kmol
    component_group VARCHAR(50),                     -- 'Hydrocarbon', 'Inert', 'Heavy'
    display_order INTEGER,                           -- For consistent display ordering
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_lng_component IS 'LNG composition component types';
COMMENT ON COLUMN ref_lng_component.component_code IS 'Standard abbreviations: CH4, C2H6, C3H8, IC4, NC4, IC5, NC5, C6+, N2, CO2';

-- ============================================================================
-- CORE ENTITY TABLES - TERMINALS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LNG Terminals Master Table
-- ----------------------------------------------------------------------------
CREATE TABLE terminal (
    terminal_id SERIAL PRIMARY KEY,
    terminal_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    terminal_name VARCHAR(200) NOT NULL,
    terminal_code VARCHAR(50) UNIQUE,                -- Unique terminal code/identifier
    country_id INTEGER REFERENCES ref_country(country_id),
    port_name VARCHAR(200),
    terminal_type_id INTEGER REFERENCES ref_terminal_type(terminal_type_id),
    terminal_status_id INTEGER REFERENCES ref_terminal_status(terminal_status_id),
    operator_name VARCHAR(200),
    owner_name VARCHAR(200),

    -- Geographic Location
    latitude NUMERIC(10,7),                          -- Decimal degrees
    longitude NUMERIC(10,7),                         -- Decimal degrees
    geolocation GEOGRAPHY(POINT, 4326),              -- PostGIS geography point

    -- Timestamps and Audit
    commissioned_date DATE,
    decommissioned_date DATE,
    data_quality_status VARCHAR(50),                 -- 'VERIFIED', 'UNVERIFIED', 'OUTDATED', 'DRAFT'
    last_verified_date DATE,
    last_verified_by VARCHAR(200),

    -- Additional Information
    website_url VARCHAR(500),
    contact_email VARCHAR(200),
    contact_phone VARCHAR(50),
    time_zone VARCHAR(50),                           -- IANA time zone identifier

    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200)
);

COMMENT ON TABLE terminal IS 'Master table for all LNG terminals (loading and discharging)';
COMMENT ON COLUMN terminal.terminal_code IS 'Unique code for terminal identification';
COMMENT ON COLUMN terminal.geolocation IS 'PostGIS geography point for spatial queries';

-- Create index on geolocation for spatial queries
CREATE INDEX idx_terminal_geolocation ON terminal USING GIST(geolocation);
CREATE INDEX idx_terminal_country ON terminal(country_id);
CREATE INDEX idx_terminal_type ON terminal(terminal_type_id);
CREATE INDEX idx_terminal_status ON terminal(terminal_status_id);

-- ----------------------------------------------------------------------------
-- Terminal Dimension Restrictions
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_dimension_restriction (
    dimension_restriction_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Vessel Size Restrictions
    max_loa_m NUMERIC(8,2),                          -- Maximum Length Overall (meters)
    max_loa_ft NUMERIC(8,2),                         -- Maximum Length Overall (feet)
    max_breadth_m NUMERIC(7,2),                      -- Maximum Breadth (meters)
    max_breadth_ft NUMERIC(7,2),                     -- Maximum Breadth (feet)
    max_displacement_mt NUMERIC(12,2),               -- Maximum Displacement (metric tons)
    max_displacement_lt NUMERIC(12,2),               -- Maximum Displacement (long tons)
    max_air_draft_m NUMERIC(7,2),                    -- Maximum Air Draft (meters)
    max_air_draft_ft NUMERIC(7,2),                   -- Maximum Air Draft (feet)
    max_draft_m NUMERIC(7,2),                        -- Maximum Draft (meters)
    max_draft_ft NUMERIC(7,2),                       -- Maximum Draft (feet)
    depth_at_berth_m NUMERIC(7,2),                   -- Water depth at berth (meters)
    depth_at_berth_ft NUMERIC(7,2),                  -- Water depth at berth (feet)

    -- Cargo Capacity Restrictions
    min_cargo_capacity_cbm NUMERIC(12,2),            -- Minimum cargo capacity (cubic meters)
    max_cargo_capacity_cbm NUMERIC(12,2),            -- Maximum cargo capacity (cubic meters)

    -- Version Control and Audit
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_dimension_restriction IS 'Physical dimension restrictions for vessels at terminals (with historical versioning)';
COMMENT ON COLUMN terminal_dimension_restriction.is_current IS 'TRUE for current restrictions, FALSE for historical';
COMMENT ON COLUMN terminal_dimension_restriction.version_number IS 'Version number for tracking changes';

CREATE INDEX idx_term_dim_terminal ON terminal_dimension_restriction(terminal_id);
CREATE INDEX idx_term_dim_current ON terminal_dimension_restriction(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Navigation Information
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_navigation (
    navigation_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Berthing Information
    berthing_time_id INTEGER REFERENCES ref_berthing_time(berthing_time_id),
    berthing_side_id INTEGER REFERENCES ref_berthing_side(berthing_side_id),
    berthing_speed_restriction_ms NUMERIC(6,3),      -- Berthing speed restriction (m/s)
    berthing_speed_restriction_kn NUMERIC(6,3),      -- Berthing speed restriction (knots)

    -- Transit and Approach
    max_transit_speed_kn NUMERIC(6,2),               -- Maximum transit speed (knots)
    max_transit_speed_kmh NUMERIC(6,2),              -- Maximum transit speed (km/h)
    approach_speed_restriction_kn NUMERIC(6,2),      -- Approach speed restriction

    -- Environmental Restrictions
    visibility_restriction_nm NUMERIC(6,2),          -- Minimum visibility (nautical miles)
    visibility_restriction_km NUMERIC(6,2),          -- Minimum visibility (kilometers)
    max_wind_speed_ms NUMERIC(6,2),                  -- Maximum wind speed (m/s)
    max_wind_speed_kn NUMERIC(6,2),                  -- Maximum wind speed (knots)
    max_wave_height_m NUMERIC(6,2),                  -- Maximum wave height (meters)
    max_current_speed_kn NUMERIC(6,2),               -- Maximum current speed (knots)

    -- Tidal Information
    tidal_range_low_m NUMERIC(6,2),                  -- Low tide (meters)
    tidal_range_high_m NUMERIC(6,2),                 -- High tide (meters)
    tidal_window_restriction TEXT,                   -- Description of tidal restrictions

    -- Water Density
    water_density_min_kgm3 NUMERIC(8,2),            -- Minimum water density (kg/m³)
    water_density_max_kgm3 NUMERIC(8,2),            -- Maximum water density (kg/m³)
    water_type VARCHAR(50),                          -- 'SALT', 'FRESH', 'BRACKISH'

    -- Pilot and Tugs
    pilot_required BOOLEAN DEFAULT true,
    pilot_boarding_location TEXT,
    pilot_boarding_lat NUMERIC(10,7),
    pilot_boarding_lon NUMERIC(10,7),
    number_of_pilots INTEGER,

    tug_required BOOLEAN DEFAULT true,
    tug_count_berthing INTEGER,
    tug_count_unberthing INTEGER,
    total_bollard_pull_mt NUMERIC(8,2),              -- Total bollard pull (metric tons)
    tug_configuration TEXT,                          -- Description of tug requirements

    -- Anchorage
    anchorage_available BOOLEAN DEFAULT false,
    anchorage_location TEXT,
    anchorage_lat NUMERIC(10,7),
    anchorage_lon NUMERIC(10,7),

    -- Charts and Navigation Aids
    local_charts_required BOOLEAN DEFAULT false,
    chart_numbers TEXT,                              -- Required chart numbers
    navigation_notes TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_nav_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_navigation IS 'Navigation and operational restrictions for terminals (with historical versioning)';

CREATE INDEX idx_term_nav_terminal ON terminal_navigation(terminal_id);
CREATE INDEX idx_term_nav_current ON terminal_navigation(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Cargo Management (Loading/Discharge Capabilities)
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_cargo_management (
    cargo_mgmt_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Shore Tank Capacity
    shore_tank_capacity_cbm NUMERIC(12,2),           -- Shore tank capacity (m³)
    shore_tank_capacity_restriction_cbm NUMERIC(12,2),
    number_of_tanks INTEGER,

    -- Arrival Conditions (for discharge terminals)
    arrival_svp_mbar_min NUMERIC(8,2),               -- Min saturated vapor pressure (mbar)
    arrival_svp_mbar_max NUMERIC(8,2),               -- Max saturated vapor pressure (mbar)
    arrival_svp_psi_min NUMERIC(8,2),                -- Min saturated vapor pressure (psi)
    arrival_svp_psi_max NUMERIC(8,2),                -- Max saturated vapor pressure (psi)
    arrival_temp_c_min NUMERIC(7,2),                 -- Minimum arrival temperature (°C)
    arrival_temp_c_max NUMERIC(7,2),                 -- Maximum arrival temperature (°C)

    -- Loading/Discharge Rates - Liquid
    liquid_rate_m3h_max NUMERIC(10,2),               -- Maximum liquid rate (m³/hr)
    liquid_rate_m3h_min NUMERIC(10,2),               -- Minimum liquid rate (m³/hr)
    liquid_rate_m3h_normal NUMERIC(10,2),            -- Normal liquid rate (m³/hr)

    -- Loading/Discharge Rates - Vapor
    vapor_rate_m3h_max NUMERIC(10,2),                -- Maximum vapor rate (m³/hr)
    vapor_rate_m3h_min NUMERIC(10,2),                -- Minimum vapor rate (m³/hr)
    vapor_rate_m3h_normal NUMERIC(10,2),             -- Normal vapor rate (m³/hr)

    -- Cooldown and Gas-up
    cooldown_gasup_required BOOLEAN DEFAULT false,
    cooldown_time_hours NUMERIC(6,2),

    -- Purging and Draining
    purging_required BOOLEAN DEFAULT false,
    purging_criteria TEXT,                           -- e.g., "O2 < 1%", "CH4 < 1%"
    draining_required BOOLEAN DEFAULT false,
    draining_criteria TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_cargo_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_cargo_management IS 'Cargo handling capabilities and restrictions (with historical versioning)';

CREATE INDEX idx_term_cargo_terminal ON terminal_cargo_management(terminal_id);
CREATE INDEX idx_term_cargo_current ON terminal_cargo_management(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Manifold Arrangement
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_manifold_arrangement (
    manifold_arrangement_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Manifold Configuration
    manifold_config_id INTEGER REFERENCES ref_manifold_configuration(manifold_config_id),
    configuration_description TEXT,                  -- Free-text description
    reference_point VARCHAR(100),                    -- 'FROM_BOW', 'FROM_STERN', 'FROM_MIDSHIP'

    -- Flange Details - Liquid
    flange_liquid_std_id INTEGER REFERENCES ref_flange_standard(flange_std_id),
    flange_liquid_size_in NUMERIC(6,2),
    flange_liquid_rating VARCHAR(50),
    flange_liquid_count INTEGER,

    -- Flange Details - Vapor
    flange_vapor_std_id INTEGER REFERENCES ref_flange_standard(flange_std_id),
    flange_vapor_size_in NUMERIC(6,2),
    flange_vapor_rating VARCHAR(50),
    flange_vapor_count INTEGER,

    -- Flange Surface Finish
    surface_finish_id INTEGER REFERENCES ref_flange_surface_finish(surface_finish_id),
    flange_thickness_mm NUMERIC(7,2),                -- Flange thickness (mm)

    -- Spool Pieces and Bobbins
    sdp_bobbins_required BOOLEAN DEFAULT false,
    sdp_description TEXT,                            -- Spool piece details
    perc_required BOOLEAN DEFAULT false,             -- PERC (Pipeline Emergency Release Coupling)
    qcdc_required BOOLEAN DEFAULT false,             -- QC/DC (Quick Connect/Disconnect Coupling)

    -- Gaskets
    gasket_supply_id INTEGER REFERENCES ref_gasket_supply(gasket_supply_id),
    gasket_specification TEXT,

    -- Strainer Requirements
    strainer_required BOOLEAN DEFAULT false,
    strainer_mesh_size INTEGER,                      -- Mesh size
    strainer_notes TEXT,

    -- Loading Arm Operating Envelope
    loading_arm_reach_min_m NUMERIC(6,2),            -- Minimum reach (meters)
    loading_arm_reach_max_m NUMERIC(6,2),            -- Maximum reach (meters)
    loading_arm_height_min_m NUMERIC(6,2),           -- Minimum height (meters)
    loading_arm_height_max_m NUMERIC(6,2),           -- Maximum height (meters)

    -- Monitoring System
    primary_monitoring_type_id INTEGER REFERENCES ref_monitoring_system_type(monitoring_type_id),
    secondary_monitoring_type_id INTEGER REFERENCES ref_monitoring_system_type(monitoring_type_id),
    tertiary_monitoring_type_id INTEGER REFERENCES ref_monitoring_system_type(monitoring_type_id),

    -- Adaptors and Equipment
    specific_adaptor_required BOOLEAN DEFAULT false,
    adaptor_description TEXT,
    tension_monitoring_system BOOLEAN DEFAULT false,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_manifold_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_manifold_arrangement IS 'Manifold and connection details for terminals (with historical versioning)';

CREATE INDEX idx_term_manifold_terminal ON terminal_manifold_arrangement(terminal_id);
CREATE INDEX idx_term_manifold_current ON terminal_manifold_arrangement(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Mooring Arrangement
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_mooring_arrangement (
    mooring_arrangement_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Mooring Line Configuration
    mooring_pattern VARCHAR(100),                    -- e.g., '2/4/2-2/4/2', '3/3/2-2/3/3'
    total_lines INTEGER,
    forward_lines INTEGER,
    aft_lines INTEGER,
    spring_lines INTEGER,
    breast_lines INTEGER,

    -- Line Specifications
    line_material VARCHAR(50),                       -- 'NYLON', 'POLYESTER', 'WIRE', 'SYNTHETIC'
    line_diameter_mm NUMERIC(6,2),
    line_mbl_mt NUMERIC(8,2),                        -- Minimum Breaking Load (metric tons)

    -- Tail Ropes
    tail_rope_required BOOLEAN DEFAULT false,
    tail_rope_material VARCHAR(50),
    tail_rope_length_m NUMERIC(6,2),
    tail_rope_spec TEXT,

    -- Bollards and Quick Release
    bollard_swl_mt NUMERIC(8,2),                     -- Safe Working Load per bollard (metric tons)
    quick_release_hooks BOOLEAN DEFAULT false,
    quick_release_swl_mt NUMERIC(8,2),

    -- Mooring Restrictions
    max_line_tension_mt NUMERIC(8,2),                -- Maximum line tension (metric tons)
    mooring_winch_required BOOLEAN DEFAULT false,

    notes TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_mooring_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_mooring_arrangement IS 'Mooring line arrangements and requirements (with historical versioning)';

CREATE INDEX idx_term_mooring_terminal ON terminal_mooring_arrangement(terminal_id);
CREATE INDEX idx_term_mooring_current ON terminal_mooring_arrangement(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Gangway and Access
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_gangway_access (
    gangway_access_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Gangway Location
    gangway_location VARCHAR(50),                    -- 'FORWARD', 'MIDSHIP', 'AFT'
    gangway_location_distance_m NUMERIC(6,2),        -- Distance from reference point (meters)
    gangway_height_m NUMERIC(6,2),                   -- Height above waterline (meters)

    -- Gangway Specifications
    gangway_footprint_length_m NUMERIC(6,2),         -- Length (meters)
    gangway_footprint_width_m NUMERIC(6,2),          -- Width (meters)
    gangway_angle_min_deg NUMERIC(5,2),              -- Minimum angle
    gangway_angle_max_deg NUMERIC(5,2),              -- Maximum angle

    -- Personnel Transfer
    basket_required BOOLEAN DEFAULT false,
    basket_capacity INTEGER,                         -- Number of persons
    personnel_transfer_notes TEXT,

    -- Crew Change and Shore Leave
    crew_change_allowed BOOLEAN DEFAULT false,
    shore_leave_allowed BOOLEAN DEFAULT false,
    crew_change_restrictions TEXT,

    notes TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_gangway_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_gangway_access IS 'Gangway and personnel access arrangements (with historical versioning)';

CREATE INDEX idx_term_gangway_terminal ON terminal_gangway_access(terminal_id);
CREATE INDEX idx_term_gangway_current ON terminal_gangway_access(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Services
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_services (
    service_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Bunkering and Supplies
    bunkering_available BOOLEAN DEFAULT false,
    bunkering_fuel_types TEXT,                       -- e.g., 'MGO', 'VLSFO', 'LSMGO'
    stores_available BOOLEAN DEFAULT false,
    fresh_water_available BOOLEAN DEFAULT false,

    -- Waste Management
    garbage_collection BOOLEAN DEFAULT false,
    bilge_reception BOOLEAN DEFAULT false,
    sewage_reception BOOLEAN DEFAULT false,

    -- Environmental Restrictions
    nox_sox_co2_restrictions TEXT,
    ballast_water_restrictions TEXT,
    discharge_restrictions TEXT,

    -- Other Services
    ship_repair_available BOOLEAN DEFAULT false,
    medical_facilities BOOLEAN DEFAULT false,
    communications TEXT,

    notes TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_service_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_services IS 'Services and facilities available at terminals (with historical versioning)';

CREATE INDEX idx_term_service_terminal ON terminal_services(terminal_id);
CREATE INDEX idx_term_service_current ON terminal_services(terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- Terminal Operations and Procedures
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_operations (
    operation_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Notice of Readiness
    nor_location VARCHAR(200),                       -- Where to tender NOR
    nor_requirements TEXT,

    -- Conditions of Use
    cou_required BOOLEAN DEFAULT false,
    pla_required BOOLEAN DEFAULT false,              -- Port Liability Agreement
    tsa_required BOOLEAN DEFAULT false,              -- Terminal Services Agreement
    special_agreements_required TEXT,

    -- Insurance and Premiums
    additional_premium_required BOOLEAN DEFAULT false,
    insurance_requirements TEXT,

    -- Training Requirements
    training_required BOOLEAN DEFAULT false,
    training_description TEXT,

    -- Safety Requirements
    firewires_required BOOLEAN DEFAULT false,
    fender_energy_absorption_knm NUMERIC(10,2),      -- kNm
    safety_equipment_required TEXT,

    -- Operating Restrictions
    exposed_terminal BOOLEAN DEFAULT false,
    exposure_limitations TEXT,
    weather_restrictions TEXT,
    other_restrictions TEXT,

    notes TEXT,

    -- Version Control
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP,
    is_current BOOLEAN DEFAULT true,
    version_number INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_operation_valid_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE terminal_operations IS 'Operational procedures and requirements (with historical versioning)';

CREATE INDEX idx_term_operation_terminal ON terminal_operations(terminal_id);
CREATE INDEX idx_term_operation_current ON terminal_operations(terminal_id, is_current) WHERE is_current = true;

-- ============================================================================
-- CORE ENTITY TABLES - VESSELS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Vessels Master Table
-- ----------------------------------------------------------------------------
CREATE TABLE vessel (
    vessel_id SERIAL PRIMARY KEY,
    vessel_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    vessel_name VARCHAR(200) NOT NULL,
    imo_number VARCHAR(10) UNIQUE NOT NULL,          -- IMO number (7 digits)
    call_sign VARCHAR(20),
    mmsi VARCHAR(15),                                 -- Maritime Mobile Service Identity

    -- Vessel Classification
    vessel_type VARCHAR(100),                         -- 'LNG_CARRIER', 'FSRU', 'FSLU'
    vessel_class VARCHAR(100),                        -- 'QFLEX', 'QMAX', 'MEMBRANE', 'MOSS'
    ice_class VARCHAR(50),

    -- Owner and Operator
    owner_name VARCHAR(200),
    operator_name VARCHAR(200),
    commercial_operator VARCHAR(200),
    technical_manager VARCHAR(200),
    flag_country_id INTEGER REFERENCES ref_country(country_id),

    -- Physical Dimensions
    loa_m NUMERIC(8,2),                              -- Length Overall (meters)
    breadth_m NUMERIC(7,2),                          -- Breadth (meters)
    depth_m NUMERIC(7,2),                            -- Depth (meters)
    draft_design_m NUMERIC(7,2),                     -- Design draft (meters)
    draft_max_m NUMERIC(7,2),                        -- Maximum draft (meters)
    air_draft_m NUMERIC(7,2),                        -- Air draft (meters)

    -- Tonnage
    gross_tonnage NUMERIC(12,2),
    net_tonnage NUMERIC(12,2),
    deadweight_mt NUMERIC(12,2),                     -- Deadweight (metric tons)
    displacement_mt NUMERIC(12,2),                   -- Displacement (metric tons)

    -- Cargo Capacity
    cargo_capacity_cbm NUMERIC(12,2),                -- Total cargo capacity (m³)
    number_of_tanks INTEGER,
    tank_type VARCHAR(50),                           -- 'MEMBRANE', 'MOSS', 'SPB'

    -- Build Information
    builder_name VARCHAR(200),
    yard_name VARCHAR(200),
    build_country_id INTEGER REFERENCES ref_country(country_id),
    keel_laid_date DATE,
    launched_date DATE,
    delivered_date DATE,
    hull_number VARCHAR(50),

    -- Status
    vessel_status VARCHAR(50),                       -- 'IN_SERVICE', 'LAID_UP', 'SCRAPPED'
    is_active BOOLEAN DEFAULT true,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200)
);

COMMENT ON TABLE vessel IS 'Master table for LNG vessels';
COMMENT ON COLUMN vessel.imo_number IS 'IMO number (7 digits, often prefixed with IMO)';

CREATE INDEX idx_vessel_imo ON vessel(imo_number);
CREATE INDEX idx_vessel_name ON vessel(vessel_name);
CREATE INDEX idx_vessel_owner ON vessel(owner_name);
CREATE INDEX idx_vessel_operator ON vessel(operator_name);

-- ============================================================================
-- CORE ENTITY TABLES - LNG CARGO QUALITY (FOR LOADING TERMINALS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LNG Cargo Batch (for Loading Terminals)
-- ----------------------------------------------------------------------------
CREATE TABLE lng_cargo_batch (
    cargo_batch_id SERIAL PRIMARY KEY,
    cargo_batch_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    loading_terminal_id INTEGER REFERENCES terminal(terminal_id),

    -- Batch Identification
    batch_number VARCHAR(100),
    cargo_source VARCHAR(200),                       -- Source field/facility
    cargo_name VARCHAR(200),                         -- Commercial cargo name

    -- Sampling Information
    sample_date DATE NOT NULL,
    sample_time TIME,
    sample_location VARCHAR(200),
    sampled_by VARCHAR(200),

    -- Analysis Information
    analysis_date DATE,
    analysis_lab VARCHAR(200),
    analysis_method VARCHAR(200),                    -- e.g., 'ISO 6976', 'GPA 2172'
    certificate_number VARCHAR(100),

    -- Period of Validity
    valid_from_date DATE,
    valid_to_date DATE,
    is_current BOOLEAN DEFAULT true,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200),

    CONSTRAINT chk_cargo_batch_period CHECK (valid_to_date IS NULL OR valid_to_date >= valid_from_date)
);

COMMENT ON TABLE lng_cargo_batch IS 'LNG cargo batches from loading terminals with quality data';
COMMENT ON COLUMN lng_cargo_batch.sample_date IS 'Date when cargo sample was taken';

CREATE INDEX idx_cargo_batch_terminal ON lng_cargo_batch(loading_terminal_id);
CREATE INDEX idx_cargo_batch_date ON lng_cargo_batch(sample_date);
CREATE INDEX idx_cargo_batch_current ON lng_cargo_batch(loading_terminal_id, is_current) WHERE is_current = true;

-- ----------------------------------------------------------------------------
-- LNG Cargo Composition (Mole %)
-- ----------------------------------------------------------------------------
CREATE TABLE lng_cargo_composition (
    composition_id SERIAL PRIMARY KEY,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id) ON DELETE CASCADE,
    component_id INTEGER REFERENCES ref_lng_component(component_id),

    -- Composition Values
    mole_percent NUMERIC(10,6) NOT NULL,             -- Mole percentage (0-100)
    mass_percent NUMERIC(10,6),                      -- Mass percentage (0-100)
    volume_percent NUMERIC(10,6),                    -- Volume percentage (0-100)

    -- Uncertainty/Range
    mole_percent_min NUMERIC(10,6),
    mole_percent_max NUMERIC(10,6),
    uncertainty NUMERIC(10,6),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_mole_percent_range CHECK (mole_percent >= 0 AND mole_percent <= 100),
    CONSTRAINT uq_cargo_component UNIQUE (cargo_batch_id, component_id)
);

COMMENT ON TABLE lng_cargo_composition IS 'Component composition of LNG cargo batches';
COMMENT ON COLUMN lng_cargo_composition.mole_percent IS 'Mole percentage of component (0-100%)';

CREATE INDEX idx_composition_batch ON lng_cargo_composition(cargo_batch_id);
CREATE INDEX idx_composition_component ON lng_cargo_composition(component_id);

-- ----------------------------------------------------------------------------
-- LNG Cargo Heating Values
-- ----------------------------------------------------------------------------
CREATE TABLE lng_cargo_heating_value (
    heating_value_id SERIAL PRIMARY KEY,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id) ON DELETE CASCADE,

    -- Gross Heating Value (by mass)
    ghv_mass_value NUMERIC(12,4) NOT NULL,
    ghv_mass_unit_id INTEGER REFERENCES ref_heating_value_mass_unit(hv_mass_unit_id),
    ghv_mj_kg NUMERIC(12,4),                         -- Standardized to MJ/kg

    -- Net Heating Value (by mass)
    nhv_mass_value NUMERIC(12,4),
    nhv_mass_unit_id INTEGER REFERENCES ref_heating_value_mass_unit(hv_mass_unit_id),
    nhv_mj_kg NUMERIC(12,4),                         -- Standardized to MJ/kg

    -- Gross Heating Value (by volume)
    ghv_volume_value NUMERIC(12,4),
    ghv_volume_unit_id INTEGER REFERENCES ref_heating_value_volume_unit(hv_vol_unit_id),
    ghv_mj_sm3 NUMERIC(12,4),                        -- Standardized to MJ/Sm³

    -- Net Heating Value (by volume)
    nhv_volume_value NUMERIC(12,4),
    nhv_volume_unit_id INTEGER REFERENCES ref_heating_value_volume_unit(hv_vol_unit_id),
    nhv_mj_sm3 NUMERIC(12,4),                        -- Standardized to MJ/Sm³

    -- Wobbe Index
    wobbe_index_value NUMERIC(12,4),
    wobbe_index_unit_id INTEGER REFERENCES ref_heating_value_volume_unit(hv_vol_unit_id),
    wobbe_index_mj_sm3 NUMERIC(12,4),                -- Standardized to MJ/Sm³

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cargo_heating_value UNIQUE (cargo_batch_id)
);

COMMENT ON TABLE lng_cargo_heating_value IS 'Heating values for LNG cargo batches in various unit combinations';
COMMENT ON COLUMN lng_cargo_heating_value.ghv_mj_kg IS 'Gross heating value standardized to MJ/kg for comparison';
COMMENT ON COLUMN lng_cargo_heating_value.wobbe_index_mj_sm3 IS 'Wobbe Index standardized to MJ/Sm³';

CREATE INDEX idx_heating_value_batch ON lng_cargo_heating_value(cargo_batch_id);

-- ----------------------------------------------------------------------------
-- LNG Cargo Physical Properties
-- ----------------------------------------------------------------------------
CREATE TABLE lng_cargo_physical_properties (
    physical_properties_id SERIAL PRIMARY KEY,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id) ON DELETE CASCADE,

    -- Density
    density_liquid_kgm3 NUMERIC(10,4),               -- Liquid density at NBP (kg/m³)
    density_gas_kgm3 NUMERIC(10,6),                  -- Gas density (kg/m³)
    relative_density_gas NUMERIC(10,6),              -- Relative density (air = 1)
    density_measurement_temp_c NUMERIC(7,2),         -- Temperature of measurement

    -- Molecular Weight
    molecular_weight NUMERIC(10,5),                  -- kg/kmol

    -- Critical Properties
    critical_temperature_c NUMERIC(8,3),
    critical_pressure_mpa NUMERIC(8,4),

    -- Boiling Point
    normal_boiling_point_c NUMERIC(8,3),             -- At 1 atm

    -- Compressibility
    compressibility_factor NUMERIC(10,6),

    -- Vapor Pressure
    vapor_pressure_mbar NUMERIC(10,4),               -- At specified temperature
    vapor_pressure_temp_c NUMERIC(7,2),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cargo_physical_props UNIQUE (cargo_batch_id)
);

COMMENT ON TABLE lng_cargo_physical_properties IS 'Physical properties of LNG cargo batches';

CREATE INDEX idx_physical_props_batch ON lng_cargo_physical_properties(cargo_batch_id);

-- ----------------------------------------------------------------------------
-- LNG Cargo Quality Parameters
-- ----------------------------------------------------------------------------
CREATE TABLE lng_cargo_quality_parameters (
    quality_param_id SERIAL PRIMARY KEY,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id) ON DELETE CASCADE,

    -- Sulfur Content
    total_sulfur_mgkg NUMERIC(10,4),                 -- mg/kg
    total_sulfur_ppm NUMERIC(10,4),                  -- ppm (mass)
    hydrogen_sulfide_mgkg NUMERIC(10,4),
    mercaptan_sulfur_mgkg NUMERIC(10,4),

    -- Water Content
    water_content_mgkg NUMERIC(10,4),                -- mg/kg
    water_content_ppm NUMERIC(10,4),                 -- ppm (mass)

    -- Mercury Content
    mercury_content_ugm3 NUMERIC(10,4),              -- μg/m³
    mercury_content_ppb NUMERIC(10,4),               -- ppb (volume)

    -- Solids and Particulates
    particulate_matter_mgm3 NUMERIC(10,4),

    -- Acidity/pH
    ph_value NUMERIC(5,2),

    -- Other Contaminants
    oxygen_content_ppm NUMERIC(10,4),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cargo_quality_params UNIQUE (cargo_batch_id)
);

COMMENT ON TABLE lng_cargo_quality_parameters IS 'Quality parameters and contaminant levels for LNG cargo';

CREATE INDEX idx_quality_params_batch ON lng_cargo_quality_parameters(cargo_batch_id);

-- ============================================================================
-- VESSEL-TERMINAL INTERACTION TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Port Calls / Visits
-- ----------------------------------------------------------------------------
CREATE TABLE port_call (
    port_call_id SERIAL PRIMARY KEY,
    port_call_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- References
    vessel_id INTEGER REFERENCES vessel(vessel_id),
    terminal_id INTEGER REFERENCES terminal(terminal_id),

    -- Port Call Identification
    port_call_number VARCHAR(100),                   -- Voyage/call reference number
    operation_type VARCHAR(50) NOT NULL,             -- 'LOADING', 'DISCHARGING', 'BUNKERING', 'TRANSIT'

    -- Dates and Times (all in UTC)
    eta_utc TIMESTAMP,                               -- Estimated Time of Arrival
    eta_local TIMESTAMP,                             -- ETA in local time
    ata_utc TIMESTAMP,                               -- Actual Time of Arrival
    ata_local TIMESTAMP,

    nor_tendered_utc TIMESTAMP,                      -- Notice of Readiness tendered
    nor_accepted_utc TIMESTAMP,                      -- NOR accepted

    berthing_commenced_utc TIMESTAMP,
    berthing_completed_utc TIMESTAMP,
    all_fast_utc TIMESTAMP,                          -- All lines fast

    operation_commenced_utc TIMESTAMP,               -- Loading/Discharging commenced
    operation_completed_utc TIMESTAMP,

    unberthing_commenced_utc TIMESTAMP,
    unberthing_completed_utc TIMESTAMP,

    etd_utc TIMESTAMP,                               -- Estimated Time of Departure
    atd_utc TIMESTAMP,                               -- Actual Time of Departure

    -- Berth Information
    berth_name VARCHAR(100),
    berth_side VARCHAR(20),                          -- 'PORT', 'STARBOARD'

    -- Cargo Batch (for loading operations)
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id),

    -- Cargo Quantity
    cargo_quantity_loaded_cbm NUMERIC(12,4),         -- m³ loaded
    cargo_quantity_discharged_cbm NUMERIC(12,4),     -- m³ discharged
    cargo_quantity_loaded_mt NUMERIC(12,4),          -- metric tons loaded
    cargo_quantity_discharged_mt NUMERIC(12,4),      -- metric tons discharged

    -- BOG (Boil-Off Gas)
    bog_quantity_cbm NUMERIC(12,4),

    -- Personnel
    master_name VARCHAR(200),
    chief_officer_name VARCHAR(200),
    cargo_officer_name VARCHAR(200),

    -- Pilot and Tugs
    pilot_on_board BOOLEAN DEFAULT false,
    pilot_name VARCHAR(200),
    number_of_tugs_arrival INTEGER,
    number_of_tugs_departure INTEGER,

    -- Documents
    cou_signed BOOLEAN DEFAULT false,
    pla_signed BOOLEAN DEFAULT false,
    tsa_signed BOOLEAN DEFAULT false,

    -- Incidents and Delays
    incidents_reported BOOLEAN DEFAULT false,
    delays_reported BOOLEAN DEFAULT false,
    delay_duration_hours NUMERIC(8,2),
    delay_reason TEXT,

    -- Status
    port_call_status VARCHAR(50),                    -- 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(200)
);

COMMENT ON TABLE port_call IS 'Individual port calls/visits by vessels to terminals';
COMMENT ON COLUMN port_call.operation_type IS 'Type of operation: LOADING, DISCHARGING, BUNKERING, TRANSIT';

CREATE INDEX idx_port_call_vessel ON port_call(vessel_id);
CREATE INDEX idx_port_call_terminal ON port_call(terminal_id);
CREATE INDEX idx_port_call_date ON port_call(ata_utc);
CREATE INDEX idx_port_call_status ON port_call(port_call_status);
CREATE INDEX idx_port_call_cargo ON port_call(cargo_batch_id);

-- ----------------------------------------------------------------------------
-- Port Call Cargo Details (for multiple cargo batches in one call)
-- ----------------------------------------------------------------------------
CREATE TABLE port_call_cargo_detail (
    port_call_cargo_id SERIAL PRIMARY KEY,
    port_call_id INTEGER REFERENCES port_call(port_call_id) ON DELETE CASCADE,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id),

    -- Cargo Quantity for this batch
    cargo_quantity_cbm NUMERIC(12,4),
    cargo_quantity_mt NUMERIC(12,4),

    -- Tank Loading Information
    tank_numbers TEXT,                               -- Which tanks were loaded

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE port_call_cargo_detail IS 'Details of cargo batches loaded during a port call (supports multiple batches per call)';

CREATE INDEX idx_port_call_cargo_detail_call ON port_call_cargo_detail(port_call_id);
CREATE INDEX idx_port_call_cargo_detail_batch ON port_call_cargo_detail(cargo_batch_id);

-- ----------------------------------------------------------------------------
-- Port Call Events (Timeline of Events)
-- ----------------------------------------------------------------------------
CREATE TABLE port_call_event (
    event_id SERIAL PRIMARY KEY,
    port_call_id INTEGER REFERENCES port_call(port_call_id) ON DELETE CASCADE,

    -- Event Details
    event_type VARCHAR(100) NOT NULL,                -- 'ARRIVAL', 'BERTHING', 'OPERATION_START', 'OPERATION_END', etc.
    event_timestamp_utc TIMESTAMP NOT NULL,
    event_timestamp_local TIMESTAMP,

    -- Event Description
    event_description TEXT,
    event_category VARCHAR(50),                      -- 'NAVIGATION', 'CARGO_OPS', 'SAFETY', 'ADMINISTRATIVE'

    -- Personnel
    reported_by VARCHAR(200),

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(200)
);

COMMENT ON TABLE port_call_event IS 'Timeline of events during a port call';

CREATE INDEX idx_port_call_event_call ON port_call_event(port_call_id);
CREATE INDEX idx_port_call_event_timestamp ON port_call_event(event_timestamp_utc);
CREATE INDEX idx_port_call_event_type ON port_call_event(event_type);

-- ============================================================================
-- FEEDBACK AND HISTORICAL TRACKING TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Port Feedback Submissions
-- ----------------------------------------------------------------------------
CREATE TABLE port_feedback (
    feedback_id SERIAL PRIMARY KEY,
    feedback_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- References
    port_call_id INTEGER REFERENCES port_call(port_call_id),
    terminal_id INTEGER REFERENCES terminal(terminal_id) NOT NULL,
    vessel_id INTEGER REFERENCES vessel(vessel_id) NOT NULL,

    -- Feedback Submission Info
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_by VARCHAR(200),                       -- User who submitted
    submitter_role VARCHAR(100),                     -- 'MASTER', 'CHIEF_OFFICER', 'OPERATOR', 'AGENT'
    submitter_email VARCHAR(200),

    -- Port Call Reference
    port_call_date DATE,
    load_discharge VARCHAR(20),                      -- 'LOAD', 'DISCHARGE'
    berth_name VARCHAR(100),

    -- Terminal Information Version
    terminal_handbook_version VARCHAR(100),
    new_handbook_available BOOLEAN DEFAULT false,
    handbook_attachment_url TEXT,

    -- Feedback Category
    feedback_category VARCHAR(100),                  -- 'POSITIVE', 'NEGATIVE', 'INFORMATIONAL', 'UPDATE_REQUEST'
    feedback_priority VARCHAR(50),                   -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'

    -- Feedback Content
    feedback_title VARCHAR(500),
    feedback_description TEXT NOT NULL,

    -- Specific Areas of Feedback
    dimension_restrictions_feedback TEXT,
    navigation_feedback TEXT,
    cargo_management_feedback TEXT,
    manifold_feedback TEXT,
    mooring_feedback TEXT,
    gangway_access_feedback TEXT,
    services_feedback TEXT,
    operations_feedback TEXT,
    general_comments TEXT,

    -- Supporting Data
    attachments_url TEXT,                            -- URL/path to attachments
    photos_url TEXT,

    -- Status
    feedback_status VARCHAR(50) DEFAULT 'SUBMITTED', -- 'SUBMITTED', 'UNDER_REVIEW', 'IMPLEMENTED', 'REJECTED', 'CLOSED'
    reviewed_by VARCHAR(200),
    reviewed_at TIMESTAMP,
    review_notes TEXT,

    -- Actions Taken
    action_required BOOLEAN DEFAULT false,
    action_description TEXT,
    action_completed BOOLEAN DEFAULT false,
    action_completed_date DATE,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE port_feedback IS 'Port and terminal feedback submissions from vessel operators and crew';
COMMENT ON COLUMN port_feedback.feedback_status IS 'Status: SUBMITTED, UNDER_REVIEW, IMPLEMENTED, REJECTED, CLOSED';

CREATE INDEX idx_port_feedback_terminal ON port_feedback(terminal_id);
CREATE INDEX idx_port_feedback_vessel ON port_feedback(vessel_id);
CREATE INDEX idx_port_feedback_call ON port_feedback(port_call_id);
CREATE INDEX idx_port_feedback_date ON port_feedback(submitted_at);
CREATE INDEX idx_port_feedback_status ON port_feedback(feedback_status);

-- ----------------------------------------------------------------------------
-- Terminal Change History (Audit Trail for All Terminal Data Changes)
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_change_history (
    change_id SERIAL PRIMARY KEY,
    change_uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,

    -- Reference
    terminal_id INTEGER REFERENCES terminal(terminal_id),

    -- Change Details
    table_name VARCHAR(100) NOT NULL,                -- Which table was changed
    record_id INTEGER,                                -- ID of the changed record
    change_type VARCHAR(50) NOT NULL,                -- 'INSERT', 'UPDATE', 'DELETE'

    -- Change Tracking
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(200),
    change_reason TEXT,

    -- Data Changes
    old_values JSONB,                                -- Old values (as JSON)
    new_values JSONB,                                -- New values (as JSON)
    changed_fields TEXT[],                           -- Array of changed field names

    -- Source of Change
    change_source VARCHAR(100),                      -- 'USER_EDIT', 'FEEDBACK', 'PERIODIC_REVIEW', 'IMPORT'
    source_reference_id INTEGER,                     -- e.g., feedback_id if from feedback

    -- Approval Workflow
    requires_approval BOOLEAN DEFAULT false,
    approved_by VARCHAR(200),
    approved_at TIMESTAMP,
    approval_status VARCHAR(50),                     -- 'PENDING', 'APPROVED', 'REJECTED'

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE terminal_change_history IS 'Complete audit trail of all changes to terminal data';
COMMENT ON COLUMN terminal_change_history.old_values IS 'Previous values stored as JSON for full audit trail';
COMMENT ON COLUMN terminal_change_history.new_values IS 'New values stored as JSON for full audit trail';

CREATE INDEX idx_change_history_terminal ON terminal_change_history(terminal_id);
CREATE INDEX idx_change_history_table ON terminal_change_history(table_name);
CREATE INDEX idx_change_history_date ON terminal_change_history(changed_at);
CREATE INDEX idx_change_history_user ON terminal_change_history(changed_by);
CREATE INDEX idx_change_history_source ON terminal_change_history(change_source);

-- ----------------------------------------------------------------------------
-- Cargo Batch Change History
-- ----------------------------------------------------------------------------
CREATE TABLE cargo_batch_change_history (
    change_id SERIAL PRIMARY KEY,
    cargo_batch_id INTEGER REFERENCES lng_cargo_batch(cargo_batch_id),

    -- Change Details
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER,
    change_type VARCHAR(50) NOT NULL,

    -- Change Tracking
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(200),
    change_reason TEXT,

    -- Data Changes
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE cargo_batch_change_history IS 'Audit trail of changes to cargo batch data';

CREATE INDEX idx_cargo_change_history_batch ON cargo_batch_change_history(cargo_batch_id);
CREATE INDEX idx_cargo_change_history_date ON cargo_batch_change_history(changed_at);

-- ----------------------------------------------------------------------------
-- Terminal Documents and Attachments
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_document (
    document_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id) ON DELETE CASCADE,

    -- Document Details
    document_category VARCHAR(100),                  -- 'TERMINAL_MANUAL', 'CARGO_HANDLING_MANUAL', 'PORT_REGULATIONS', etc.
    document_name VARCHAR(500) NOT NULL,
    document_description TEXT,

    -- File Information
    file_path TEXT,
    file_url TEXT,
    file_type VARCHAR(50),                           -- 'PDF', 'DOC', 'XLS', 'IMG'
    file_size_bytes BIGINT,

    -- Version Control
    document_version VARCHAR(50),
    version_date DATE,
    is_current_version BOOLEAN DEFAULT true,
    supersedes_document_id INTEGER REFERENCES terminal_document(document_id),

    -- Upload Information
    uploaded_by VARCHAR(200),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Access Control
    is_public BOOLEAN DEFAULT false,
    access_restrictions TEXT,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE terminal_document IS 'Documents and attachments related to terminals';

CREATE INDEX idx_terminal_doc_terminal ON terminal_document(terminal_id);
CREATE INDEX idx_terminal_doc_category ON terminal_document(document_category);
CREATE INDEX idx_terminal_doc_current ON terminal_document(is_current_version) WHERE is_current_version = true;

-- ============================================================================
-- COMPATIBILITY AND MATCHING TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Terminal-Vessel Compatibility
-- ----------------------------------------------------------------------------
CREATE TABLE terminal_vessel_compatibility (
    compatibility_id SERIAL PRIMARY KEY,
    terminal_id INTEGER REFERENCES terminal(terminal_id),
    vessel_id INTEGER REFERENCES vessel(vessel_id),

    -- Compatibility Assessment
    is_compatible BOOLEAN NOT NULL,
    compatibility_status VARCHAR(50),                -- 'APPROVED', 'RESTRICTED', 'PROHIBITED'

    -- Compatibility Factors
    dimension_compatible BOOLEAN,
    draft_compatible BOOLEAN,
    manifold_compatible BOOLEAN,
    mooring_compatible BOOLEAN,

    -- Restrictions or Conditions
    restrictions TEXT,
    special_requirements TEXT,

    -- Assessment Details
    assessed_by VARCHAR(200),
    assessed_date DATE,
    valid_from DATE,
    valid_to DATE,

    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_terminal_vessel_compat UNIQUE (terminal_id, vessel_id)
);

COMMENT ON TABLE terminal_vessel_compatibility IS 'Pre-assessed compatibility between terminals and vessels';

CREATE INDEX idx_compat_terminal ON terminal_vessel_compatibility(terminal_id);
CREATE INDEX idx_compat_vessel ON terminal_vessel_compatibility(vessel_id);
CREATE INDEX idx_compat_status ON terminal_vessel_compatibility(is_compatible);

-- ============================================================================
-- VIEWS FOR CONVENIENT DATA ACCESS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View: Current Terminal Information (All Current Data)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_terminal_current AS
SELECT
    t.*,
    tdr.*,
    tn.*,
    tcm.*,
    tma.*,
    tmr.*,
    tga.*,
    ts.*,
    top.*
FROM terminal t
LEFT JOIN terminal_dimension_restriction tdr ON t.terminal_id = tdr.terminal_id AND tdr.is_current = true
LEFT JOIN terminal_navigation tn ON t.terminal_id = tn.terminal_id AND tn.is_current = true
LEFT JOIN terminal_cargo_management tcm ON t.terminal_id = tcm.terminal_id AND tcm.is_current = true
LEFT JOIN terminal_manifold_arrangement tma ON t.terminal_id = tma.terminal_id AND tma.is_current = true
LEFT JOIN terminal_mooring_arrangement tmr ON t.terminal_id = tmr.terminal_id AND tmr.is_current = true
LEFT JOIN terminal_gangway_access tga ON t.terminal_id = tga.terminal_id AND tga.is_current = true
LEFT JOIN terminal_services ts ON t.terminal_id = ts.terminal_id AND ts.is_current = true
LEFT JOIN terminal_operations top ON t.terminal_id = top.terminal_id AND top.is_current = true
WHERE t.is_active = true;

COMMENT ON VIEW v_terminal_current IS 'Complete current terminal information (all active terminals with current data)';

-- ----------------------------------------------------------------------------
-- View: LNG Cargo with Complete Quality Data
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_cargo_quality_complete AS
SELECT
    cb.*,
    chv.*,
    cpp.*,
    cqp.*
FROM lng_cargo_batch cb
LEFT JOIN lng_cargo_heating_value chv ON cb.cargo_batch_id = chv.cargo_batch_id
LEFT JOIN lng_cargo_physical_properties cpp ON cb.cargo_batch_id = cpp.cargo_batch_id
LEFT JOIN lng_cargo_quality_parameters cqp ON cb.cargo_batch_id = cqp.cargo_batch_id
WHERE cb.is_current = true;

COMMENT ON VIEW v_cargo_quality_complete IS 'Complete cargo quality data including composition, heating values, and physical properties';

-- ----------------------------------------------------------------------------
-- View: Port Call Summary
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_port_call_summary AS
SELECT
    pc.*,
    v.vessel_name,
    v.imo_number,
    v.cargo_capacity_cbm AS vessel_capacity_cbm,
    t.terminal_name,
    t.terminal_code,
    t.port_name,
    c.country_name,
    cb.batch_number AS cargo_batch_number,
    cb.cargo_name,
    EXTRACT(EPOCH FROM (pc.operation_completed_utc - pc.operation_commenced_utc))/3600 AS operation_duration_hours,
    EXTRACT(EPOCH FROM (pc.atd_utc - pc.ata_utc))/3600 AS total_port_time_hours
FROM port_call pc
LEFT JOIN vessel v ON pc.vessel_id = v.vessel_id
LEFT JOIN terminal t ON pc.terminal_id = t.terminal_id
LEFT JOIN ref_country c ON t.country_id = c.country_id
LEFT JOIN lng_cargo_batch cb ON pc.cargo_batch_id = cb.cargo_batch_id;

COMMENT ON VIEW v_port_call_summary IS 'Summary view of port calls with vessel, terminal, and cargo information';

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to relevant tables
CREATE TRIGGER trg_terminal_updated_at BEFORE UPDATE ON terminal
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_vessel_updated_at BEFORE UPDATE ON vessel
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_port_call_updated_at BEFORE UPDATE ON port_call
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_port_feedback_updated_at BEFORE UPDATE ON port_feedback
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
