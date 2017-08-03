use <utils.scad>;

// make headplate holder
// @param height the height of the holder
// @param stubs the height of the stubs (on top of the holder)
module headplate_holder(height = 110, stubs = 15) {

  holder_d = 195; // holder diameter (190 is actual headplate)
  hole_d = 150; // hole diameter (143 is actual to sealing ring)
  base_h = 15; // base height
  z_plus = 0.1; // how much thicker to make cutouts in z
  stub_r = 85; // location of the stubs
  stub_d = 6.5; // diameter of the stubs
  stub_tolerance = 0.3; // tolerance on the stub holes
  cutout_w = 75; // width of the cutout
  cutout_d = holder_d - hole_d; // depth of the cutout
  cutout_w_d_scale = 1; // how much the angled support of the pillars are squashed

  difference() {

    union() {
      // cylinder itself
      cylinder(h=height, d=holder_d, $fn = 120);
      // make adapters
      for (r = [0:5])
        rotate(r*60)
          translate([stub_r, 0, 0])
            cylinder(h=height+stubs, d=stub_d, $fn=30);
    }

    translate([0, 0, -z_plus]) {
      // central hole cut
      cylinder(h=height+2*z_plus, d=hole_d, $fn=120);
      // adapter holes for stacking
      for (r = [0:5])
        rotate(30+r*60)
          translate([stub_r, 0, 0])
            cylinder(h=height+2*z_plus, d=stub_d+stub_tolerance, $fn=30);
    }

    // side walls cutout
    for (r = [0:5]) color("green")
      rotate(30+r*60)
        translate([stub_r, 0, base_h+cutout_w_d_scale*cutout_w/2])
          union() {
            xy_center_cube([cutout_d, cutout_w, height]);
            translate([-cutout_d/2, 0, 0])
              rotate([0,90,0])
                scale([cutout_w_d_scale, 1.0, 1.0])
                  cylinder(d=cutout_w, h=cutout_d);
          }
  }


}



headplate_holder();
