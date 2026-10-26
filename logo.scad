// Full opcadnium logo
// xyscale - lateral dimension
// h - height, positive for emboss, negative for engrave
module logo(xyscale=12, h=0.4,
    font="DejaVu Sans:Bold") {
    dz = (h>0) ? 0 : h;
    ah = abs(h);
    w1 = (h>0) ? xyscale : xyscale-2*ah;
    s = ((xyscale-h*2)/xyscale);
    translate([0, 0, dz]) difference() {
        linear_extrude(ah, scale=s)
        square(w1, center=true);
        linear_extrude(ah+.05) {
            text("Op", size=0.3*xyscale, halign="center", valign="center", font=font);
            translate([0, -.32*xyscale])
            text("CAD", size=0.16*xyscale, halign="center", valign="center", font=font);
        }
    }
}

// Partial opcadnium logo
// xyscale - lateral dimension
// h - height, positive for emboss, negative for engrave
module logo_small(xyscale=12, h=0.4,
    font="DejaVu Sans:Bold") {
    dz = (h>0) ? 0 : h;
    ah = abs(h);
    w1 = (h>0) ? xyscale : xyscale-2*ah;
    s = ((xyscale-h*2)/xyscale);
    translate([0, 0, dz]) difference() {
        linear_extrude(ah, scale=s)
        square(w1, center=true);
        linear_extrude(ah+.05)
        text("Op", size=0.38*xyscale, halign="center", valign="center", font=font);
    }
}

logo(xyscale=14, h=.4);

translate([0, 0, 10])
logo_small(xyscale=8);
