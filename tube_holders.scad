/*
 * Tube holders for rigid tubing (e.g. stainless steel, brass, etc.)
 */

use <utils.scad>;
use <screws.scad>;

// standard tube holders
// @param thickness holder thichness in mm
// @param screw which screw holes to add
// @param screw_spacing how far apart should the screws be placed?
// @param tube_size_inch tube size in inches
module tube_holder(thickness = 10, screw = "M5", screw_spacing = 20, tube_size_inch = 1/4, tube_size_tolerance = 0.2, with_hexnuts = false) {

  tube_size = 25.4 * tube_size_inch;
  z_plus = 0.1; // how much thicker to make cutouts in z
  holder = [35, 20, thickness];

  difference() {
    tube_holder_spacer(thickness = thickness, screw = screw, screw_spacing = screw_spacing);
    // add hex nut holes
    if (with_hexnuts)
      for(x=[-1, 1])
        translate([x * screw_spacing/2, 0, holder[2] - get_hexnut(screw)[2]])
          hexnut(screw, z_plus = z_plus, screw_hole = false);
    // add tub cutout
    rotate([90,0,0])
      translate([0, 0, -(holder[1]+2*z_plus)/2])
        cylinder(h = holder[1]+2*z_plus, d = tube_size + tube_size_tolerance, $fn = 30);
  }

}

module tube_holder_spacer(thickness = 5, screw = "M5", screw_spacing = 20) {
  z_plus = 0.1; // how much thicker to make cutouts in z
  spacer = [35, 20, thickness];
  difference() {
    xy_center_cube(spacer);
    // add screw holes
    for(x=[-1, 1]) {
      translate([x * screw_spacing/2, 0, 0])
        machine_screw(screw, length = spacer[2], z_plus = z_plus, countersink = false);
    }
  }
}

// note: hexnut version does not screw super tight because the nut does not catch on a larger area
// better to use without hexnut and just use washers
color("green")
tube_holder(tube_size_inch = 1/4, with_hexnuts = true);

// standard tube holder
color("yellow")
translate([0, 0, -5])
rotate([0, 180, 0])
tube_holder(10, tube_size_inch = 1/4);

// difference spacers
color("red")
translate([0, 0, -20])
tube_holder_spacer(2.5);

color("red")
translate([0, 0, -30])
tube_holder_spacer(5);

!color("red")
translate([0, 0, -45])
tube_holder_spacer(10);
