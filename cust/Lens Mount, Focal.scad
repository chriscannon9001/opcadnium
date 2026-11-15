/* 'Lens Mount, Focal'
 * A lens mount with precision focal adjuster.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_pockets.scad>
use <../hw_features.scad>
use <../flexure.scad>
use <../logo.scad>

vitamins = true;

with_logo = true;

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

/* [Cage Plate] */

skip_cage = false;

Cage_setscrew = "M3";

Cage_nuttype = 3; //[2: hex, 3: square, 4: tapped]

// depth of plate1 for cage
D_plate1 = 44;

// cut back actual plate1 depth; no change to centering
D_cutback1 = 0;

// length of plate1
L_plate1 = 50;

// thickness of plate1
T_plate1 = 11.5;

// if >0, use this for ID in plate1 instead of Diameter
Bore_plate1 = 0;

// [rod, oncenter, AOI]
Cage_rods = [6.35, 30, 0];

/* [Mirror Plate] */

// depth of plate2 for mirror
D_plate2 = 20;

// length of plate2
L_plate2 = 30;

// thickness of plate2
T_plate2 = 9.5;

// Mirror diameter, mm
Diameter = 12.7;

// Mirror diameter tolerance +/-, mm
Dia_tol = .3;

// Inner-diameter, thickness of flange, mm
Flange = [10.8, 1];

// Size of setscrew
Setscrew_size = "M4";

Setscrew_type = 2; //[2: hex, 3: square, 4: tapped]

// Offset (mm) from mirror opening to nut for setscrew
Setscrew_nutoffset = 2.5;

// rotation around y-axis where setscrew is attached
Setscrew_position = 90;

/* [Flexure] */

// [Length, Width, Depth, Gap]
Flex = [22, 16, 12, 2.9];

// total length including arms
L_flexTL = 36;

// I.e. 2x nozzle diameter
Thick_flex = .8;

rh_flex = true;

/* [Actuator] */
Screw_dz = "M3";

Supportthick_dz = 3;

Nuttype_dz = 2; //[2: hex, 3: square, 4: tapped]

// springspec - ["name", OD, wire, free-length, N-coils, isclosed, isflat, 2nd-OD, color]
Spring_spec = ["8x20", 8, .8, 20, 4.8, 1, 0, 0, "red"];

compressedLength = 10;

Actuator_inset = 5;

/* [Base Post] */

base_attach = 0; //[0: None, 1: Right, 2: Clamp]

// Length, width, height of right angle base
RA_base_dimensions = [4, 20, 22];

// What hardware is used for attachment to base
Attach_type = 0; //[0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead]

Attach_washer = true;

Attach_size = "M4"; 

// Thickness under base attach hardware
Attach_thick = 2.5; //0.1

// Move attachment hardware from the center of RA_base
Attach_bias = -0.5; //0.1

// For nuts, access from the side
Attach_access = false;

// Cone pocket under the fastener to spread pressure
Attach_stancecone = 1.5;

// ID, wall-thickness, height of clamp, mm
Clamp_dims = [12.7, 1.6, 13];

// L, W, gap of clamp jaw, mm
Clamp_jaw_dims = [7.1, 7.8, 2.5];

Clamp_Nscrew = 1;

Clamp_screwsize = "M3";

Clamp_nuttype = 2; //[2: hex, 3: square, 4: tapped]

module _end_cust_() {}

$fa = $preview? 5 : 1;
$fs = $preview? .4 : .1;

span = Flex[1] + 2*Flex[3];
s = rh_flex? 1 : -1;

module coord_actuator() {
    x = (span - compressedLength) / 2;
    y = -L_plate1/2 + Actuator_inset;
    z = Flex[2]/2;
    translate([x, s*y, z])
    rotate([0, 90, 0])
    rotate(-s*90)
    children();
}

Base_length = RA_base_dimensions[0];
Base_width = RA_base_dimensions[1];
Base_height = RA_base_dimensions[2];
Clamp_dia = Clamp_dims[0];
Clamp_wall = Clamp_dims[1];
Clamp_H = Clamp_dims[2];
Clamp_L_jaw = Clamp_jaw_dims[0];
Clamp_W_jaw = Clamp_jaw_dims[1];
Clamp_gap = Clamp_jaw_dims[2];
module right_angle_attach() {
    translate([span/2+T_plate1, 0, 0])
    rotate(90)
    rotate([0, 90, 0])
    linear_extrude(Base_width, center=true)
    polygon([[-Base_height, 0], [0, 0], [0, -Base_length]]);
}

difference() {
    union() {
        // plate1
        translate([span/2+T_plate1/2, 0])
        linear_extrude(D_plate1+Flex[2] - D_cutback1)
        square([T_plate1, L_plate1], center=true);
        // plate2
        D2 = D_plate1/2+D_plate2/2;
        translate([-span/2-T_plate2/2, 0]) {
            linear_extrude(D2+Flex[2])
            square([T_plate2, L_plate2], center=true);
            // plate2b
            linear_extrude(Flex[2])
            square([T_plate2, L_plate1], center=true);
        }
        if (with_logo) {
            translate([-span/2-T_plate2, 0, 8])
            rotate([0, -90, 0])
            rotate(-90)
            logo(xyscale=15);
        }
        // backing for the adjuster
        linear_extrude(Flex[2])
        polygon([[-span/2, -s*L_plate1/2],
            [span/2-compressedLength, -s*L_plate1/2],
            [span/2-compressedLength, -s*L_flexTL/2],
            [-span/2, -s*L_flexTL/2]]);
        // flexure
        thick3 = (L_flexTL - Flex[0])/2;
        flexure_translation1(Flex[0], Flex[1], Flex[2], thick1=Thick_flex, thick2=2, thick3=thick3, bias=0);
        // connect flexure across the gap
        for (j = [-1,1]) {
            y = j*s*(Flex[0]/2+thick3/2+.25);
            x = j*(Flex[1]/2+Flex[3]/2);
            translate([x, y])
            linear_extrude(Flex[2])
            square([Flex[3], thick3-.5], center=true);
        }
        if (base_attach==2) {
            // collar clamp type of base attachment
            translate([span/2+T_plate1+Clamp_dia/2, 0, 0])
            rotate(-90)
            collar_clamp(Clamp_dia, Clamp_H, Clamp_wall, Clamp_L_jaw, Clamp_W_jaw, Clamp_gap, Clamp_Nscrew, Clamp_screwsize, Clamp_nuttype, margins=margins);
        } else if (base_attach==1) {
            // extrude for right angle hardware
            right_angle_attach();
        }
    }
    // mirror cutout
    diag = sqrt(D_plate2^2+L_plate2^2);
    translate([-span/2, 0, D_plate1/2+Flex[2]])
    rotate([0, -90, 0])
    neg_shaftsetscrew(diag, T_plate2, Diameter, Dia_tol, Flange, Setscrew_size, Setscrew_type, Setscrew_nutoffset, Setscrew_position, margins=margins);
    // cage rod pockets
    translate([span/2+T_plate1+.05, 0, D_plate1/2+Flex[2]])
    rotate([0, -90, 0]) {
        rad_ss = (D_plate1 - Cage_rods[1])/2 + 1;
        if (!skip_cage)
        neg_cage1(Cage_rods[0], Cage_rods[1], T_plate1+.1, Cage_setscrew, rad_ss, ss_angle=-1,  ss_nut_type=Cage_nuttype, AOI=Cage_rods[2], margins=margins, fast=$preview, overhead=span+T_plate2, overbore=2*margins[3]);
        bore = (Bore_plate1>0)? Bore_plate1 : Diameter;
        cylinder(h=T_plate1+.1, d=bore);
    }
    // actuator pockets
    coord_actuator()
    neg_adjuster_screwnutspring(Screw_dz, Spring_spec, typehead=0, typenut=Nuttype_dz, washer=true, l_compressed=compressedLength, support_thick=Supportthick_dz, access_length=10, overhead=10, margins=margins);
    // right angle attachment hardware
    if (base_attach==1) {
        macc = Attach_access? Base_length/2-Attach_bias : 0;
        translate([span/2+T_plate1+Base_length/2+Attach_bias, 0, 0])
        translate([0, 0, -.01])
        neg_hardware(Attach_size, Attach_type, Attach_thick+.01, sink=-Base_height, washer=Attach_washer, stancecone=Attach_stancecone, capture=Attach_access, minor_access=macc, margins=margins);
    }
}

if (vitamins) {
    coord_actuator()
    vit_adjuster_screwnutspring(Screw_dz, Spring_spec, typehead=0, typenut=Nuttype_dz, washer=true,  l_compressed=compressedLength, support_thick=Supportthick_dz);
}

