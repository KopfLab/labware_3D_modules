use <utils.scad>;
use <screws.scad>;

e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders
nylon_tol = 0.1; // extra tolerance for nylon parts shrinkage
$extra_tolerance = nylon_tol; // for cutouts, screws, etc.
$screw_hole_tolerance = 0.15 + 2 * $extra_tolerance; // tolernace for screw holes
$alu_block_x = 120; // x dimension of the aluminum block
$alu_block_y = 60; // y dimension of the aluminum block
$base_height = 15; // height of the cooler base
$top_thickness = 15; // height of the cooler top
$wall_thickness = 15; // minimum thickness of the cavity walls
$cavity_diameter = 75; // diameter of the column cavity
$cavity_height = 20; // height of the column cavity
$capillary_diameter = 5; // min width of the capillary inlets
$capillary_spacing = 70; // spacing of the capillary inlets
$total_x = $alu_block_x + 2 * $wall_thickness; // total x dimension of block
$total_y = $cavity_diameter + 2 * $wall_thickness; // total y dimension
$corner_screws_x = $total_x/2 - 2/3 * $wall_thickness; // corner screws location
$corner_screws_y = $total_y/2 - 2/3 * $wall_thickness; // corner screws location
$attachment_screws_x = 80/2; // peltier block attachment screws location
$attachment_screws_y = 34/2; // peltier block attachment screws location
$screw_driver_notch = [8, 10, 2]; // size of screwdriver notch

module cooler_base(total_x = $total_x, total_y = $total_y, alu_block_x = $alu_block_x, alu_block_y = $alu_block_y, base_height = $base_height, wall_thickness = $wall_thickness, cavity_diameter = $cavity_diameter, cavity_height = $cavity_height, capillary_diameter = $capillary_diameter, capillary_spacing = $capillary_spacing) {
  difference() {
    xy_center_cube([total_x, total_y, base_height + cavity_height]);
    // alu block cutout
    translate([0, 0, -e])
      xy_center_cube([alu_block_x + 2 * $extra_tolerance, alu_block_y + 2 * $extra_tolerance, base_height + cavity_height + 2e]);
    // cavity cutout
    translate([0, 0, base_height])
      cylinder(d = cavity_diameter, h = cavity_height + e);
    // capillary cutouts
    for (x = [-1, 1])
      translate([x * capillary_spacing/2, (total_y + alu_block_y + 2e)/4, base_height])
        xy_center_cube([capillary_diameter, (total_y - alu_block_y)/2 + 2e, cavity_height + e]);
    // attachment screws
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * $corner_screws_x, y * $corner_screws_y, -e])
          union() {
            machine_screw(name = "M5", length = base_height + cavity_height + 2e, tolerance = $screw_hole_tolerance, countersink = false);
            hexnut(name = "M5", screw_hole = false, tolerance = 2 * $extra_tolerance);
          }
  }
}

module cooler_top(total_x = $total_x, total_y = $total_y, top_thickness = $top_thickness) {
  difference() {
    xy_center_cube([total_x, total_y, top_thickness]);
    // attachment screws
    for (x = [-1, 1])
      for (y = [-1, 1]) {
        translate([x * $corner_screws_x, y * $corner_screws_y, -e])
          machine_screw(name = "M5", length = top_thickness + 2e, tolerance = $screw_hole_tolerance, countersink = false);
        translate([x * $attachment_screws_x, y * $attachment_screws_y, -e])
          machine_screw(name = "M5", length = top_thickness + 2e, tolerance = $screw_hole_tolerance, countersink = false);
      }
    // screw driver notch
    for (x = [-1, 1])
      translate([x * (total_x/2 - $screw_driver_notch[0]/2 + e), 0, -e])
        xy_center_cube($screw_driver_notch);
  }
}


cooler_base();
color("green") translate([0, 0, 40]) cooler_top();
