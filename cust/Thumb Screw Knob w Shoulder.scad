/*
 * Given a hex screw or hex nut (or square);
 * convert to thumb screw.
 * There are many other designs like this already
 * but this one also has a scalable shoulder feature.
 */

use <../hw_pockets.scad>
use <../hw_features.scad>
use <../hwlookup.scad>

// [snug, close, loose, gap]
margins = [.08, .2, .26, .5];

// e.g. "I8" or "M4"
size = "M5";

type = 2; //[2: hex, 3: square]

// height of nut over base
H_nut = 2; //0.1

// widen the stance
stancecone = 0; //0.1

// diameter at bottom
OD1 = 11.1; //0.1

// height where taper begins
H1 = 14; //0.1

// height of taper
H1b = 8; //0.1

// diameter at handle
OD2 = 20; //0.1

// height of handle
H2 = 8; //0.1

// bevel at top
bevel = 2; //0.1

// number of indentations
N_dent = 5;

// diameter of indentations
dent_dia = 8; //0.1

// proportion of diameter of indentation inside OD2
dent_prop = 0.35; //0.01

module _endc_ () {}

$fa=1;
$fs=.2;

function d_taper(h) = OD1+(h-H1)*(OD2-OD1)/(H1b);

module check_d_crit() {
    echo("=== Critical Wall Check ===");
    echo("    (at bottom of nut)");
    // first calculate major dia of nut
    spec = hw_getspec(size);
    c = (type==2)? cos(30) : cos(45);
    minor = (type==2)? hw_hex(spec)[0] : hw_squ(spec)[0];
    d_nut = (minor+2*margins[0])/c;
    d_crit = (H_nut <= H1) ? OD1 :
        ((H_nut <= (H1b+H1)) ? d_taper(H_nut) : OD2);
    wall = (d_crit - d_nut)/2;
    echo("Wall: ", wall);
    echo(" = (", d_crit, " - ", d_nut, ")/2");
    if (wall < 0.8)
        echo("^ WARNING ^");
}

module body() {
    cylinder(h=H1, d=OD1);
    translate([0, 0, H1])
    cylinder(h=H1b, d1=OD1, d2=OD2);
    translate([0, 0, H1+H1b])
    cylinder(h=H2-bevel, d=OD2);
    translate([0, 0, H1+H1b+H2-bevel])
    cylinder(h=bevel, d1=OD2, d2=OD2-2*bevel);
}

module pockets() {
    neg_hardware(size, type, H_nut, plate=H1+H1b+H2+.1, stancecone=stancecone, margins=margins);
    translate([0, 0, H1])
    neg_thumb_circumscribe(N_dent, OD2, dent_dia, dent_prop, H1b+H2);
}

difference() {
    union() body();
    pockets();
}
check_d_crit();
