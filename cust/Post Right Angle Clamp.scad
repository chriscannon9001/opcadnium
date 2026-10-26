/* 'Post Right Angle Clamp'
 * Customizable printable right angle for posts.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_features.scad>
use <../logo.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

with_logo = true;

// exact post diameter
Post1 = 12.7; //0.01

// exact post diameter
Post2 = 12.7; //0.01

Pitch = 14; //0.1

Outer = 18; //0.1

Gap = 1;

Clampscrew = "M3";

Length = 40;

Typehead = 0;

Typenut = 2;

Washer = true;

module coord1() {
    translate([Pitch/2, 0, -Outer/2-.05])
    children();
}

module coord2() {
    translate([-Pitch/2, Outer/2+.05])
    rotate([90, 0, 0])
    rotate(180)
    children();
}

margin1 = (Length - Pitch - Post1)/2;
margin2 = (Length - Pitch - Post2)/2;

rad_ss1 = (Post1 + margin1)/2;
rad_ss2 = (Post2 + margin2)/2;

OD1 = Post1 + 2*margin1;
OD2 = Post2 + 2*margin2;

$fa=2;
$fs=.2;

difference() {
    cube([Length, Outer, Outer], center=true);
    coord1() cylinder(h=Outer+.1, d=Post1);
    coord1() neg_collar_screwnut(Outer+.1, OD1, Gap, Clampscrew, rad_ss1, Lshaft=5, typehead=Typehead, typenut=Typenut, access=false, washer=Washer, margins=margins);
    coord2() cylinder(h=Outer+.1, d=Post2);
    coord2() neg_collar_screwnut(Outer+.1, OD2, Gap, Clampscrew, rad_ss2, Lshaft=5, typehead=Typehead, typenut=Typenut, access=false, washer=Washer, margins=margins);
    // logo
    if (with_logo) {
        translate([Pitch/2-0.5, -Outer/2-.05, 0])
        rotate([90, 0, 0])
        logo(xyscale=12, h=-.34);
    }
}
