/*
 * Adapter Plate to Tube, Setscrew
 *
 */

include <../hw.scad>

// don't print the vitamins!
vitamins = true;

// ID of tube clamp
ID = 12.7;

// tolerance on tube diameter
ID_tol = 0.3;

// OD of D shape body
OD = 26;

// Thickness from OD to edge of D (also affects flange)
D_thick = 4;

// if W_flange > OD, a flange is formed, good for wider set of base screws
W_flange = 0;

// Extruded length of body
L = 30;

// size of setscrew
ss_size = "M4";

// type of setscrew
ss_type = 2; //[2: hex, 3: square, 4: tapped]

// length of shaft 
ss_Lshaft = 2.5;

ss_wart = 2.5;

ss_useaccess = true;

base_screw = "M4";

base_screwtype = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead]

base_Lshaft = 2;

base_N = [2, 1];

base_pitch = [19.5, 12.5];

module _endc_() {}

$fa=1;
$fs=.2;
ss_x = -OD/2-ss_wart;

module extruded_body() {
    linear_extrude(L, center=true) difference() {
        union() {
            hull() {
                circle(d=OD);
                translate([OD/2, -OD/2])
                square([D_thick, OD]);
            }
            if (W_flange > OD) {
                translate([OD/2, -W_flange/2])
                square([D_thick, W_flange]);
            }
        }
        // 
        sketch_precision_bore(ID, ID_tol, rotation=180);
    }
}

module coord_base() {
    rotate([0, -90, 0])
    for (i=[1:base_N[0]]) for (j=[1:base_N[1]]) {
        x = base_pitch[0]*(i-base_N[0]/2-.5);
        y = base_pitch[1]*(j-base_N[1]/2-.5);
        translate([x, y, -OD/2-D_thick])
        children();
    }
}

difference() {
    macc = ss_useaccess ? L/2 : 0;
    union() {
        extruded_body();
        if (ss_wart > 0) {
            // setscrew wart
            h = (OD-ID)/2+ss_wart-2*ID_tol;
            d1 = 10;
            d2 = d1+h*.35*2;
            translate([ss_x, 0])
            rotate([0, 90, 0])
            cylinder(h=h, d1=d1, d2=d2);
        }
    }
    translate([ss_x, 0])
    rotate([0, 90, 0])
    rotate(180)
    neg_hardware(ss_size, ss_type, ss_Lshaft, sink=ID/2, capture=ss_useaccess, minor_access=macc);
    //
    coord_base()
    neg_hardware(base_screw, base_screwtype, base_Lshaft, sink=OD+D_thick);
}

if (vitamins) {
    translate([ss_x, 0])
    rotate([0, 90, 0])
    rotate(180)
    color("silver")
    vit_hardware(ss_size, ss_type, ss_Lshaft, TLshaft=ss_Lshaft+3);
    //
    color("silver")
    coord_base()
    vit_hardware(base_screw, base_screwtype, base_Lshaft, TLshaft=base_Lshaft+3);
}
