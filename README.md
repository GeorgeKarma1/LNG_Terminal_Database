# LNG Terminal Database

A comprehensive PostgreSQL database schema for managing LNG (Liquefied Natural Gas) terminal data, cargo quality information, vessel interactions, port calls, and historical feedback tracking.

## Overview

This database provides a complete solution for tracking and managing:

- **LNG Loading Terminals** - Export facilities with cargo quality data
- **LNG Discharging Terminals** - Import and regasification facilities
- **Vessel Information** - LNG carrier specifications and capabilities
- **Port Calls** - Complete vessel-terminal interaction history
- **Cargo Quality Data** - Composition, heating values, and physical properties
- **Feedback System** - User feedback submissions with historical tracking
- **Unit Conversions** - Comprehensive measurement unit reference tables

## Key Features

### 1. **Comprehensive Terminal Data**
- Physical dimensions and restrictions
- Navigation requirements and restrictions
- Cargo management capabilities
- Manifold and connection specifications
- Mooring arrangements
- Gangway and access details
- Services and facilities
- Operational procedures

### 2. **Complete Cargo Quality Tracking** (for Loading Terminals)
- Component composition (mole %, mass %, volume %)
- Heating values (multiple unit combinations)
- Physical properties (density, molecular weight, etc.)
- Quality parameters (sulfur, water, mercury content, etc.)

### 3. **Vessel-Terminal Interactions**
- Port call history
- Loading/discharging events
- Timeline of events during port calls
- Multi-cargo batch support

### 4. **Historical Versioning**
- All critical terminal data maintains version history
- Complete audit trail for all changes
- Tracks who changed what and when
- Links changes to feedback submissions

### 5. **User Feedback System**
- Structured feedback collection
- Category-specific feedback fields
- Status tracking (submitted, under review, implemented, etc.)
- Action tracking and completion

### 6. **Measurement Unit Standards**
- Comprehensive reference tables for all unit types
- Support for ISO, ASTM, and industry standards
- Temperature reference standards (0°C, 15°C, 25°C, 60°F, etc.)
- Heating value combinations (MJ/kg, Btu/lbm, MJ/Sm³, Btu/scf, etc.)

## Database Structure

### Core Entity Tables

```
terminal
├── terminal_dimension_restriction (with versioning)
├── terminal_navigation (with versioning)
├── terminal_cargo_management (with versioning)
├── terminal_manifold_arrangement (with versioning)
├── terminal_mooring_arrangement (with versioning)
├── terminal_gangway_access (with versioning)
├── terminal_services (with versioning)
├── terminal_operations (with versioning)
└── terminal_document

vessel
└── vessel (master vessel information)

lng_cargo_batch (for loading terminals)
├── lng_cargo_composition
├── lng_cargo_heating_value
├── lng_cargo_physical_properties
└── lng_cargo_quality_parameters

port_call
├── port_call_cargo_detail
└── port_call_event

port_feedback
├── terminal_change_history
└── cargo_batch_change_history
```

### Reference Tables

```
ref_temperature_standard
ref_energy_unit
ref_mass_unit
ref_volume_unit
ref_heating_value_mass_unit
ref_heating_value_volume_unit
ref_pressure_unit
ref_length_unit
ref_speed_unit
ref_flow_rate_liquid_unit
ref_flow_rate_vapor_unit
ref_terminal_type
ref_terminal_status
ref_berthing_side
ref_berthing_time
ref_manifold_configuration
ref_flange_standard
ref_flange_surface_finish
ref_gasket_supply
ref_monitoring_system_type
ref_country
ref_lng_component
```

## Installation

### Prerequisites

- PostgreSQL 12 or higher
- PostGIS extension (optional, for geographic queries)
- UUID-OSSP extension

### Setup Instructions

1. **Create Database**

```bash
createdb lng_terminal_db
```

2. **Connect to Database**

```bash
psql lng_terminal_db
```

3. **Run Schema Creation**

```sql
\i lng_terminal_database_schema.sql
```

4. **Load Reference Data**

```sql
\i lng_reference_data_inserts.sql
```

5. **Verify Installation**

```sql
-- Check tables
\dt

-- Check reference data
SELECT COUNT(*) FROM ref_temperature_standard;
SELECT COUNT(*) FROM ref_energy_unit;
SELECT COUNT(*) FROM ref_heating_value_mass_unit;
SELECT COUNT(*) FROM ref_heating_value_volume_unit;
```

## Usage Examples

### Example 1: Add a New Terminal

```sql
-- Insert terminal
INSERT INTO terminal (
    terminal_name, terminal_code, country_id, port_name,
    terminal_type_id, terminal_status_id, latitude, longitude
)
SELECT
    'Example LNG Terminal',
    'EXMPL-01',
    c.country_id,
    'Example Port',
    tt.terminal_type_id,
    ts.terminal_status_id,
    25.123456,
    55.789012
FROM ref_country c, ref_terminal_type tt, ref_terminal_status ts
WHERE c.country_code_iso2 = 'AE'
    AND tt.terminal_type_code = 'DISCHARGE'
    AND ts.status_code = 'OPERATIONAL'
RETURNING terminal_id;

-- Add dimension restrictions (using terminal_id from above)
INSERT INTO terminal_dimension_restriction (
    terminal_id, max_loa_m, max_breadth_m, max_draft_m, is_current
) VALUES (
    1,  -- Replace with actual terminal_id
    345.00,
    55.00,
    12.50,
    true
);
```

### Example 2: Add Cargo Quality Data (Loading Terminal)

```sql
-- Create cargo batch
INSERT INTO lng_cargo_batch (
    loading_terminal_id, batch_number, cargo_name,
    sample_date, is_current
) VALUES (
    1,  -- Terminal ID
    'BATCH-2025-001',
    'Qatar Mix',
    '2025-01-15',
    true
) RETURNING cargo_batch_id;

-- Add composition
INSERT INTO lng_cargo_composition (cargo_batch_id, component_id, mole_percent)
SELECT
    1,  -- Replace with actual cargo_batch_id
    component_id,
    CASE component_code
        WHEN 'CH4' THEN 89.50
        WHEN 'C2H6' THEN 6.20
        WHEN 'C3H8' THEN 2.10
        WHEN 'IC4H10' THEN 0.50
        WHEN 'NC4H10' THEN 0.60
        WHEN 'N2' THEN 1.10
        ELSE 0.00
    END
FROM ref_lng_component
WHERE component_code IN ('CH4', 'C2H6', 'C3H8', 'IC4H10', 'NC4H10', 'N2');

-- Add heating values
INSERT INTO lng_cargo_heating_value (
    cargo_batch_id,
    ghv_mass_value, ghv_mass_unit_id,
    ghv_mj_kg,
    ghv_volume_value, ghv_volume_unit_id,
    ghv_mj_sm3
) SELECT
    1,  -- cargo_batch_id
    55.50,
    hvm.hv_mass_unit_id,
    55.50,  -- Already in MJ/kg
    40.20,
    hvv.hv_vol_unit_id,
    40.20   -- Already in MJ/Sm³
FROM ref_heating_value_mass_unit hvm, ref_heating_value_volume_unit hvv
WHERE hvm.unit_code = 'MJ_KG_15C'
    AND hvv.unit_code = 'MJ_SM3_15C';
```

### Example 3: Record a Port Call

```sql
INSERT INTO port_call (
    vessel_id, terminal_id, operation_type,
    ata_utc, berthing_completed_utc,
    operation_commenced_utc, operation_completed_utc,
    atd_utc,
    cargo_quantity_discharged_cbm,
    port_call_status
) VALUES (
    1,  -- vessel_id
    1,  -- terminal_id
    'DISCHARGING',
    '2025-01-15 08:30:00',
    '2025-01-15 10:00:00',
    '2025-01-15 11:00:00',
    '2025-01-16 03:00:00',
    '2025-01-16 05:00:00',
    140000.00,
    'COMPLETED'
);
```

### Example 4: Submit Port Feedback

```sql
INSERT INTO port_feedback (
    port_call_id, terminal_id, vessel_id,
    submitted_by, submitter_role,
    port_call_date, load_discharge,
    feedback_category, feedback_priority,
    feedback_title, feedback_description,
    mooring_feedback
) VALUES (
    1,  -- port_call_id
    1,  -- terminal_id
    1,  -- vessel_id
    'Captain John Smith',
    'MASTER',
    '2025-01-15',
    'DISCHARGE',
    'UPDATE_REQUEST',
    'MEDIUM',
    'Updated Mooring Line Requirements',
    'Terminal now requires 11m nylon tail ropes instead of 22m previously listed.',
    'Please update terminal manual - nylon tail ropes must be 11m, not 22m as currently documented.'
);
```

### Example 5: Query Current Terminal Information

```sql
-- Get complete current terminal data
SELECT
    terminal_name,
    country_name,
    port_name,
    terminal_type_name,
    max_loa_m,
    max_draft_m,
    manifold_config.config_name AS manifold_configuration,
    berthing_side.side_name AS preferred_berthing_side,
    liquid_rate_m3h_max AS max_liquid_rate_m3hr
FROM v_terminal_current vt
LEFT JOIN ref_country c ON vt.country_id = c.country_id
LEFT JOIN ref_terminal_type tt ON vt.terminal_type_id = tt.terminal_type_id
LEFT JOIN ref_manifold_configuration manifold_config ON vt.manifold_config_id = manifold_config.manifold_config_id
LEFT JOIN ref_berthing_side berthing_side ON vt.berthing_side_id = berthing_side.berthing_side_id
WHERE vt.is_active = true
ORDER BY terminal_name;
```

### Example 6: Find Compatible Terminals for a Vessel

```sql
SELECT
    t.terminal_name,
    t.port_name,
    c.country_name,
    tdr.max_loa_m,
    tdr.max_draft_m,
    tdr.depth_at_berth_m,
    (tdr.depth_at_berth_m - 12.5) AS underkeel_clearance_m
FROM terminal t
JOIN terminal_dimension_restriction tdr
    ON t.terminal_id = tdr.terminal_id
    AND tdr.is_current = true
JOIN ref_country c ON t.country_id = c.country_id
WHERE t.is_active = true
    AND tdr.max_loa_m >= 315.0        -- Vessel LOA
    AND tdr.max_breadth_m >= 50.0     -- Vessel breadth
    AND tdr.max_draft_m >= 12.0       -- Vessel draft
    AND tdr.depth_at_berth_m >= 13.0  -- Minimum depth with UKC
ORDER BY t.terminal_name;
```

### Example 7: Get Cargo Quality with Multiple Units

```sql
SELECT
    cb.cargo_name,
    cb.sample_date,
    t.terminal_name,
    -- Heating values in MJ/kg
    chv.ghv_mj_kg,
    -- Convert to Btu/lbm
    chv.ghv_mj_kg * 429.923 AS ghv_btu_per_lbm,
    -- Heating values in MJ/Sm³
    chv.ghv_mj_sm3,
    -- Wobbe Index
    chv.wobbe_index_mj_sm3,
    -- Physical properties
    cpp.density_liquid_kgm3,
    cpp.molecular_weight
FROM lng_cargo_batch cb
JOIN terminal t ON cb.loading_terminal_id = t.terminal_id
JOIN lng_cargo_heating_value chv ON cb.cargo_batch_id = chv.cargo_batch_id
LEFT JOIN lng_cargo_physical_properties cpp ON cb.cargo_batch_id = cpp.cargo_batch_id
WHERE cb.is_current = true
ORDER BY cb.sample_date DESC;
```

### Example 8: Track Terminal Changes

```sql
-- View change history for a specific terminal
SELECT
    tch.changed_at,
    tch.changed_by,
    tch.table_name,
    tch.change_type,
    tch.changed_fields,
    tch.change_reason,
    tch.old_values,
    tch.new_values
FROM terminal_change_history tch
WHERE tch.terminal_id = 1
ORDER BY tch.changed_at DESC;
```

## Naming Conventions

All naming conventions and unit measurements are documented in detail in [NAMING_CONVENTIONS_AND_UNITS.md](NAMING_CONVENTIONS_AND_UNITS.md).

### Key Conventions

- **Table Names**: `snake_case`, singular form (e.g., `terminal`, `vessel`, `port_call`)
- **Column Names**: `snake_case` with unit suffixes (e.g., `max_draft_m`, `cargo_capacity_cbm`)
- **Reference Tables**: Prefixed with `ref_` (e.g., `ref_country`, `ref_energy_unit`)
- **Unit Suffixes**: Clear indication of measurement units (e.g., `_m` = meters, `_mt` = metric tons)

### Common Unit Suffixes

| Suffix | Meaning | Example |
|--------|---------|---------|
| `_m` | meters | `max_loa_m` |
| `_ft` | feet | `max_loa_ft` |
| `_mt` | metric tons | `deadweight_mt` |
| `_cbm` | cubic meters | `cargo_capacity_cbm` |
| `_kn` | knots | `max_transit_speed_kn` |
| `_mbar` | millibars | `arrival_svp_mbar` |
| `_c` | Celsius | `arrival_temp_c` |
| `_m3h` | cubic meters/hour | `liquid_rate_m3h` |
| `_mj_kg` | MJ per kilogram | `ghv_mj_kg` |
| `_mj_sm3` | MJ per standard m³ | `ghv_mj_sm3` |

## Measurement Units

### Heating Value Units

The database supports all common heating value unit combinations:

**By Mass (Energy/Mass):**
- MJ/kg at 0°C, 15°C, 25°C (abbreviated: MJ0/kg, MJ1/kg, MJ2/kg)
- Btu/kg, Btu/lbm at 60°F (abbreviated: B6/lbm)
- kWh/kg
- kcal/kg
- th/kg (Thermie/kg)

**By Volume (Energy/Volume):**
- MJ/Sm³ at 0°C, 15°C, 25°C (abbreviated: MJ0/Sm3, MJ1/Sm3, MJ2/Sm3)
- Btu/scf at 60°F (abbreviated: B6/Scf)
- Btu/ft³, Btu/m³
- kWh/m³
- kcal/m³
- th/m³

### Temperature References

| Code | Temperature | Standard | Common Use |
|------|------------|----------|------------|
| T0C | 0°C (32°F) | ISO 6976 | European/ISO |
| T15C | 15°C (59°F) | ISO 6976 | Most common ISO |
| T25C | 25°C (77°F) | - | Some regions |
| T60F | 60°F (15.56°C) | ASTM | US standard |

## Historical Versioning

All critical terminal data tables include built-in versioning:

- `valid_from` / `valid_to` timestamps
- `is_current` boolean flag
- `version_number` for tracking
- Queries automatically filter for current data using views

**Example: Accessing Historical Data**

```sql
-- Get all historical versions of dimension restrictions
SELECT
    terminal_id,
    max_loa_m,
    max_draft_m,
    valid_from,
    valid_to,
    version_number
FROM terminal_dimension_restriction
WHERE terminal_id = 1
ORDER BY valid_from DESC;

-- Get current restrictions only
SELECT *
FROM terminal_dimension_restriction
WHERE terminal_id = 1
    AND is_current = true;
```

## Views

### `v_terminal_current`
Complete current terminal information with all related data joined.

```sql
SELECT * FROM v_terminal_current
WHERE terminal_name LIKE '%Grain%';
```

### `v_cargo_quality_complete`
Complete cargo quality data including composition, heating values, and properties.

```sql
SELECT * FROM v_cargo_quality_complete
WHERE sample_date > '2025-01-01';
```

### `v_port_call_summary`
Port call summary with vessel, terminal, and duration calculations.

```sql
SELECT * FROM v_port_call_summary
WHERE operation_type = 'LOADING'
ORDER BY ata_utc DESC;
```

## Integration with Existing Systems

### CSV Data Import Example

```sql
-- Create temporary table for CSV import
CREATE TEMP TABLE temp_terminal_import (
    terminal_name TEXT,
    country_code TEXT,
    port_name TEXT,
    max_loa_m NUMERIC,
    max_draft_m NUMERIC,
    latitude NUMERIC,
    longitude NUMERIC
);

-- Import CSV
\COPY temp_terminal_import FROM 'terminals.csv' CSV HEADER;

-- Insert into main tables
INSERT INTO terminal (
    terminal_name, country_id, port_name, latitude, longitude
)
SELECT
    tti.terminal_name,
    c.country_id,
    tti.port_name,
    tti.latitude,
    tti.longitude
FROM temp_terminal_import tti
LEFT JOIN ref_country c ON c.country_code_iso2 = tti.country_code;
```

## Backup and Maintenance

### Backup

```bash
# Full database backup
pg_dump lng_terminal_db > lng_terminal_db_backup_$(date +%Y%m%d).sql

# Schema only
pg_dump --schema-only lng_terminal_db > lng_terminal_db_schema.sql

# Data only
pg_dump --data-only lng_terminal_db > lng_terminal_db_data.sql
```

### Maintenance

```sql
-- Analyze tables for query optimization
ANALYZE;

-- Vacuum to reclaim storage
VACUUM ANALYZE;

-- Reindex
REINDEX DATABASE lng_terminal_db;
```

## Performance Optimization

### Indexes

The schema includes comprehensive indexes on:
- Foreign keys
- Frequently queried columns
- Geographic data (using GIST indexes for PostGIS)
- Boolean flags for filtering (e.g., `is_current`, `is_active`)

### Query Tips

1. **Use views for current data**: `v_terminal_current` pre-filters for current versions
2. **Filter on indexed columns**: Use `terminal_id`, `vessel_id`, `is_current` in WHERE clauses
3. **Use EXPLAIN ANALYZE**: Check query plans for optimization opportunities

```sql
EXPLAIN ANALYZE
SELECT * FROM v_terminal_current
WHERE max_loa_m >= 300;
```

## Contributing

When adding new data or modifying the schema:

1. **Maintain naming conventions**: Follow snake_case and unit suffix standards
2. **Add version control**: Use `valid_from`, `valid_to`, `is_current` for historical data
3. **Document changes**: Update this README and create change history entries
4. **Test queries**: Ensure views and indexes work correctly with new data

## Support and Documentation

- **Schema Documentation**: See `lng_terminal_database_schema.sql`
- **Naming Conventions**: See `NAMING_CONVENTIONS_AND_UNITS.md`
- **Reference Data**: See `lng_reference_data_inserts.sql`

## License

[Your License Here]

## Version History

- **v1.0** (2025-11-15): Initial release
  - Complete schema for terminals, vessels, cargoes, and port calls
  - Comprehensive unit measurement reference tables
  - Historical versioning and feedback system
  - PostgreSQL 12+ compatible

---

**Maintained by**: LNG Terminal Database Project
**Last Updated**: 2025-11-15
