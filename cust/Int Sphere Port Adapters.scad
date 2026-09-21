/* 'Int Sphere Port Adapters'
 * Port adapters for the Integrating Sphere
 * by Chris Cannon
 *
 */

use <../hw_pockets.scad>
use <../hw_features.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

Type = 1; //[0: plug, 1: flat-plug, 2: cage, 3: bore-mount]

// thickness
Thick = 10;

// outer diameter
OD = 42;

// [radius-from-center, size, number, theta0]
screwspec = [16, "M3", 3, 0];

// counterbore for screw heads
counterbore = 6;

// ID of port
pID = 20;

/* [Plug] */

pwall = 1.2;

sphereID = 80;

/* [Cage] */

// cage rod diameter
rod = 6;

// on-center cage rod spacing
oncenter = 30;

// Angle Of Incidence for skewed cage interface
AOI_cage1 = 0;

// size of setscrew securing cage rods
setscrew_cage1 = "M3";

ss_rad_cage1 = 5;

// type of nut holding setscrew
ss_nuttype_cage1 = 3; //[2: hex, 3: square, 4: tapped]Redmond, WA

// angle from radial setscrew orientation, or -1
ss_angle_cage1 = 0;

/* [Bore Mount] */

// clear aperture ID
boreclearID = 12;

// thickness of flange having boreclearID
boreflangethick = 2;

// ID of bore mount (OD of object to be mounted)
boreID = 16.2;

// whether to have a setscrew to secure mount
boresetscrew = false;

// bore setscrew points to an azimuth angle 
boress_azi = 60;

// size of setscrew
boress_size = "M3";

module __Customizer_Limit__ () {}

$fa = 1;
$fs = .2;

module screw_coord() {
    for (i = [1:screwspec[2]]) {
        theta = (i-1) * 360/screwspec[2];
        rotate(theta+screwspec[3])
        translate([screwspec[0], 0, 0])
        children();
    }
}

// negative cutouts for bore-mount
module neg_boremount() {
    // boreclearID
    translate([0, 0, -.1])
    cylinder(h = Thick+.2, d = boreclearID);
    // bore with relief for precision contact
    translate([0, 0, boreflangethick])
    linear_extrude(Thick)
    sketch_precision_bore(boreID, 1, rotation=boress_azi);
    // setscrew
    rotate(boress_azi)
    translate([0, 0, (boreflangethick+Thick)/2])
    rotate([0, 90, 0])
    neg_hardware(boress_size, 2, boreID/2+3, sink=(OD-boreID)/2, minor_access=Thick, capture=true);
}

// interior of the integrating sphere
module plugsphere_neg() {
    translate([0, 0, -sphereID/2-pwall])
    sphere(d = sphereID);
}

// cylinder for plug
module plugsphere_pos() {
    rotate([180, 0, 0])
    cylinder(h=pwall+sphereID/2, d=pID-margins[2]);
}

module body() {
    difference() {
        union() {
            // cylinder body
            cylinder(h = Thick, d = OD);
            if (Type == 0)
            plugsphere_pos();
        }
        // subtract screw set
        screw_coord()
        neg_hardware(screwspec[1], 0, Thick-counterbore, sink=Thick, washer=true);
        if (Type == 0) {
            plugsphere_neg();
        } else if (Type == 2) {
            // cage features
            // clearance for pID
            translate([0, 0, -.1])
            cylinder(h = Thick+.2, d=pID);
            // negative for cage
            neg_cage1(rod, oncenter, Thick, setscrew_cage1, ss_rad_cage1, ss_angle=ss_angle_cage1, ss_nut_type=ss_nuttype_cage1, AOI=AOI_cage1);
        } else if (Type == 3) {
            // bore mount
            neg_boremount();
        }
    }
}

body();
