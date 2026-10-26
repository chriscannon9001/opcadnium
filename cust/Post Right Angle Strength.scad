/* 'Post Right Angle Strength'
 * Right angle joing between posts.
 * Both posts are at 45deg to the layer lines.
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

Tol = 0.4;

Pitch = 16.5; //0.1

Outer = 24; //0.1

Gap = 1;

Clampscrew = "M4";

Length = 46;

Typenut = 2; //[2: hex, 3: square

Capture = true;

Lshaft = 1.4; //0.1

$fa=2;
$fs=.2;

module coord(s) {
    translate([s*Pitch/2, 0, 0])
    rotate([60*s, 0, 0])
    children();
}

plate = (Length-Pitch)/2+.5;

difference() {
    union () {
        // body
        rotate([0, 90, 0])
        rotate(30)
        cylinder(h=Length, d=Outer/cos(30), center=true, $fn=6);
        // logo
        if (with_logo) {
            xys = min(14, Outer*tan(30));
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
            neg_hex(Clampscrew, bore/2+Tol+Lshaft, capture=Capture, minor_access=Outer/2+.5, plate=plate);
        } else {
            translate([s*Length/2, 0, 0])
            rotate([0, -s*90, 0])
            neg_hex(Clampscrew, Lshaft, sink=bore/2, plate=plate);
        }
    }
}
