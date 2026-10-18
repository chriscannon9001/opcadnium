/* 'Integrating Sphere'
 * A customizable printable integrating sphere,
 * for scrambling light until spatially uniform.
 * by Chris Cannon
 *
 * Consider matte ultra white paint
 * or
 * barium sulfate mixed in an optically
 * clear binder.
 */

include <../hw.scad>

Render = 2; //[0:bottom, 1:top, 2:whole]

// internal diameter of the sphere
ID = 80;

// thinnest wall portions
wall = 2.5;

// altitude angle at top/bottom seam
alt_seam = 0;

// number of closer screws
N_closers = 3;

// [OD, thick, walloffset, draftangle]
closers = [9.5, 3, 3, 30];

// size of closer screws e.g. "M4" or "I8"
closer_screw = "M3";

// type of nut bottom side of closers
closer_nuttype = 4; //[2: hex, 3: square, 4: tapped]

// make space for washer at closer head
closer_washer = false;

closer_headtype = 0; //[0: SHC, 1: BHC, 5: flathead]

/* [Ports] */
//ID of up to 3 ports (0 for no port)
pID = [25, 8, 0];
// zenith
pzen = [0, 60, 0];
// azimuth
pazi = [0, 90, 180];
// wall thickness at port ID
pwall = [2.5, 2.5, 2.5];
// flange OD around port (sometimes just huge)
pflange = [60, 50, 40];
// OD of counterbore concentric with port (0 for none)
pcounterbore = [0, 0, 0];
// depth of counterbore
pboredepth = [0, 0, 0];
// any ports with protruding wall thickness have a draft
pshoulder_draft = 25;

/* [Baffles] */
// mode of baffles; -1: auto, 0: none, >0: specific radius
bmode = [-1, 0, 0];

// thickness of baffles
bthick = 1.0; //0.1

// thickness of screens which cover over the port (print first layer)
screen = [0, 0, 0]; //[0:0.05:2]

/* [Base Mounting] */
// type of mounting hardware to table
base_hw_type = 0; //[0: tapped, 1: captured-nut, 2: heatset,  3: clamp, 4: none]

// screw size for base attachment
base_screw = "M4";

// additional height (more than wall thickness)
base_addheight = 6.5;

// if using heatset, bore diameter
heatset_bore = 5.25;

// if using heatset or tapped, depth of bore
bore_depth = 7;

// if using clamp, diameter of tube (ID of clamp)
clamp_dia = 12.7;

clamp_screw = "M3";

clamp_Nscrew = 2;

// azimuth angle where clamp is located
clamp_azi = 180;

clamp_wall = 1.6;

// L, W, gap of clamp jaw, mm
Clamp_jaw_dims = [7.1, 7.8, 2.5];

/* [Port Adapter Threads] */

useadapter1 = false;

// [radius-from-center, size, number, theta0]
adapter1screwspec = [20, "M3", 3, 0];

adapter1screwdepth = 3.5;

useadapter2 = false;

// [radius-from-center, size, number, theta0]
adapter2screwspec = [16, "M3", 3, 0];

adapter2screwdepth = 3.5;

useadapter3 = false;

// [radius-from-center, size, number, theta0]
adapter3screwspec = [16, "M3", 3, 0];

adapter3screwdepth = 3.5;

module __Customizer_Limit__ () {}

$fa = $preview? 2.5 : .75;
$fs = $preview? 0.5: 0.15;

dz_seam = sin(alt_seam)*ID/2;
alpha = (Render==2) ? 0.5 : 1.0;
OD = ID + wall*2;
h_draft_closerbore = tan(closers[3]) * (closers[0] + closers[1]) / 2;
Clamp_L_jaw = Clamp_jaw_dims[0];
Clamp_W_jaw = Clamp_jaw_dims[1];
Clamp_gap = Clamp_jaw_dims[2];

function r_lip(i) = sqrt((ID/2)^2 - (pID[i]/2)^2);

module coord_closer(i) {
    translate([0, 0, dz_seam])
    rotate([0, 0, i*360/(N_closers)]) translate([OD/2+closers[2], 0, 0]) children();
}

module coord_port(i) {
    zenith = pzen[i];
    azimuth = pazi[i];
    rotate([0, 0, azimuth]) rotate([0, zenith, 0]) children();
}

module port_negatives(i) {
    // for ID
    cylinder(h=OD*0.6, d=pID[i]);
    // for flange
    translate([0, 0, r_lip(i)+pwall[i]]) cylinder(h=OD*.3,d=pflange[i]);
    if (pcounterbore[i]>0) {
        // for couterbore
        translate([0, 0, r_lip(i)+pwall[i]-pboredepth[i]]) cylinder(h=pboredepth[i]+.1, d=pcounterbore[i]);
    }
}

module port_shoulder(i) {
    d2 = pflange[i];
    d1 = min(OD, d2 + 2 * tan(pshoulder_draft) * (ID/2 + pwall[i]));
    cylinder(h=ID/2+pwall[i], d1=d1, d2=d2);
}

module closer_tabs() {
    // first calc the minor diameter of a n polygon
    if (N_closers>0) {
        major_dia = ID + 2*closers[2] + closers[0];
        theta = 180 / N_closers;
        minor_dia = major_dia * cos(theta);
        // hdraftangle sets the halfheight of a cylinder
        halfheight = tan(closers[3]) * (major_dia - minor_dia)/2 + closers[1];
        // build N closers in a hull with the cylinder
        hull() {
            translate([0, 0, dz_seam-halfheight]) cylinder(h=2*halfheight, d=minor_dia);
            for (i = [0:N_closers-1]) {
                coord_closer(i) translate([0, 0, -closers[1]]) cylinder(h=2*closers[1], d=closers[0]);
            }
        }
    }
}


module closer_negative() {
    Lshaft = closers[1];
    sink = h_draft_closerbore+5;
    // top side
    translate([0, 0, -.05])
    neg_hardware(closer_screw, closer_headtype, Lshaft+.05, sink=sink, washer=closer_washer);
    // bottom side
    rotate([180, 0, 0])
    translate([0, 0, -.05])
    neg_hardware(closer_screw, closer_nuttype, Lshaft+.05, sink=sink, capture=false);
}

function azzen2vec(az, zen) = [sin(zen)*cos(az), sin(zen)*sin(az), cos(zen)];

function vec2az(v) = atan2(v[1], v[0]);

function vec2zen(v) = atan2(norm([v[0], v[1]]), v[2]);

module rotate_to_vector(vec) {
    az = vec2az(vec);
    zen = vec2zen(vec);
    rotate([0, 0, az])
    rotate([0, zen, 0])
    children();
}

// i=0: baffle ports 0,1
// i=1: baffle ports 1,2
// i=2: baffle ports 2,0
module bafflemaker(i) {
    m = bmode[i];
    j = (i>=2) ? 0: i+1;
    // get vectors for ports
    v1 = azzen2vec(pazi[i], pzen[i]);
    v2 = azzen2vec(pazi[j], pzen[j]);
    v_bis = (v1+v2)/2;
    v_plane = cross(v1, v2);
    nb = norm(v_bis);
    np = norm(v_plane);
    if (m == 0) {
        echo("Ignore baffle ", i);
    } else if (abs(nb)<.01) {
        echo("Illegal hemisphere baffle ", i);
    } else if (abs(np)<.01) {
        echo("Illegal baffle coincident ports ", i);
    } else difference() {
        // angle between ports
        a12 = acos(v1 * v2);
        // half-angle width of each port
        a1 = asin(pID[i] / ID);
        a2 = asin(pID[j] / ID);
        // radius at which baffle terminates
        // cos(half-total-angle)*internal-radius
        r = (m>0)? m : ID*cos((a1+a2+a12)/2)/2;
        // simpler formula r=ID*norm((v1+v2))/4;
        // positive baffle
        rotate_to_vector(v2 - v1)
        linear_extrude(bthick, center=true)
        circle(d=ID+.5);
        // negative (trim down)
        rotate_to_vector(v_bis)
        translate([0, 0, r])
        rotate([180, 0, 0])
        cylinder(h=ID/2+r+.5, d=ID+.5);
    }
}

module interior() {
    difference() {
        sphere(d=ID);
        for (i=[0:2]) bafflemaker(i);
    }
}

module portscrew_coord(screwspec) {
    for (i = [1:screwspec[2]]) {
        theta = (i-1) * 360/screwspec[2];
        rotate(theta+screwspec[3])
        translate([screwspec[0], 0, 0])
        children();
    }
}

module port_adapterthreads() {
    if (useadapter1) {
        x_lip = sqrt((ID/2)^2 - (pID[0]/2)^2);
        coord_port(0)
        translate([0, 0, x_lip + pwall[0] - adapter1screwdepth])
        portscrew_coord(adapter1screwspec)
        neg_hardware(adapter1screwspec[1], 4, adapter1screwdepth, sink=.1);
    }
    if (useadapter2) {
        x_lip = sqrt((ID/2)^2 - (pID[1]/2)^2);
        coord_port(1)
        translate([0, 0, x_lip + pwall[1] - adapter2screwdepth])
        portscrew_coord(adapter2screwspec)
        neg_hardware(adapter2screwspec[1], 4, adapter2screwdepth, sink=.1);
    }
    if (useadapter3) {
        x_lip = sqrt((ID/2)^2 - (pID[2]/2)^2);
        coord_port(2)
        translate([0, 0, x_lip + pwall[2] - adapter3screwdepth])
        portscrew_coord(adapter3screwspec)
        neg_hardware(adapter3screwspec[1], 4, adapter3screwdepth, sink=.1);
    }
}

dbot = (base_hw_type>=3) ? 0 : base_addheight;
z_bot = -OD/2 - dbot;
h_bot = OD/4 + dbot;
d1_bot = OD*.55 - dbot * (.45/.25);

color(alpha=alpha) difference() {
    union() {
        // exterior segments
        translate([0, 0, z_bot]) cylinder(h=h_bot, d1=d1_bot, d2=OD);
        translate([0, 0, -OD/4]) cylinder(h=OD/2, d=OD);
        translate([0, 0, OD/4]) cylinder(h=OD/4, d1=OD, d2=OD*.55);
        // closers
        closer_tabs();
        // port shoulders, if any
        for (i = [0:2]) if (pwall[i]>wall) coord_port(i) {
            port_shoulder(i);
        }
        // clamp, if called for
        if ((base_hw_type == 3) && (Render != 1)) {
            rotate(clamp_azi)
            translate([OD/2+clamp_dia/2, 0, -OD/4])
            rotate(-90)
            collar_clamp(clamp_dia, OD/4, clamp_wall, Clamp_L_jaw, Clamp_W_jaw, Clamp_gap, clamp_Nscrew, clamp_screw, 2);
        }
    }
    // interior hollow (sphere)
    interior();
    
    // closer hardware
    if (N_closers>0) for (i = [0:N_closers-1]) coord_closer(i) {
        closer_negative();
    }
    
    // port opening
    for (i = [0:2]) if (pID[i]>0) coord_port(i) {
        port_negatives(i);
    }
    
    // block off top or bottom
    d_TL = OD + closers[2]*2 + closers[0] + 10;
    translate([0, 0, dz_seam])
    if (Render==0) {
        cylinder(h=OD/2+1-dz_seam, d=d_TL);
    } else if (Render==1) {
        rotate([0, 180, 0]) cylinder(h=OD/2+1+dbot+dz_seam, d=d_TL);
    }
    
    // port adapter threads
    port_adapterthreads();
    
    if (base_hw_type == 0) {
        // base attach hw: tapped
        translate([0, 0, z_bot-.1])
        neg_tapped(base_screw, bore_depth+.1);
    } else if (base_hw_type == 1) {
        // base attach hw: captured nut
        spec = hw_getspec(base_screw);
        hex = hw_hex(spec);
        H_hex = hex[1];
        sink = bore_depth - H_hex - 2;
        translate([0, 0, z_bot-.1])
        neg_hex(base_screw, 2, capture=true, minor_access=OD/4, sink=sink);
    } else if (base_hw_type == 2) {
        // base attach hw: heatset
        translate([0, 0, z_bot-.1])
        cylinder(h=bore_depth+.1, d=heatset_bore);
    }
}

// add screens if any
for (i = [0:2]) if (screen[i]>0 && pID[i]>0) {
    coord_port(i)
    translate([0, 0, r_lip(i)+pwall[i]-screen[i]])
    cylinder(h=screen[i], d=pID[i]);
}
