use <utils.scad>;

// make headplate holder
// @param holder_height the height of the holder
// @param rim_height the height of the rim on top of the holder
module headplate_holder(holder_height = 120, rim_height = 10) {

  // general settings
  z_plus = 0.1; // how much thicker to make cutouts in z

  // holder
  holder_d = 192; // holder diameter (190 is actual headplate)
  holder_thickness = 15; // holder chickness
  base_h = 12; // base height

  // holder rim
  rim_thickness = 7.5; // thickness of the rim
  rim_cutout_tolerance = 1; // extra thickness on cutout to ensure stackability

  // side cutout
  cutout_x = 85; // x location of cutouts
  cutout_w = 85; // width of the cutout
  cutout_w_d_scale = 1; // how much the angled support of the pillars are squashed

  difference() {

    union() {
      // cylinder itself
      cylinder(h=holder_height, d=holder_d, $fn = 120);

      // rims
      difference() {
        cylinder(h=holder_height+rim_height, d=holder_d+2*rim_thickness, $fn = 120);
        // side cut outs
        for (r = [0:5])
          rotate(36+r*72)
            translate([cutout_x, 0, -z_plus])
              xy_center_cube([holder_d, cutout_w, holder_height+rim_height+2*z_plus]);
        // top cutout
        translate([0, 0, holder_height])
          cylinder(h=rim_height+z_plus, d=holder_d+rim_cutout_tolerance, $fn=120);
      }
    }

    // center hole cutout
    translate([0, 0, -z_plus])
      cylinder(h=holder_height+2*z_plus, d=holder_d - 2*holder_thickness, $fn=120);


    // side walls cutout
    for (r = [0:5])
      rotate(36+r*72)
        translate([cutout_x, 0, base_h+cutout_w_d_scale*cutout_w/2])
          union() {
            xy_center_cube([holder_d, cutout_w, holder_height]);
            translate([-holder_d/2, 0, 0])
              rotate([0,90,0])
                scale([cutout_w_d_scale, 1.0, 1.0])
                  cylinder(d=cutout_w, h=holder_d);
          }
  }


}



headplate_holder();
