/* 'Post Right Angle Strength'
 * Right angle joing between posts.
 * Both posts are at 45deg to the layer lines,
 * this makes it a lot stronger.
 *
 * Authors:
 * Chris Cannon
 */

use <../hw_pockets.scad>
use <../hw_features.scad>
use <../logo.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

with_logo = true;

// exact post diameter
Post1 = 12.7; //0.01

// exact post diameter
Post2 = 12.7; //0.01

// tolerance of post diameter
Tol = 0.4;

// pitch between posts
Pitch = 16.5; //0.1

// outer diameter of body
Outer = 30; //0.1

// length of body
Length = 46;

// size of screw clamping each post
Clampscrew = "M4";

// type of nut for clampscrew
Typenut = 2; //[2: hex, 3: square]

Capture = true;

Lshaft = 1.4; //0.1

$fa=2;
$fs=.2;

module coord(s) {
    translate([s*Pitch/2, 0, 0])
    rotate([45*s, 0, 0])
    children();
}

plate = (Length-Pitch)/2+.5;

difference() {
    union () {
        // body
        rotate([0, 90, 0])
        rotate(22.5)
        cylinder(h=Length, d=Outer/cos(22.5), center=true, $fn=8);
        // logo
        if (with_logo) {
            xys = min(14, Outer*tan(22.5));
            translate([0, 0, Outer/2])
            if (xys >= 12)
                logo(xyscale=xys);
            else if (xys >= 8)
                logo_small(xyscale=xys);
        }
    }
    for (s=[-1, 1]) {
        bore = (s>0) ? Post1 : Post2;
        rz = (s>0) ? 0 : 180;
        // precision bores for posts
        coord(s)
        linear_extrude(Outer+1, center=true)
        sketch_precision_bore(bore, Tol, rotation=rz);
        // nuts to secure posts
        if (Capture) {
            translate([s*Pitch/2, 0, 0])
            rotate([0, s*90, 0])
            rotate(rz+180)
            neg_hardware(Clampscrew, Typenut, bore/2+Tol+Lshaft, capture=Capture, minor_access=Outer/2+.5, plate=plate, margins=margins);
        } else {
            translate([s*Length/2, 0, 0])
            rotate([0, -s*90, 0])
            neg_hardware(Clampscrew, Typenut, Lshaft, sink=bore/2, plate=plate, margins=margins);
        }
    }
}
