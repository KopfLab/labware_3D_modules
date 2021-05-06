use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

// details
base = [125.80, 87.30, 2.0];
inlay = [121, 83, 4.0]; // rounded up for tighter fit
tabs = [4.0, 30.0, 2.0];
edge_d = 22.0; // edge rounding diameter
holes_d = 9.0;
cols = 10;
rows = 6;

// holder for 1mL pipette tips
difference() {
  union() {
    // top
    xy_center_cube([base[0] - edge_d, base[1], base[2]]);
    xy_center_cube([base[0], base[1] - edge_d, base[2]]);
    for (x = [-1, 1]) {
      for (y = [-1, 1])
        translate([x * (base[0]/2 - edge_d/2), y * (base[1]/2 - edge_d/2), 0])
          cylinder(d = edge_d, h = base[2]);
    }
    // inlay
    xy_center_cube([inlay[0] - edge_d, inlay[1], inlay[2]]);
    xy_center_cube([inlay[0], inlay[1] - edge_d, inlay[2]]);
    for (x = [-1, 1]) {
      for (y = [-1, 1])
        translate([x * (inlay[0]/2 - edge_d/2), y * (inlay[1]/2 - edge_d/2), 0])
          cylinder(d = edge_d, h = inlay[2]);
    }
    // tabs
    for (x = [-1, 1]) {
      translate([x * (base[0] + tabs[0])/2, 0, 0])
        xy_center_cube(tabs);
    }
  }
  // holes
  x_space = inlay[0]/(cols + 1);
  y_space = inlay[1]/(rows + 1);
  for (x = [1 : 1 : cols]) {
    for (y = [1 : 1 : rows]) {
      translate([-inlay[0]/2 + x * x_space, -inlay[1]/2 + y * y_space, -e])
        cylinder(d = holes_d, h = inlay[2] + 2e);
    }
  }
}
