/*
 * hw_pockets
 * Quick pockets to fit nuts, bolts, etc in 3d prints
 * with internal size table lookups.
 *
 * Authors:
 * Chris Cannon
 */

use <./hwlookup.scad>
include <./margins.scad>


// uses a hull to slotify children on x axis
// (need to be careful because hull can change shapes)
module xslotify(width) {
    if (width > 0) {
        hull() for (x=[-width/2,width/2])
            translate([x, 0, 0]) children();
    } else {
        children();
    }
}
// uses a hull to slotify children on y axis
// (need to be careful because hull can change shapes)
module yslotify(width) {
    if (width > 0) {
        hull() for (y=[-width/2,width/2])
            translate([0, y, 0]) children();
    } else {
        children();
    }
}

// Creates a cone (or chamfer) around
// a screw bore. This is needed to widen
// the stance anytime a single screw is
// used to secure opto-mechanics. Such
// as a mirror mount screwed to the end
// of a post.
// chamfer - radial chamfer size, added to bore
// bore - diameter of the screw bore
// Lshaft - length of the shaft bored through the base material, used to set a max chamfer height
module stance_cone(chamfer, bore, Lshaft) {
    if (chamfer > 0) {
        d1 = 2*chamfer + bore;
        h = min(Lshaft - .8, chamfer * .7);
        translate([0, 0, -.05])
        cylinder(h=h+.05, d1=d1, d2=bore);
    }
}

// neg_SHC(); create a pocket
//   designed to counterbore socket-head-cap screws
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below
// sink - (default 0) extrusion of pocket in addition to head height, but if <0 then it overrides extrusion instead of adding on
// plate - (default 0) if plate>Lshaft, pocket extrusion height will be calculated internally so that the Lshaft and extrusion add up to plate
// washer - size up counterbore to include washer (default false)
// slot - x width to add slot (default 0)
// margins - see above;
//      loose around sides, gap over top
//      close around sides of shaft
module neg_SHC(size, Lshaft, sink=0, plate=0, washer=false, slot=0, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    shc = hw_shc(spec);
    w = hw_washer(spec);
    bore = (washer ? max(w[0], shc[0]) : shc[0]) + 2*margins[2];
    thick0 = shc[1] + margins[3] + sink + (washer ? w[1] : 0);
    thick = (plate>Lshaft) ? plate-Lshaft : ((sink<0) ? -sink : thick0);
    //echo(shc, thick);
    union() {
    // head
    xslotify(slot)
    translate([0, 0, Lshaft]) linear_extrude(thick+.1) circle(d=bore);
    // shaft
    xslotify(slot)
    linear_extrude(Lshaft+.12) circle(d=shaft);
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
    }
}

// vit_SHC(): create a vitamin
//   appears roughly like a socket-head-cap screw
//   origin is centered same as neg_SHC
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// washer - include washer (default false)
// TLshaft - total shaft length including Lshaft
module vit_SHC(size, Lshaft, washer=false, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    shc = hw_shc(spec);
    w = hw_washer(spec);
    cylinder(h=Lshaft, d=shaft);
    if (washer) {
        translate([0, 0, Lshaft]) cylinder(h=w[1], d=w[0]);
    }
    translate([0, 0, Lshaft+(washer ? w[1] : 0)])
    cylinder(h=shc[1], d=shc[0]);
    dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}

// neg_BHC(); create a pocket
//   designed to counterbore button-head-cap screws
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below
// sink - (default 0) extrusion of pocket in addition to head height, but if <0 then it overrides extrusion instead of adding on
// plate - (default 0) if plate>Lshaft, pocket extrusion height will be calculated internally so that the Lshaft and extrusion add up to plate
// washer - size to include washer (default false)
// slot - x width to add slot (default 0)
// margins - see above;
//      loose around sides, gap over top
//      close around sides of shaft
module neg_BHC(size, Lshaft, sink=0, plate=0, washer=false, slot=0, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    bhc = hw_bhc(spec);
    w = hw_washer(spec);
    bore = (washer ? max(w[0], bhc[0]) : bhc[0]) + + 2*margins[2];
    thick0 = bhc[1] + margins[3] + sink + (washer ? w[1] : 0);
    thick = (plate>Lshaft) ? plate-Lshaft : ((sink<0) ? -sink : thick0);
    //echo(shc, thick);
    union() {
    // head
    xslotify(slot)
    translate([0, 0, Lshaft]) linear_extrude(thick+.1) circle(d=bore);
    // shaft
    xslotify(slot)
    linear_extrude(Lshaft+.12) circle(d=shaft);
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
    }
}

// vit_BHC(): create a vitamin
//   appears roughly like a button-head-cap screw
//   origin is centered same as neg_BHC
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// washer - include washer (default false)
// TLshaft - total shaft length including Lshaft
module vit_BHC(size, Lshaft, washer=false, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    bhc = hw_bhc(spec);
    w = hw_washer(spec);
    cylinder(h=Lshaft, d=shaft);
    if (washer) {
        translate([0, 0, Lshaft]) cylinder(h=w[1], d=w[0]);
    }
    translate([0, 0, Lshaft+(washer ? w[1] : 0)])
    cylinder(h=bhc[1], d=bhc[0]);
        dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}

// neg_flathead(); create a pocket
//   designed to countersink flat-head screws
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below
// sink - extrusion over top of head (default 0)
// slot - x width to add slot (default 0)
// margins - see above;
//      loose around sides, gap over top
//      close around sides of shaft
module neg_flathead(size, Lshaft, sink=0, plate=0, slot=0, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    head = hw_flathead(spec) + 2*margins[2];
    thick = (head - shaft) / 2;
    sink = (plate>0) ? (plate-Lshaft) : abs(sink);
    //echo(shc, thick);
    union() {
    // head
    xslotify(slot)
    translate([0, 0, Lshaft-thick]) cylinder(h=thick+.01, d1=shaft, d2=head);
    if (sink>0) {
        xslotify(slot)
        translate([0, 0, Lshaft]) linear_extrude(sink) circle(d=head);
    }
    // shaft
    xslotify(slot)
    linear_extrude(Lshaft+.12) circle(d=shaft);
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
    }
}

// vit_flathead(): create a vitamin
//   appears roughly like a flathead screw
//   origin is centered same as neg_flathead
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// TLshaft - total shaft length including Lshaft
module vit_flathead(size, Lshaft, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    head = hw_flathead(spec);
    thick = (head - shaft) / 2;
    cylinder(h=Lshaft, d=shaft);
    translate([0, 0, Lshaft-thick])
    cylinder(h=thick, d1=shaft, d2=head);
    dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}

// neg_tapped(); create a pocket
//   designed for a tapped or self-tapped screw
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft
// rel_thread - relative reduction of shaft (default 0.15)
module neg_tapped(size, Lshaft, stancecone=0, rel_thread=0.15) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) * (1 - rel_thread);
    cylinder(h=Lshaft, d=shaft);
    // stance cone
    stance_cone(stancecone, shaft, Lshaft);
}

// vit_tapped(): create a vitamin
//   appears like a screw shaft, that's all
//   origin is centered same as neg_tapped
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// TLshaft - total shaft length including Lshaft
module vit_tapped(size, Lshaft, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    cylinder(h=Lshaft, d=shaft);
    dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}

module access_slot(length, w1, angle, height) {
    w2 = w1 + 2*length*tan(angle/2);
    linear_extrude(height)
    polygon([[0, -w1/2], [0, w1/2], [length, w2/2], [length, -w2/2]]);
}

// neg_hex(); create a pocket
//   designed for nuts, also works on hex head
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below
// sink - extrusion of hex in addition to thick (default 0), but if <0 then it overrides thick instead of adding on
// plate - (default 0) if plate>Lshaft, pocket extrusion height will be calculated internally so that the Lshaft and extrusion add up to plate
// capture - extrude above not the hex but only the shaft so that a nut can be captured by interrupting the print (default 0)
// slot - x width to add slotting (default 0)
// minor_access - (default 0) length of access slot (aligned to minor dimension of the hex) usually so that nut can be installed after print for capture (normally combined with capture=true)
// major_access - (default 0) length of access slot, like minor access but aligned to major dimension of the hex
// access_draft - (default 12) full angle in degrees that access slot expands
// margins - see above;
//      snug around sides of hex, loose over top
//      close around sides of shaft
module neg_hex(size, Lshaft, sink=0, plate=0, capture=false, slot=0, minor_access=0, major_access=0, access_draft=12, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    hex = hw_hex(spec);
    hex_minor = hex[0] + 2*margins[0];
    hexOD = hex_minor/cos(30);
    sink0 = (plate>Lshaft) ? Lshaft-plate : sink;
    // thick0 is based on the hw table
    thick0 = hex[1] + margins[2];
    // dthick is the height difference between thick0 and sink
    dthick = (sink0<0) ? -sink0-thick0 : sink0;
    // Tshaft is 0 if there is no top shaft
    Tshaft = (capture) ? max(0, dthick): 0;
    thickener = (Tshaft) ? 0 : dthick;
    // thick is the thickness of the extrude for the nut
    thick = thick0 + thickener;
    union() {
    // hex
    xslotify(slot)
    translate([0, 0, Lshaft]) linear_extrude(thick) circle(d=hexOD, $fn=6);
    // access slot
    if (minor_access>0) {
        translate([hexOD*.5*sin(30), 0, Lshaft])
        access_slot(minor_access, hex_minor, access_draft, thick);
    } else if (major_access>0) {
        translate([0, 0, Lshaft]) rotate([0, 0, 90])
        access_slot(major_access, hexOD, access_draft, thick);
    }
    // bottom shaft
    xslotify(slot)
    linear_extrude(Lshaft+.12) circle(d=shaft);
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
    // top shaft
    xslotify(slot)
    if (Tshaft>0) {
        translate([0, 0, Lshaft+thick-.1]) linear_extrude(Tshaft+.1) circle(d=shaft);
    }
    }
}

// vit_hex(): create a vitamin
//   appears roughly like a nut or hex-head-screw
//   origin is centered same as neg_hex
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// TLshaft - total shaft length including Lshaft
module vit_hex(size, Lshaft, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    hex = hw_hex(spec);
    hex_minor = hex[0];
    hexOD = hex_minor/cos(30);
    cylinder(h=Lshaft, d=shaft);
    translate([0, 0, Lshaft]) linear_extrude(hex[1]) circle(d=hexOD, $fn=6);
    dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}

// neg_square(); create a pocket
//   designed for square nuts, (might) also work on a square head screw
//   origin is centered at bottom of shaft
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below
// sink - extrusion of hex in addition to thick (default 0), but if <0 then it overrides thick instead of adding on
// capture - extrude above not the hex but only the shaft so that a nut can be captured by interrupting the print (default 0)
// xx Tshaft - length of shaft above (default 0)
// slot - x width to add slotting (default 0)
// margins - see above;
//      snug around sides of hex, loose over top
//      close around sides of shaft
module neg_square(size, Lshaft, sink=0, plate=0, capture=false, slot=0, minor_access=0, major_access=0, access_draft=12, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    squ = hw_squ(spec);
    d = squ[0] + 2*margins[0];
    sink0 = (plate>Lshaft) ? Lshaft-plate : sink;
    // thick0 is based on the hw table
    thick0 = squ[1] + margins[2];
    // dthick is the height difference between thick0 and sink
    dthick = (sink0<0) ? -sink0-thick0 : sink0;
    // Tshaft is 0 if there is no top shaft
    Tshaft = (capture) ? max(0, dthick): 0;
    thickener = (Tshaft) ? 0 : dthick;
    // thick is the thickness of the extrude for the nut
    thick = thick0 + thickener;
    union() {
    // square
    xslotify(slot)
    translate([0, 0, Lshaft]) linear_extrude(thick) square(d, center=true);
    // access slot
    if (minor_access>0) {
        translate([d*.5-.01, 0, Lshaft])
        access_slot(minor_access, d, access_draft, thick);
    } else if (major_access>0) {
        echo("No major_access");
    }
    // bottom shaft
    xslotify(slot)
    linear_extrude(Lshaft+.12) circle(d=shaft);
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
    // top shaft
    xslotify(slot)
    if (Tshaft>0) {
        translate([0, 0, Lshaft+thick-.1]) linear_extrude(Tshaft+.1) circle(d=shaft);
    }
    }
}

// vit_square(): create a vitamin
//   appears roughly like a square nut and screw shaft
//   origin is centered same as neg_flathead
// size - e.g. "M3", "I4" or "I1/4"
// Lshaft - length of shaft below origin to head
// TLshaft - total shaft length including Lshaft
module vit_square(size, Lshaft, capture=false, TLshaft=0) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec);
    squ = hw_squ(spec);
    d = squ[0];
    cylinder(h=Lshaft, d=shaft);
    translate([0, 0, Lshaft]) linear_extrude(squ[1]) square(d, center=true);
    dH = TLshaft - Lshaft;
    if (dH > 0) {
        translate([0, 0, -dH]) cylinder(h=TLshaft, d=shaft);
    }
}



module neg_custom(size, Lshaft, bore, sink=0, slot=0, stancecone=0, margins=def_margins) {
    spec = hw_getspec(size);
    shaft = hw_shaft(spec) + 2*margins[1];
    xslotify(slot)
    linear_extrude(Lshaft+.01) circle(d=shaft);
    if (sink>0) {
        xslotify(slot)
        translate([0, 0, Lshaft]) linear_extrude(sink) circle(d=bore);
    }
    // stance cone
    xslotify(slot)
    stance_cone(stancecone, shaft, Lshaft);
}


//
// type - 0: SHC, 1: BHC, 2: hex, 3: square, 4: tapped, 5: flathead, 6: custom
module neg_hardware(size, type, Lshaft, sink=0, plate=0, slot=0, minor_access=0, major_access=0, capture=false, access_draft=12, washer=false, rel_thread=0.15, stancecone=0, margins=def_margins) {
    if (type == 0) {
        neg_SHC(size, Lshaft, sink=sink, plate=plate, washer=washer, slot=slot, stancecone=stancecone, margins=margins);
    } else if (type == 1) {
        neg_BHC(size, Lshaft, sink=sink, plate=plate, washer=washer, slot=slot, stancecone=stancecone, margins=margins);
    } else if (type == 2) {
        neg_hex(size, Lshaft, sink=sink, plate=plate, capture=capture, slot=slot, minor_access=minor_access, major_access=major_access, access_draft=access_draft, stancecone=stancecone, margins=margins);
    } else if (type == 3) {
        neg_square(size, Lshaft, sink=sink,plate=plate, capture=capture, slot=slot, minor_access=minor_access, major_access=major_access, access_draft=access_draft, stancecone=stancecone, margins=margins);
    } else if (type == 4) {
        neg_tapped(size, Lshaft+abs(sink), rel_thread=rel_thread, stancecone=stancecone);
    } else if (type == 5) {
        neg_flathead(size, Lshaft, sink=sink, plate=plate, slot=slot, stancecone=stancecone, margins=margins);
    } else if (type == 6) {
        neg_custom(size, Lshaft, minor_access, sink=sink, slot=slot, stancecone=stancecone);
    } else {
    }
}

module vit_hardware(size, type, Lshaft, washer=false, TLshaft=0) {
    if (type == 0) {
        vit_SHC(size, Lshaft, washer=washer, TLshaft=TLshaft);
    } else if (type == 1) {
        vit_BHC(size, Lshaft, washer=washer, TLshaft=TLshaft);
    } else if (type == 2) {
        vit_hex(size, Lshaft, TLshaft=TLshaft);
    } else if (type == 3) {
        vit_square(size, Lshaft, TLshaft=TLshaft);
    } else if (type == 4) {
        vit_tapped(size, Lshaft, TLshaft=TLshaft);
    } else if (type == 5) {
        vit_flathead(size, Lshaft, TLshaft=TLshaft);
    } else if (type == 6) {
    } else {
    }
}
