// disruptor genie adapters
use <utils.scad>;
use <screws.scad>;

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres

// common sizes
$ga_base_thickness = 1.0; // thickness of the base
$ga_vial_diameter = 11.7 + 0.8; // with tolerance
$ga_vial_distance = 0.5 * (75+53)/2; // distance from center
$ga_vial_wall = 2; // thickness of the vial wall
$ga_outer_diameter = 2 *($ga_vial_distance + $ga_vial_diameter/2 + $ga_vial_wall);
$ga_inner_diameter = 2 *($ga_vial_distance - $ga_vial_diameter/2 - $ga_vial_wall);
$ga_cut_to_vial = 4; // thickness of cut to vial holder (for better printing)
$ga_vial_height = 4.0; // height of the vial holder hole
$ga_n_vials = 12; // how many vials in a circle
$ga_screw_diameter = 7.0; // hole for attachment screws

// generate genie adapater
// @param cut_in_half whether to print only half of the adapter (for easier assembly)
module genie_adapter(cut_in_half = true) {

  difference(){
    union() {
      // outer ring
      cylinder(d = $ga_outer_diameter, h = $ga_base_thickness);
      // inner ring
      translate([0, 0, $ga_base_thickness])
        cylinder(d = $ga_inner_diameter + 2 * $ga_vial_wall, h = $ga_vial_height);
      // vial holds
      for (i = [1:1:$ga_n_vials]) {
        translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), $ga_base_thickness])
          cylinder(d = $ga_vial_diameter + 2 * $ga_vial_wall, h = $ga_vial_height);
      }
    }
    // inner ring cutout
    translate([0, 0, -$e])
      cylinder(d = $ga_inner_diameter, h = $ga_base_thickness + $ga_vial_height + $2e);
    // vial holds cutouts
    for (i = [1:1:$ga_n_vials]) {
      translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), -$e])
        cylinder(d = $ga_screw_diameter, h = $ga_base_thickness + $2e);
      translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), $ga_base_thickness])
        cylinder(d = $ga_vial_diameter, h = $ga_vial_height + $e);
      translate([$ga_inner_diameter/2 * cos((i-1) * 360/$ga_n_vials), $ga_inner_diameter/2 * sin((i-1) * 360/$ga_n_vials), $ga_vial_height/2 + $e + $ga_base_thickness])
        rotate([0, 0, (i-1) * 360/$ga_n_vials])
          cube([4 * $ga_vial_wall, $ga_cut_to_vial, $ga_vial_height + $2e], center = true);
    }
    // only half?
    if (cut_in_half) {
      translate([0, $ga_outer_diameter/2 + $e, ($ga_base_thickness + $ga_vial_height)/2])
          cube([2 * $ga_outer_diameter, $ga_outer_diameter + $2e, $ga_base_thickness + $ga_vial_height + $2e], center = true);
    }

  }

}


genie_adapter();
