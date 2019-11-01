use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

module voa_vial_holder(tube_diameter = 3) {

  block_size = [40, 40, 10];
  base_thickness = 5;

  tube_distance = [10, 10];

  difference() {
    xy_center_cube(block_size);
    for (y = [-1, 0, 1]) {
      for (x = [-2, -1, 0, 1, 2]) {
        translate([x * tube_distance[0], y * tube_distance[1], 5])
          cylinder(d = tube_diameter, h = block_size[2] + e);
      }
    }
  }

}

voa_vial_holder();
color("red") translate([50, 0, 0]) voa_vial_holder(tube_diameter = 8);
