// disruptor genie adapters
use <utils.scad>;
use <screws.scad>;

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres

// sizes
$ca_height = 24;
$ca_base_diameter = 137; // 69;
$ca_upper_diameter = 51;
$ca_max_diameter = 85; // how thick it can be and still fit
$ca_axle_diameter = 8;
$ca_upper_rim = 2; // thickness of rim at top
$ca_upper_cutout_depth = 8; // how deep to cut out at the top
$ca_vial_diameter = 11.7 + 0.5; // with tolerance
$ca_extra_angle = 0; // how much to rotate paste the natural inclide
$ca_vial_depth = 20;
$ca_vial_pos_r = 20;
$ca_vial_pos_z = 16;
$ca_n_vials = 6;

// module for microcentrifuge adapater
module centrifuge_adapter() {

  full_height = $ca_height * ( 1 + $ca_upper_diameter/$ca_base_diameter);
  angle = 90 - atan(full_height / ($ca_base_diameter/2)) - $ca_extra_angle;


  difference() {
    cylinder(d1 = $ca_base_diameter, d2 = $ca_upper_diameter, h = $ca_height);
    // axle
    translate([0, 0, -$e])
      cylinder(d = $ca_axle_diameter, h = $ca_height + $2e, $fn = 6);

    // vials
    for (i = [1:1:$ca_n_vials])
      translate([-$ca_vial_pos_r * cos((i-1) * 360/$ca_n_vials), -$ca_vial_pos_r * sin((i-1) * 360/$ca_n_vials), $ca_vial_pos_z])
        rotate([0, angle, (i-1) * 360/$ca_n_vials])
        translate([0, 0, -$ca_vial_depth])
          cylinder(d = $ca_vial_diameter, h = 2 * $ca_vial_depth);

    // outer bound
    translate([0, 0, -$e])
    difference() {
      cylinder(d = $ca_base_diameter, h = $ca_height + $2e);
      cylinder(d = $ca_max_diameter, h = $ca_height + $2e);
    }

    // top bound
    translate([0, 0, $ca_height + $e])
      rotate([180, 0, 0])
        cylinder(d = $ca_upper_diameter - 2 * $ca_upper_rim, h = $ca_upper_cutout_depth + $e);

  }



}

centrifuge_adapter();
