/* Calibration Check
 * for screw & nut fit.
 *
 * Check that margins are working.
 */

use <../hw_pockets.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

sizes = ["M2", "M2.5", "M3"];

headtype = 0; //[0: SHC, 1: BHC, 5: Flat]

nuttype = 2; //[2: hex, 3: square]

block = [25, 25, 7];

Lshaft = 2.5;

pitch = 7.5;

font = 2.5;

// either emboss or engrave sizes text
emboss = false;

module _endcust_() {}

$fa=1;
$fs=.1;

difference() {
    union() {
        // block
        linear_extrude(block[2])
        square([block[0], block[1]], center=true); 
        // emboss
        if (emboss) for (j=[0:2]) {
            x0 = (j-1) * pitch;
            translate([x0, 0, block[2]])
            linear_extrude(.4)
            text(sizes[j], size=font, halign="center", valign="center");
        }
    }
    // size checks
    for (i=[0:2]) {
        //echo(i, sizes[i]);
        x = (i-1) * pitch;
        dy = .5 * (pitch + font) + 1;
        // screw head
        translate([x, dy, -.01])
        neg_hardware(sizes[i], headtype, Lshaft, sink=block[1], margins=margins);
        // nut
        translate([x, -dy, -.01])
        neg_hardware(sizes[i], nuttype, Lshaft, sink=block[1], margins=margins);
        // engrave text
        if (!emboss)
        translate([x, 0, block[2]-.4])
        linear_extrude(1)
        text(sizes[i], size=font, halign="center", valign="center");
    }
}
