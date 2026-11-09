/* 'Fixed Mount Prism Cage'
 * Fixed mount on cage,
 * usually for prism but sometimes
 * useful for a cylinder lens, etc.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_features.scad>
use <../logo.scad>

with_logo = true;

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

// [x, y, z] Dimensions of body plate
plate = [50, 50, 18];

// Size of prism setscrews
ss_size = "M4";

// nut type for prism setscrews
ss_nuttype = 2; //[2: hex, 3: square, 4: tapped]

// [x, y, z] nominal dimensions of prism
prism = [12, 12, 12];

// pad prism pocket along +x axis
xpad = 2;

// pad prism pocket along +y axis
ypad = 2;

// bore a path for beam along -x
xborepath = true;

// bore a path for beam along -y
yborepath = false;

// if >0, override auto ID of bore-paths
ID_bore = 0;

// baffles in bore-paths: [radial, pitch]
bore_baffles = [0.9, 3]; //0.1

// [rod, oncenter, AOI]
cage = [6.35, 30, 0];

cage_setscrew = "M3";

cage_nuttype = 2; //[2: hex, 3: square, 4: tapped]

// 0 means cage at an AOI intercepts center at the back of optic
cageAOI_center = 0;

// if cage has AOI: faster preview at expense of accuracy
fastcagepreview = true;

module _endc_ () {}

$fa=1;
$fs=.1;

ss_length = max(plate[0], plate[1]);

difference() {
    union () {
        // body
        cube(plate, center=true);
        if (with_logo) {
            translate([-plate[0]/2, -plate[1]/2+6, 0])
            rotate([0, -90, 0])
            logo(xyscale=12);
        }
    }
    // cage attachment
    rad_ss = max(plate[0], plate[1]) - cage[1] + 1;
    translate([0, 0, -plate[2]/2])
    neg_cage1(cage[0], cage[1], plate[2], cage_setscrew, rad_ss, ss_angle=-1,  ss_nut_type=cage_nuttype, AOI=cage[2], margins=margins, topaccess=true, overbore=2, fast=fastcagepreview&&$preview);
    // prism mount
    neg_prismmount(prism, plate[2], xpad, ypad, ss_length, ss_size, ss_nuttype=ss_nuttype, margins=margins);
    // bore paths
    d_maj = (ID_bore>0)? ID_bore : prism[2]-0.8;
    d_min = d_maj - 2*bore_baffles[0];
    if (xborepath) {
        h = (plate[0] - prism[0])/2;
        translate([-prism[0]/2, 0])
        rotate([0, -90, 0])
        //cylinder(h=plate[0]/2+1, d=bore);
        neg_cyl_baffled(h, d_min, d_maj, bore_baffles[1]);
    }
    if (yborepath) {
        h = (plate[1] - prism[1])/2;
        translate([0, -prism[1]/2])
        rotate([90, 0, 0])
        //cylinder(h=h, d=d_maj);
        neg_cyl_baffled(h, d_min, d_maj, bore_baffles[1]);
    }
}

/* TODO
 *
 * open-shoulder (top or right)
 */
