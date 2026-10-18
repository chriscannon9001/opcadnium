/*
 * Adapter Plate to Tube, Clamp
 *
 */

include <../hw.scad>

// don't print the vitamins!
vitamins = true;

// ID of tube clamp
ID = 12.7;

wallthick = 1.6;

// Extruded length of body
L = 30;

// if T_flange > 0, a flange is formed, good for wider set of base screw
T_flange = 3;

// Width of flange
W_flange = 14;

gap = 3;

// L_jaw - protruding length of jaw
L_jaw = 7.5;

// W_jaw - width of jaw
W_jaw = 8;

N_clampscrew = 2;

size_clampscrew = "M3";

base_screw = "M4";

base_screwtype = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead]

base_Lshaft = 1;

base_N = [2, 1];

base_pitch = [19.5, 12.5];

module _endc_() {}

$fa=1;
$fs=.2;

zback = ID/2 + 2*wallthick + T_flange;


module coord_base() {
    rotate([-90, 0, 0])
    for (i=[1:base_N[0]]) for (j=[1:base_N[1]]) {
        y = base_pitch[0]*(i-base_N[0]/2-.5);
        x = base_pitch[1]*(j-base_N[1]/2-.5);
        translate([x, y, -zback])
        children();
    }
}

difference() {
    union () {
        translate([0, 0, -L/2])
        collar_clamp(ID, L, wallthick, L_jaw, W_jaw, gap, N_clampscrew, size_clampscrew, 2);
        if (T_flange > 0)
        translate([-W_flange/2, -zback])
        linear_extrude(L, center=true) {
            square([W_flange, T_flange]);
        }
    }
    //
    coord_base()
    neg_hardware(base_screw, base_screwtype, base_Lshaft, plate=zback);
}

if (vitamins) color("silver") {
    coord_base()
    vit_hardware(base_screw, base_screwtype, base_Lshaft, TLshaft=base_Lshaft+3);
}
