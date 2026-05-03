// OpenSCAD reference blanks for Rekon pod design.
// Units: mm
//
// Sources used:
// - Pi Zero 2 W mechanical drawing:
//   https://pip-assets.raspberrypi.com/categories/584-raspberry-pi-zero-2-w/documents/RP-008358-DS-1-raspberry-pi-zero-2-w-mechanical-drawing.pdf
// - Camera Module 3 standard mechanical drawing:
//   https://datasheets.raspberrypi.com/camera/camera-module-3-standard-mechanical-drawing.pdf
//
// Coordinate convention for all modules:
// - XY plane is board plane.
// - Z+ is "up" from component side.
// - Origin is board center unless otherwise noted.

$fn = 48;

// Canonical mechanical facts (not config):
PI_ZERO2W_PCB_X = 65;
PI_ZERO2W_PCB_Y = 30;
PI_ZERO2W_PCB_Z = 1.6;
PI_ZERO2W_HOLE_D = 2.75;
PI_ZERO2W_HOLE_SPACING_X = 58;
PI_ZERO2W_HOLE_SPACING_Y = 23;

CM3_STD_PCB_X = 25;
CM3_STD_PCB_Y = 23.862;
CM3_STD_PCB_Z = 1.12;
CM3_STD_HOLE_D = 2.2;
CM3_STD_HOLE_EDGE_OFFSET = 2.0;
CM3_STD_HEIGHT_Z = 11.5;

// ----------------------------
// Raspberry Pi Zero 2 W blank
// ----------------------------
//
// Includes:
// - PCB plate
// - Through-hole cuts in PCB
// - Optional full-height envelope (for interference checks)
module pi_zero2w_blank(
    show_envelope = true,
    envelope_z = 12.4,
    envelope_alpha = 0.25
) {
    color([0.07, 0.45, 0.12])
    difference() {
        translate([-PI_ZERO2W_PCB_X / 2, -PI_ZERO2W_PCB_Y / 2, 0])
            cube([PI_ZERO2W_PCB_X, PI_ZERO2W_PCB_Y, PI_ZERO2W_PCB_Z], center = false);
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * PI_ZERO2W_HOLE_SPACING_X / 2, sy * PI_ZERO2W_HOLE_SPACING_Y / 2, -0.2])
                cylinder(d = PI_ZERO2W_HOLE_D, h = PI_ZERO2W_PCB_Z + 0.4, center = false);
        }
    }

    // Envelope is centered on board footprint and starts at PCB bottom.
    if (show_envelope) {
        color([0.8, 0.8, 0.8, envelope_alpha])
            translate([-PI_ZERO2W_PCB_X / 2, -PI_ZERO2W_PCB_Y / 2, 0])
                cube([PI_ZERO2W_PCB_X, PI_ZERO2W_PCB_Y, envelope_z], center = false);
    }
}

// -----------------------------------
// Raspberry Pi Camera Module 3 (standard)
// -----------------------------------
//
// Includes:
// - PCB plate
// - Through-hole cuts in PCB
// - Optional body envelope
// - Optional lens keepout (mechanical proxy only, not optical FOV)
// - Optional optical frustum (CM3 standard nominal FOV, for visibility checks)
module camera_module3_blank(
    show_body_envelope = true,
    show_lens_keepout = true,
    show_view_frustum = false,
    body_envelope_alpha = 0.25,
    lens_keepout_d = 14.5,
    lens_keepout_h = 9.0,
    lens_keepout_alpha = 0.35,
    frustum_hfov_deg = 66,
    frustum_vfov_deg = 41,
    frustum_depth = 80,
    frustum_near = 1.0,
    frustum_alpha = 0.22
) {
    hole_spacing_x = CM3_STD_PCB_X - 2 * CM3_STD_HOLE_EDGE_OFFSET;
    hole_spacing_y = CM3_STD_PCB_Y - 2 * CM3_STD_HOLE_EDGE_OFFSET;
    frustum_near_w = 2 * frustum_near * tan(frustum_hfov_deg / 2);
    frustum_near_h = 2 * frustum_near * tan(frustum_vfov_deg / 2);
    frustum_far_w = 2 * frustum_depth * tan(frustum_hfov_deg / 2);
    frustum_far_h = 2 * frustum_depth * tan(frustum_vfov_deg / 2);
    lens_origin_z = CM3_STD_PCB_Z + lens_keepout_h;

    color([0.10, 0.55, 0.10])
    difference() {
        translate([-CM3_STD_PCB_X / 2, -CM3_STD_PCB_Y / 2, 0])
            cube([CM3_STD_PCB_X, CM3_STD_PCB_Y, CM3_STD_PCB_Z], center = false);
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * hole_spacing_x / 2, sy * hole_spacing_y / 2, -0.2])
                cylinder(d = CM3_STD_HOLE_D, h = CM3_STD_PCB_Z + 0.4, center = false);
        }
    }

    if (show_body_envelope) {
        color([0.65, 0.65, 0.65, body_envelope_alpha])
            translate([-CM3_STD_PCB_X / 2, -CM3_STD_PCB_Y / 2, 0])
                cube([CM3_STD_PCB_X, CM3_STD_PCB_Y, CM3_STD_HEIGHT_Z], center = false);
    }

    // Lens module keepout proxy at board center.
    // This is a mechanical collision envelope around lens housing only.
    if (show_lens_keepout) {
        color([0.15, 0.15, 0.15, lens_keepout_alpha])
            translate([0, 0, CM3_STD_PCB_Z])
                cylinder(d = lens_keepout_d, h = lens_keepout_h, center = false);
    }

    // Optical view frustum along +Z from an approximate lens origin.
    // Useful for quick sightline checks in pod geometry.
    if (show_view_frustum) {
        color([0.15, 0.45, 1.0, frustum_alpha])
            translate([0, 0, lens_origin_z])
                hull() {
                    translate([0, 0, frustum_near])
                        cube([frustum_near_w, frustum_near_h, 0.01], center = true);
                    translate([0, 0, frustum_depth])
                        cube([frustum_far_w, frustum_far_h, 0.01], center = true);
                }
    }
}

// ----------------
// Quick demo layout
// ----------------
show_demo = false;
if (show_demo) {
    translate([-35, 0, 0]) pi_zero2w_blank();
    translate([35, 0, 0]) camera_module3_blank();
}
