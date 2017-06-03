use <utils.scad>;
use <screws.scad>;

// holder for mounting nema 17
// @param size total size
module nema17_holder(size) {
  // parameters
  z_plus = 0.1; // how much thicker to make cutouts in z
  nema17_size = [43, 43, size[2]];
  screws = ["M3", 15.5, 15.5, 0.25];
  gap = nema17_size[0]/2 - screws[1]; // this cal only works with square profile

  // assemble
  difference() {
    xy_center_cube(size);

    // screw holes
    for(x=[-1, 1])
      for(y=[-1, 1])
        translate([x*screws[1], y*screws[2], 0])
          machine_screw(screws[0], size[2], tolerance = screws[3], z_plus = z_plus);

    // nema cut out
    translate([0, 0, -z_plus])
      resize([0, 0, nema17_size[2] + 2*z_plus])
        difference() {
          xy_center_cube(nema17_size);
          for(x=[-1, 1])
            for(y=[-1, 1]) {
              translate([x*screws[1], y*screws[2], -z_plus])
                cylinder(size[2]+2*z_plus, d=6, center=false, $fn = 30);
              translate([x*screws[1] + x*gap/2, y*screws[2] + y*gap/2, -z_plus])
                xy_center_cube([gap, 2*gap, size[2]+2*z_plus]);
              translate([x*screws[1] + x*gap/2, y*screws[2] + y*gap/2, -z_plus])
                xy_center_cube([2*gap, gap, size[2]+2*z_plus]);
            }
        }
  }
}



color("green") nema17_holder([50, 50, 5]);
translate([0, 0, -30]) nema17_holder([60, 80, 10]);
