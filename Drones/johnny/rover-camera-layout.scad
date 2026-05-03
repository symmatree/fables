// Rover camera layout study for 8x CM3 around a 5.5" x 18" deck.
// Units: mm
use <../rekon10/components/pi-blanks.scad>

$fn = 48;

IN = 25.4;

// Carrier board / vehicle envelope requested:
deck_w = 5.5 * IN;      // X width
deck_l = 18 * IN;       // Y length
vehicle_h = 7 * IN;     // Z from ground to top of vehicle blank

// Camera height and ground reference:
camera_center_z = 8 * IN;               // "ground is 8 inches below cameras"
ground_z = camera_center_z - 8 * IN;    // this evaluates to 0

// Camera posture:
camera_elevation_deg = 15;              // +15 up from horizon
frustum_depth = 3000;                   // long for visibility checks
camera_roll_deg = 90;                   // rotate image frame (portrait->landscape)
show_centerlines = true;
centerline_len = 900;
centerline_d = 1.6;

// Corner placement:
corner_inset_x = 10;
corner_inset_y = 12;
pair_spacing = 28;                      // separation between two cameras at each corner

// Azimuth: 0 = +Y (forward), +90 = +X (right), -90 = -X (left).
// Elevation: 0 = horizon, +90 = straight up.
//
// We orient local +Z into the requested aim vector using explicit yaw + pitch:
// 1) pitch around local Y by (90 - el) to move +Z toward horizon
// 2) yaw around global Z by (90 - az) to set compass direction
module orient_camera_az_el(az_deg, el_deg) {
    rotate([0, 0, 90 - az_deg])
        rotate([0, 90 - el_deg, 0])
            children();
}

module camera_node(label, x, y, az_deg, el_deg = camera_elevation_deg) {
    // Label pillar + text marker at ground level for orientation debugging.
    color([0.85, 0.85, 0.85, 0.5])
        translate([x, y, ground_z])
            cylinder(d = 3, h = camera_center_z - ground_z, center = false);

    color([1.0, 1.0, 1.0])
        translate([x, y, ground_z + 2])
            linear_extrude(height = 0.8)
                text(label, size = 8, halign = "center", valign = "center");

    // Camera module at optical center height, aimed by az/el.
    translate([x, y, camera_center_z])
        orient_camera_az_el(az_deg, el_deg)
            rotate([0, 0, camera_roll_deg]) {
                camera_module3_blank(
                    show_body_envelope = true,
                    show_lens_keepout = true,
                    show_view_frustum = true,
                    frustum_hfov_deg = 66,
                    frustum_vfov_deg = 41,
                    frustum_depth = frustum_depth,
                    frustum_alpha = 0.14
                );

                // Boresight centerline (local +Z) for orientation sanity checks.
                if (show_centerlines)
                    color([1.0, 0.2, 0.2, 0.85])
                        translate([0, 0, 0])
                            cylinder(d = centerline_d, h = centerline_len, center = false);
            }
}

module rover_blanks() {
    // Ground rectangle.
    color([0.40, 0.30, 0.20, 0.35])
        translate([-deck_w / 2, -deck_l / 2, ground_z - 0.2])
            cube([deck_w, deck_l, 0.2], center = false);

    // Vehicle blank (same XY as deck, top at 7").
    color([0.2, 0.2, 0.2, 0.20])
        translate([-deck_w / 2, -deck_l / 2, ground_z])
            cube([deck_w, deck_l, vehicle_h], center = false);

    // Deck top marker.
    color([0.7, 0.7, 0.7, 0.30])
        translate([-deck_w / 2, -deck_l / 2, ground_z + vehicle_h - 1.6])
            cube([deck_w, deck_l, 1.6], center = false);
}

module camera_layout() {
    xL = -deck_w / 2 + corner_inset_x;
    xR =  deck_w / 2 - corner_inset_x;
    yF =  deck_l / 2 - corner_inset_y;
    yB = -deck_l / 2 + corner_inset_y;

    // Front-left pair: NNW, WSW
    camera_node("NNW", xL + pair_spacing / 2, yF, -22.5);
    camera_node("WSW", xL - pair_spacing / 2, yF, -112.5);

    // Front-right pair: NNE, ESE
    camera_node("NNE", xR - pair_spacing / 2, yF, 22.5);
    camera_node("ESE", xR + pair_spacing / 2, yF, 112.5);

    // Rear-right pair: ENE, SSE
    camera_node("ENE", xR + pair_spacing / 2, yB, 67.5);
    camera_node("SSE", xR - pair_spacing / 2, yB, 157.5);

    // Rear-left pair: SSW, WNW
    camera_node("SSW", xL + pair_spacing / 2, yB, -157.5);
    camera_node("WNW", xL - pair_spacing / 2, yB, -67.5);
}

rover_blanks();
camera_layout();
