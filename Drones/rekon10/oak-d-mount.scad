// Units: mm
$fn = 48;

// Hole layout (replace with your exact measured centers)
front_spacing = 30.5;
rear_spacing  = 29.4;
row_spacing   = 40.7;   // front-to-rear center distance

// Absolute frame coordinates supplied from Rekon model:
// front row at (4.5, 212.8) and (35.0, 212.8)
front_left_abs  = [4.5, 212.8];
front_right_abs = [35.0, 212.8];
front_center_abs = [
    (front_left_abs[0] + front_right_abs[0]) / 2,
    (front_left_abs[1] + front_right_abs[1]) / 2
];

base_thickness = 3;
corner_margin  = 6;

riser_len_y = 33;
riser_rise_z = 20;
riser_top_width_x = 56;
riser_top_len_y = 39;         // widen front-back from 33 to 39

// Vertical capture frame at top of taper
capture_open_w = 50;          // opening width (X)
capture_open_d = 31.5;        // opening depth (Y), estimated
capture_back_w = riser_top_width_x; // backplane width matches side-support width
capture_lip_w = capture_back_w;     // lip/upper cap width matches backplane
capture_side_h = 12;          // side rise above taper
capture_lip_top_h = 57.5;     // fixed capture/lip top height above taper
capture_back_wall_d = 3;      // back wall thickness (Y)
capture_top_arm_z = 3;        // top extension thickness
capture_top_overhang_y = 2;   // extend top arm this much past the opening front
capture_drop_lip_y = 3;       // front lip depth (Y)
capture_drop_lip_z = 4;       // front lip drop (Z)
capture_join_eps = 0.05;      // tiny overlap so joined parts do not appear floating
capture_bottom_bump_y = 1;    // bottom front snap bump depth
capture_bottom_bump_z = 1;    // bottom front snap bump height

tripod_hole_d = 6.5;          // 1/4-20 close clearance (nominal major dia is 6.35)
tripod_hole_center_above_taper = 24.5;  // hole center above taper top

m3_clearance_d = 3.2;   // M3 close clearance; tighten/ream after test print if needed

// Modifier-mesh bosses for local 100% infill zones in slicer
m3_boss_r = 10;         // requested: 10mm outer radius around each M3 hole
tripod_boss_r = 12;     // suggested outer radius around 1/4-20 hole

// Raspberry Pi 4B mounting (M2.5, 58 x 49 mm hole pattern)
pi_hole_spacing_x = 58;
pi_hole_spacing_z = 49;
pi_mount_offset_x = 5;      // left standoff flush to left back edge, keep full Pi spacing
pi_standoff_h = 8;         // standoff height off backplane
pi_standoff_d = 8;         // cylindrical standoff diameter
pi_insert_pilot_d = 3.35;  // for M2.5 x D3.5 inserts (tune by material/printer)
pi_insert_depth = 4.8;     // for L4 inserts with a small seating margin

// Backplane side lobes (for future inset mounting bosses)
back_lobe_h = pi_standoff_d;          // just cover one Pi standoff cylinder
back_lobe_left_w = 0;                 // flush on one side
capture_back_total_h = pi_hole_spacing_z + back_lobe_h + 0.5; // match forward continuation top

// Connector tunnel through tapered section (front-to-back)
taper_tunnel_w = 25;    // X width
taper_tunnel_h = 14;    // Z height
taper_tunnel_top_above_taper = 3; // force tunnel top above taper transition

// --- Hole centers (XY), local origin at front-row center ---
hole_pts_local = [
    [-front_spacing/2,  0],            // front left
    [ front_spacing/2,  0],            // front right
    [-rear_spacing/2,  -row_spacing],  // rear left
    [ rear_spacing/2,  -row_spacing]   // rear right
];

// Transform local coordinates to absolute frame coordinates.
hole_pts = [
    for (p = hole_pts_local)
        [p[0] + front_center_abs[0], p[1] + front_center_abs[1]]
];

// Compute base bounds from hole envelope + margin
min_x = min([for (p = hole_pts) p[0]]) - corner_margin;
max_x = max([for (p = hole_pts) p[0]]) + corner_margin;
min_y = min([for (p = hole_pts) p[1]]) - corner_margin;
max_y = max([for (p = hole_pts) p[1]]) + corner_margin;

base_w = max_x - min_x;
base_l = max_y - min_y;
base_center_x = (min_x + max_x) / 2;
base_center_y = (min_y + max_y) / 2;
z_taper_top = base_thickness + riser_rise_z;
outer_y_min_global = base_center_y - riser_top_len_y / 2;
tripod_hole_y = outer_y_min_global + capture_back_wall_d / 2;
tripod_hole_center_z = z_taper_top + tripod_hole_center_above_taper;
taper_tunnel_center_z = z_taper_top + taper_tunnel_top_above_taper - taper_tunnel_h / 2;
taper_tunnel_depth_y = max(riser_len_y, riser_top_len_y) + 2;
pi_mount_center_z = z_taper_top + capture_back_total_h / 2;
back_lobe_right_w = (
    (base_center_x + pi_mount_offset_x + pi_hole_spacing_x / 2 + pi_standoff_d / 2)
    - (base_center_x + capture_back_w / 2)
);                                    // exact protrusion to right standoff tangent
downhill_x_min = base_center_x - capture_back_w / 2 - back_lobe_left_w; // left support edge (uphill)

// Subroutine/module for through-hole cutter
module m3_hole(h) {
    cylinder(d = m3_clearance_d, h = h, center = false);
}

// Export helper: modifier cylinders for slicer infill control
// (export these as separate STLs and set modifier regions to solid in slicer)
module m3_modifier_bosses(h = base_thickness) {
    for (p = hole_pts) {
        translate([p[0], p[1], 0])
            cylinder(r = m3_boss_r, h = h, center = false);
    }
}

module tripod_modifier_boss(h = capture_back_wall_d + 2) {
    translate([base_center_x, tripod_hole_y, tripod_hole_center_z])
        rotate([90, 0, 0])
            cylinder(r = tripod_boss_r, h = h, center = true);
}

module modifier_meshes() {
    m3_modifier_bosses();
    tripod_modifier_boss();
    pi_modifier_bosses();
}

function pi_hole_positions() = [
    [base_center_x + pi_mount_offset_x - pi_hole_spacing_x / 2, pi_mount_center_z - pi_hole_spacing_z / 2],
    [base_center_x + pi_mount_offset_x + pi_hole_spacing_x / 2, pi_mount_center_z - pi_hole_spacing_z / 2],
    [base_center_x + pi_mount_offset_x - pi_hole_spacing_x / 2, pi_mount_center_z + pi_hole_spacing_z / 2],
    [base_center_x + pi_mount_offset_x + pi_hole_spacing_x / 2, pi_mount_center_z + pi_hole_spacing_z / 2]
];

module pi_standoffs(back_face_y) {
    for (p = pi_hole_positions()) {
        translate([p[0], back_face_y - pi_standoff_h / 2, p[1]])
            rotate([90, 0, 0])
                cylinder(d = pi_standoff_d, h = pi_standoff_h, center = true);
    }
}

module pi_insert_pilots(back_face_y) {
    for (p = pi_hole_positions()) {
        translate([p[0], back_face_y - pi_standoff_h, p[1]])
            rotate([90, 0, 0])
                cylinder(d = pi_insert_pilot_d, h = pi_insert_depth, center = false);
    }
}

// Export helper: modifier cylinders around Pi insert bosses.
// Export as separate STL and set these zones to 100% infill in slicer.
module pi_modifier_bosses() {
    back_face_y = outer_y_min_global;
    for (p = pi_hole_positions()) {
        translate([p[0], back_face_y - pi_standoff_h / 2, p[1]])
            rotate([90, 0, 0])
                cylinder(d = pi_standoff_d, h = pi_standoff_h, center = true);
    }
}

// Base plate
module base_plate() {
    plate_x_min = min(min_x, downhill_x_min);
    translate([plate_x_min, min_y, 0])
        cube([max_x - plate_x_min, base_l, base_thickness], center = false);
}

// Staged riser:
// 1) taper up 20mm while widening to 56x39
// 2) build vertical capture frame with central opening
module riser() {
    y0 = base_center_y;
    z0 = base_thickness;
    z1 = z0 + riser_rise_z;

    outer_x_min = min(base_center_x - riser_top_width_x / 2, downhill_x_min);
    outer_x_max = base_center_x + riser_top_width_x / 2;
    outer_y_min = y0 - riser_top_len_y / 2;
    back_face_y = outer_y_min;
    outer_y_max = y0 + riser_top_len_y / 2;
    z_back_top = z1 + capture_lip_top_h;
    top_back_y = outer_y_min + capture_back_wall_d; // start at back-wall front face
    top_front_y = outer_y_max + capture_top_overhang_y;
    top_arm_y = top_front_y - top_back_y;

    open_x_min = base_center_x - capture_open_w / 2;
    open_x_max = base_center_x + capture_open_w / 2;

    union() {
        // 1) Tapered widening section
        hull() {
            bottom_x_min = min(min_x, downhill_x_min);
            bottom_x_max = max_x;
            top_x_min = outer_x_min;
            top_x_max = outer_x_max;

            translate([(bottom_x_min + bottom_x_max) / 2, y0, z0])
                cube([bottom_x_max - bottom_x_min, riser_len_y, 0.01], center = true);
            translate([(top_x_min + top_x_max) / 2, y0, z1])
                cube([top_x_max - top_x_min, riser_top_len_y, 0.01], center = true);
        }

        // 2a) Left side wall
        translate([(outer_x_min + open_x_min) / 2, y0, z1 + capture_side_h / 2])
            cube([open_x_min - outer_x_min, riser_top_len_y, capture_side_h], center = true);

        // 2b) Right side wall
        translate([(open_x_max + outer_x_max) / 2, y0, z1 + capture_side_h / 2])
            cube([outer_x_max - open_x_max, riser_top_len_y, capture_side_h], center = true);

        // 2c) Tall back wall
        translate([base_center_x, outer_y_min + capture_back_wall_d / 2, z1 + capture_back_total_h / 2])
            cube([capture_back_w, capture_back_wall_d, capture_back_total_h], center = true);

        // 2c.1) Upper side lobes on back wall for Pi boss support
        if (back_lobe_left_w > 0)
            translate([
                base_center_x - capture_back_w / 2 - back_lobe_left_w / 2,
                outer_y_min + capture_back_wall_d / 2,
                pi_mount_center_z + pi_hole_spacing_z / 2
            ])
                cube([back_lobe_left_w, capture_back_wall_d, back_lobe_h], center = true);
        if (back_lobe_right_w > 0)
            translate([
                base_center_x + capture_back_w / 2 + back_lobe_right_w / 2,
                outer_y_min + capture_back_wall_d / 2,
                pi_mount_center_z + pi_hole_spacing_z / 2
            ])
                cube([back_lobe_right_w, capture_back_wall_d, back_lobe_h], center = true);

        // 2c.2) Lower side lobes so lower hole row also has boss coverage
        if (back_lobe_left_w > 0)
            translate([
                base_center_x - capture_back_w / 2 - back_lobe_left_w / 2,
                outer_y_min + capture_back_wall_d / 2,
                pi_mount_center_z - pi_hole_spacing_z / 2
            ])
                cube([back_lobe_left_w, capture_back_wall_d, back_lobe_h], center = true);
        if (back_lobe_right_w > 0)
            translate([
                base_center_x + capture_back_w / 2 + back_lobe_right_w / 2,
                outer_y_min + capture_back_wall_d / 2,
                pi_mount_center_z - pi_hole_spacing_z / 2
            ])
                cube([back_lobe_right_w, capture_back_wall_d, back_lobe_h], center = true);

        // 2d) Top extension forward from the back wall
        translate([base_center_x, (top_back_y + top_front_y) / 2, z_back_top - capture_top_arm_z / 2])
            cube([capture_lip_w, top_arm_y, capture_top_arm_z], center = true);

        // 2e) Downward front lip at the end of the top extension
        translate([
            base_center_x,
            top_front_y - capture_drop_lip_y / 2,
            z_back_top - capture_top_arm_z - capture_drop_lip_z / 2 + capture_join_eps / 2
        ])
            cube([capture_lip_w, capture_drop_lip_y, capture_drop_lip_z + capture_join_eps], center = true);

        // 2f) Bottom front snap bump at top of taper (1mm x 1mm)
        translate([
            base_center_x,
            outer_y_max - capture_bottom_bump_y / 2,
            z1 + capture_bottom_bump_z / 2
        ])
            cube([capture_open_w, capture_bottom_bump_y, capture_bottom_bump_z], center = true);

        // 3) Pi standoffs on reverse side of backplane
        pi_standoffs(back_face_y);
    }
}

// Main part with mounting holes
difference() {
    union() {
        base_plate();
        riser();
    }

    // through holes in base
    for (p = hole_pts) {
        translate([p[0], p[1], -0.2])  // slight overshoot for robust subtraction
            m3_hole(base_thickness + 0.4);
    }

    // 1/4-20 clearance hole in back wall, centered horizontally.
    // Axis is front-back (Y), center is 24.5mm above flat bottom.
    translate([base_center_x, tripod_hole_y, tripod_hole_center_z])
        rotate([90, 0, 0])
            cylinder(d = tripod_hole_d, h = capture_back_wall_d + 2, center = true);

    // Front-to-back connector tunnel through tapered section.
    translate([base_center_x, base_center_y, taper_tunnel_center_z])
        cube([taper_tunnel_w, taper_tunnel_depth_y, taper_tunnel_h], center = true);

    // M2.5 insert pilot holes in Pi standoffs (blind from Pi side).
    pi_insert_pilots(outer_y_min_global);
}