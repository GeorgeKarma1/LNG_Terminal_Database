-- ============================================================================
-- LNG TERMINAL DATABASE - EXAMPLE DATA INSERTS
-- ============================================================================
-- Example data to demonstrate database usage
-- ============================================================================

-- Note: Run this AFTER lng_terminal_database_schema.sql and lng_reference_data_inserts.sql

-- ============================================================================
-- EXAMPLE 1: Add a Loading Terminal (Qatar - Ras Laffan)
-- ============================================================================

-- Insert terminal
INSERT INTO terminal (
    terminal_name,
    terminal_code,
    country_id,
    port_name,
    terminal_type_id,
    terminal_status_id,
    operator_name,
    latitude,
    longitude,
    data_quality_status,
    is_active
)
SELECT
    'Ras Laffan LNG 2',
    'RL-LNG-2',
    c.country_id,
    'Ras Laffan',
    tt.terminal_type_id,
    ts.terminal_status_id,
    'Qatargas',
    25.91030556,
    51.58744444,
    'VERIFIED',
    true
FROM ref_country c, ref_terminal_type tt, ref_terminal_status ts
WHERE c.country_code_iso2 = 'QA'
    AND tt.terminal_type_code = 'LOAD'
    AND ts.status_code = 'OPERATIONAL'
RETURNING terminal_id;

-- Add dimension restrictions (use terminal_id from above, typically 1)
INSERT INTO terminal_dimension_restriction (
    terminal_id,
    max_loa_m, max_loa_ft,
    max_breadth_m, max_breadth_ft,
    max_draft_m, max_draft_ft,
    depth_at_berth_m,
    max_cargo_capacity_cbm,
    is_current,
    version_number
) VALUES (
    1,  -- terminal_id
    315.00, 1033.46,
    55.00, 180.45,
    12.50, 41.01,
    13.50,
    105000,
    true,
    1
);

-- Add navigation information
INSERT INTO terminal_navigation (
    terminal_id,
    berthing_time_id,
    berthing_side_id,
    berthing_speed_restriction_ms,
    berthing_speed_restriction_kn,
    visibility_restriction_nm,
    tidal_range_low_m,
    tidal_range_high_m,
    water_density_min_kgm3,
    water_density_max_kgm3,
    pilot_required,
    pilot_boarding_location,
    tug_required,
    tug_count_berthing,
    tug_count_unberthing,
    total_bollard_pull_mt,
    is_current
)
SELECT
    1,  -- terminal_id
    bt.berthing_time_id,
    bs.berthing_side_id,
    0.12, 0.23,
    NULL,  -- No visibility restriction
    -0.76, 0.97,
    1025, 1025,
    true,
    '1 mile from fairway buoy',
    true,
    4,
    4,
    240,
    true
FROM ref_berthing_time bt, ref_berthing_side bs
WHERE bt.time_code = 'DAYNIGHT'
    AND bs.side_code = 'PORT';

-- Add cargo management
INSERT INTO terminal_cargo_management (
    terminal_id,
    shore_tank_capacity_cbm,
    arrival_svp_mbar_min,
    arrival_svp_mbar_max,
    arrival_temp_c_min,
    liquid_rate_m3h_max,
    vapor_rate_m3h_max,
    is_current
) VALUES (
    1,
    1460000,
    100,
    110,
    -162,
    15400,
    38700,
    true
);

-- Add manifold arrangement
INSERT INTO terminal_manifold_arrangement (
    terminal_id,
    manifold_config_id,
    flange_liquid_std_id,
    flange_vapor_std_id,
    surface_finish_id,
    gasket_supply_id,
    strainer_required,
    strainer_mesh_size,
    loading_arm_reach_min_m,
    loading_arm_reach_max_m,
    primary_monitoring_type_id,
    is_current
)
SELECT
    1,
    mc.manifold_config_id,
    fl.flange_std_id,
    fv.flange_std_id,
    sf.surface_finish_id,
    gs.gasket_supply_id,
    false,
    60,
    14.76,
    23.47,
    mt.monitoring_type_id,
    true
FROM ref_manifold_configuration mc,
     ref_flange_standard fl,
     ref_flange_standard fv,
     ref_flange_surface_finish sf,
     ref_gasket_supply gs,
     ref_monitoring_system_type mt
WHERE mc.config_code = 'L_V_L_L'
    AND fl.flange_code = 'ANSI_150_16IN_RF'
    AND fv.flange_code = 'ANSI_150_16IN_RF'
    AND sf.finish_code = 'RF'
    AND gs.supply_code = 'SHORE'
    AND mt.system_code = 'ELECTRICAL';

-- ============================================================================
-- EXAMPLE 2: Add a Discharge Terminal (UK - Isle of Grain)
-- ============================================================================

INSERT INTO terminal (
    terminal_name,
    terminal_code,
    country_id,
    port_name,
    terminal_type_id,
    terminal_status_id,
    operator_name,
    latitude,
    longitude,
    is_active
)
SELECT
    'Grain LNG Berth 10',
    'GRAIN-B10',
    c.country_id,
    'Isle of Grain',
    tt.terminal_type_id,
    ts.terminal_status_id,
    'National Grid Grain LNG',
    51.432675,
    0.704978,
    true
FROM ref_country c, ref_terminal_type tt, ref_terminal_status ts
WHERE c.country_code_iso2 = 'GB'
    AND tt.terminal_type_code = 'DISCHARGE'
    AND ts.status_code = 'OPERATIONAL'
RETURNING terminal_id;

-- Add dimension restrictions (terminal_id = 2)
INSERT INTO terminal_dimension_restriction (
    terminal_id,
    max_loa_m, max_loa_ft,
    max_breadth_m, max_breadth_ft,
    max_draft_m, max_draft_ft,
    depth_at_berth_m,
    is_current
) VALUES (
    2,
    318.00, 1043.31,
    50.00, 164.04,
    12.00, 39.37,
    12.50,
    true
);

-- Add cargo management for discharge terminal
INSERT INTO terminal_cargo_management (
    terminal_id,
    shore_tank_capacity_cbm,
    arrival_svp_mbar_max,
    liquid_rate_m3h_max,
    vapor_rate_m3h_max,
    is_current
) VALUES (
    2,
    1000000,
    175,
    12000,
    NULL,
    true
);

-- ============================================================================
-- EXAMPLE 3: Add an LNG Vessel
-- ============================================================================

INSERT INTO vessel (
    vessel_name,
    imo_number,
    call_sign,
    vessel_type,
    vessel_class,
    owner_name,
    operator_name,
    flag_country_id,
    loa_m,
    breadth_m,
    draft_design_m,
    draft_max_m,
    cargo_capacity_cbm,
    number_of_tanks,
    tank_type,
    builder_name,
    delivered_date,
    vessel_status,
    is_active
)
SELECT
    'LNG Example Carrier',
    '9123456',
    'ABC123',
    'LNG_CARRIER',
    'MEMBRANE',
    'Example Shipping Co.',
    'Example LNG Operator',
    c.country_id,
    288.00,
    46.40,
    11.50,
    11.80,
    145000,
    4,
    'MEMBRANE',
    'Samsung Heavy Industries',
    '2010-06-15',
    'IN_SERVICE',
    true
FROM ref_country c
WHERE c.country_code_iso2 = 'LR';  -- Liberia flag

-- ============================================================================
-- EXAMPLE 4: Add LNG Cargo Quality Data (for Loading Terminal)
-- ============================================================================

-- Create cargo batch
INSERT INTO lng_cargo_batch (
    loading_terminal_id,
    batch_number,
    cargo_source,
    cargo_name,
    sample_date,
    analysis_date,
    analysis_lab,
    analysis_method,
    valid_from_date,
    is_current
) VALUES (
    1,  -- Ras Laffan terminal
    'RL-2025-001',
    'North Field',
    'Qatar Mix',
    '2025-01-15',
    '2025-01-16',
    'Qatargas Laboratory',
    'ISO 6976',
    '2025-01-15',
    true
) RETURNING cargo_batch_id;

-- Add composition (using cargo_batch_id = 1)
INSERT INTO lng_cargo_composition (cargo_batch_id, component_id, mole_percent)
SELECT
    1,
    component_id,
    CASE component_code
        WHEN 'CH4' THEN 89.12
        WHEN 'C2H6' THEN 6.21
        WHEN 'C3H8' THEN 2.32
        WHEN 'IC4H10' THEN 0.48
        WHEN 'NC4H10' THEN 0.57
        WHEN 'IC5H12' THEN 0.11
        WHEN 'NC5H12' THEN 0.09
        WHEN 'C6PLUS' THEN 0.02
        WHEN 'N2' THEN 1.08
        ELSE 0.00
    END
FROM ref_lng_component
WHERE component_code IN ('CH4', 'C2H6', 'C3H8', 'IC4H10', 'NC4H10', 'IC5H12', 'NC5H12', 'C6PLUS', 'N2');

-- Add heating values
INSERT INTO lng_cargo_heating_value (
    cargo_batch_id,
    ghv_mass_value,
    ghv_mass_unit_id,
    ghv_mj_kg,
    nhv_mass_value,
    nhv_mass_unit_id,
    nhv_mj_kg,
    ghv_volume_value,
    ghv_volume_unit_id,
    ghv_mj_sm3,
    wobbe_index_value,
    wobbe_index_unit_id,
    wobbe_index_mj_sm3
)
SELECT
    1,  -- cargo_batch_id
    55.53,
    hvm.hv_mass_unit_id,
    55.53,
    50.02,
    hvm.hv_mass_unit_id,
    50.02,
    40.25,
    hvv.hv_vol_unit_id,
    40.25,
    53.84,
    hvv.hv_vol_unit_id,
    53.84
FROM ref_heating_value_mass_unit hvm, ref_heating_value_volume_unit hvv
WHERE hvm.unit_code = 'MJ_KG_15C'
    AND hvv.unit_code = 'MJ_SM3_15C';

-- Add physical properties
INSERT INTO lng_cargo_physical_properties (
    cargo_batch_id,
    density_liquid_kgm3,
    density_gas_kgm3,
    relative_density_gas,
    molecular_weight,
    normal_boiling_point_c
) VALUES (
    1,
    448.2,
    0.7245,
    0.5987,
    17.234,
    -161.5
);

-- Add quality parameters
INSERT INTO lng_cargo_quality_parameters (
    cargo_batch_id,
    total_sulfur_mgkg,
    water_content_mgkg,
    mercury_content_ugm3
) VALUES (
    1,
    0.5,
    0.1,
    0.001
);

-- ============================================================================
-- EXAMPLE 5: Record a Port Call (Loading Operation)
-- ============================================================================

INSERT INTO port_call (
    vessel_id,
    terminal_id,
    port_call_number,
    operation_type,
    eta_utc,
    ata_utc,
    nor_tendered_utc,
    nor_accepted_utc,
    berthing_commenced_utc,
    berthing_completed_utc,
    all_fast_utc,
    operation_commenced_utc,
    operation_completed_utc,
    unberthing_commenced_utc,
    unberthing_completed_utc,
    atd_utc,
    berth_name,
    berth_side,
    cargo_batch_id,
    cargo_quantity_loaded_cbm,
    master_name,
    pilot_on_board,
    number_of_tugs_arrival,
    number_of_tugs_departure,
    port_call_status
) VALUES (
    1,  -- vessel_id
    1,  -- terminal_id (Ras Laffan)
    'RL-2025-001',
    'LOADING',
    '2025-01-15 06:00:00',
    '2025-01-15 06:30:00',
    '2025-01-15 06:45:00',
    '2025-01-15 07:00:00',
    '2025-01-15 08:00:00',
    '2025-01-15 09:30:00',
    '2025-01-15 09:45:00',
    '2025-01-15 11:00:00',
    '2025-01-16 03:30:00',
    '2025-01-16 04:00:00',
    '2025-01-16 05:00:00',
    '2025-01-16 05:30:00',
    'Berth 2',
    'PORT',
    1,  -- cargo_batch_id
    142500.00,
    'Captain John Smith',
    true,
    4,
    4,
    'COMPLETED'
);

-- Add port call events
INSERT INTO port_call_event (port_call_id, event_type, event_timestamp_utc, event_description, event_category) VALUES
(1, 'PILOT_ONBOARD', '2025-01-15 06:30:00', 'Pilot boarded at fairway buoy', 'NAVIGATION'),
(1, 'BERTHING_COMMENCED', '2025-01-15 08:00:00', 'Commenced berthing with 4 tugs', 'NAVIGATION'),
(1, 'ALL_FAST', '2025-01-15 09:45:00', 'All mooring lines fast', 'NAVIGATION'),
(1, 'HOSE_CONNECTION', '2025-01-15 10:30:00', 'Loading arms connected and tested', 'CARGO_OPS'),
(1, 'LOADING_COMMENCED', '2025-01-15 11:00:00', 'Loading commenced at 14,000 m³/hr', 'CARGO_OPS'),
(1, 'LOADING_COMPLETED', '2025-01-16 03:30:00', 'Loading completed. Total: 142,500 m³', 'CARGO_OPS'),
(1, 'HOSE_DISCONNECTION', '2025-01-16 03:45:00', 'Loading arms disconnected', 'CARGO_OPS');

-- ============================================================================
-- EXAMPLE 6: Submit Port Feedback
-- ============================================================================

INSERT INTO port_feedback (
    port_call_id,
    terminal_id,
    vessel_id,
    submitted_by,
    submitter_role,
    submitter_email,
    port_call_date,
    load_discharge,
    feedback_category,
    feedback_priority,
    feedback_title,
    feedback_description,
    mooring_feedback,
    feedback_status
) VALUES (
    1,
    1,
    1,
    'Captain John Smith',
    'MASTER',
    'captain.smith@example.com',
    '2025-01-15',
    'LOAD',
    'POSITIVE',
    'LOW',
    'Excellent Loading Operations',
    'Loading operations proceeded smoothly with excellent cooperation from terminal staff.',
    'Mooring arrangement worked well. All 16 lines as specified in terminal manual.',
    'SUBMITTED'
);

-- ============================================================================
-- EXAMPLE 7: Track a Change to Terminal Data
-- ============================================================================

-- Record that someone updated the maximum draft based on feedback
INSERT INTO terminal_change_history (
    terminal_id,
    table_name,
    record_id,
    change_type,
    changed_by,
    change_reason,
    old_values,
    new_values,
    changed_fields,
    change_source
) VALUES (
    1,
    'terminal_dimension_restriction',
    1,
    'UPDATE',
    'admin@example.com',
    'Updated based on recent port authority dredging project',
    '{"max_draft_m": 12.50}',
    '{"max_draft_m": 12.80}',
    ARRAY['max_draft_m'],
    'PERIODIC_REVIEW'
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify terminals
SELECT
    t.terminal_name,
    c.country_name,
    tt.terminal_type_name,
    ts.status_name,
    t.latitude,
    t.longitude
FROM terminal t
LEFT JOIN ref_country c ON t.country_id = c.country_id
LEFT JOIN ref_terminal_type tt ON t.terminal_type_id = tt.terminal_type_id
LEFT JOIN ref_terminal_status ts ON t.terminal_status_id = ts.terminal_status_id;

-- Verify cargo composition
SELECT
    cb.cargo_name,
    comp.component_name,
    cc.mole_percent
FROM lng_cargo_batch cb
JOIN lng_cargo_composition cc ON cb.cargo_batch_id = cc.cargo_batch_id
JOIN ref_lng_component comp ON cc.component_id = comp.component_id
WHERE cb.cargo_batch_id = 1
ORDER BY cc.mole_percent DESC;

-- Verify heating values
SELECT
    cb.cargo_name,
    chv.ghv_mj_kg AS ghv_mj_per_kg,
    chv.ghv_mj_kg * 429.923 AS ghv_btu_per_lbm,
    chv.ghv_mj_sm3 AS ghv_mj_per_sm3,
    chv.ghv_mj_sm3 * 26.84 AS approx_ghv_btu_per_scf
FROM lng_cargo_batch cb
JOIN lng_cargo_heating_value chv ON cb.cargo_batch_id = chv.cargo_batch_id;

-- Verify port call
SELECT
    v.vessel_name,
    t.terminal_name,
    pc.operation_type,
    pc.ata_utc,
    pc.atd_utc,
    pc.cargo_quantity_loaded_cbm,
    EXTRACT(EPOCH FROM (pc.operation_completed_utc - pc.operation_commenced_utc))/3600 AS loading_hours
FROM port_call pc
JOIN vessel v ON pc.vessel_id = v.vessel_id
JOIN terminal t ON pc.terminal_id = t.terminal_id;

-- ============================================================================
-- END OF EXAMPLE DATA
-- ============================================================================
