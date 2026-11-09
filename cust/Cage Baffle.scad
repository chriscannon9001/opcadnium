/* 'Cage Baffle'
 * Minimalist baffle plate for cages.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_features.scad>
use <../hw_pockets.scad>
use <../logo.scad>

with_logo = true;

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

cage_setscrew = "M3";

cage_nuttype = 4; //[2: hex, 3: square, 4: tapped]

plate = [42, 46, 5];

// [OD, H]
tube = [28, 12];

// [rod, oncenter, AOI]
cage = [6.35, 30, 0];

// ID
ID = 25;

// baffles in internal bore: [radial, pitch]
bore_baffles = [0.9, 3]; //0.1

// if cage has AOI: faster preview at expense of accuracy
fastcagepreview = true;


module body() {
    union() {
        cube(plate, center=true);
        // logo
        h = min(13, (plate[1] - tube[0])/2);
        y = -plate[1]/2 + h/2;
        if (with_logo && h>7.5) {
            translate([0, y, plate[2]/2])
            if (h>=11.5)
                logo(xyscale=h);
            else
                logo_small(xyscale=h);
        }
        // tube extension
        if (tube[1]>0) {
            translate([0, 0, plate[2]/2]);
            cylinder(h=tube[1], d=tube[0]);
        }
    }
}

$fa = 1;
$fs = .2;

rad_ss = (plate[1] - cage[1])/2 + 1;

difference() {
    body();
    // baffled center bore
    hc = plate[2]+tube[1];
    translate([0, 0, -plate[2]/2])
    neg_cyl_baffled(hc, ID, ID+bore_baffles[0], bore_baffles[1]);
    // cage
    translate([0, 0, -plate[2]/2])
    neg_cage1(cage[0], cage[1], plate[2], cage_setscrew, rad_ss, ss_angle=-1,  ss_nut_type=cage_nuttype, AOI=cage[2], margins=margins, topaccess=true, overbore=2, fast=fastcagepreview&&$preview);
}
