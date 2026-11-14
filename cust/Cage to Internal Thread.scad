include <../hw.scad>

// [snug, close, loose, gap]
margins = [.06, .12, .24, .35];

// exact OD of extrusion into camera thread
thread = 41.6; //0.1

// height of extrusion
H_thread = 7.5; //0.1

// clear aperture top to bottom
ID_clear = 24;

with_baffles = true;

// internal baffles: [radial, pitch]
baffles = [0.9, 3]; //0.1

// [rod, oncenter, AOI]
cage = [6.35, 30, 0];

// plate supporting cage mount
plate = [46, 54, 12];

cage_ss = "M3";

cage_nut = 2; //[2: hex, 3:square, 4: tapped]

module body() {
    H_plate = plate[2];
    rad_ss = (plate[1] - cage[1] - cage[0]) / 2 + 0.5;
    difference() {
        union() {
            cube(plate, center=true);
            translate([0, 0, H_plate/2])
            cylinder(h=H_thread, d=thread);
        }
        // ID
        translate([0, 0, -H_plate/2-.01])
        if (with_baffles) {
            neg_cyl_baffled(H_plate+H_thread, ID_clear, ID_clear+2*baffles[0], baffles[1]);
        } else {
            cylinder(h=H_plate+H_thread+.02, d=ID_clear);
        }
        // cage
        translate([0, 0, -H_plate/2])
        neg_cage1(cage[0], cage[1], H_plate, cage_ss, rad_ss, ss_nut_type=cage_nut, ss_angle=-1, AOI=cage[2], margins=margins);
    }
}

$fa=1;
$fs=.2;
body();
