use <utils.scad>;
use <screws.scad>;

e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

// generate attachment block
// @param block [width, height, depth]
// @param walls thickness
// @param screw_depth how deep the screws should go into the block (i.e. the wall before the nut + nut + beyond)
// @param whether to include a bottom rail (by default yes)
// @param center width of the center cutout (none by default), only matters if there is a bottom rail
// @param rails_tolerance (extra gap for good fit)
// @paran screws_tolerance extra tolerance for screws
module attachment_block(block, walls, screw_depth, bottom_rail = true, center = 0, rails_tolerance = 0.4, screws_tolerance = 0) {
  screw_location = block[0]/2 - get_hexnut("M3")[1]/2 - 1.5 * walls;
  echo(str("INFO: attachment block ", block[0], "mm x ", block[1], "mm x ", block[2], "mm with screw locations +/- ", screw_location, "mm"));
  union() {
    difference() {
      // whole block
      xy_center_cube(block);
      // center cutout
      if (bottom_rail == true && center > 0) {
        translate([0, 0, -e])
        xy_center_cube([center + 2 * rails_tolerance, block[1] + 2e, 2 * walls + e]);
      }
      // front cutout
      front = (bottom_rail) ?
        [block[0] - 3 * walls + 2 * rails_tolerance, block[1] - 1.5 * walls + rails_tolerance + e, 2 * walls + e] :
        [block[0] - 3 * walls + 2 * rails_tolerance, block[1] + 2e, 2 * walls + e];
      translate([0, (front[1] - block[1] - e)/2, - e])
      xy_center_cube(front);
      // rails cutout
      rails = (bottom_rail) ?
        [block[0] - 2 * walls + 2 * rails_tolerance, block[1] - walls + rails_tolerance + e, walls + rails_tolerance]:
        [block[0] - 2 * walls + 2 * rails_tolerance, block[1] + 2e, walls + rails_tolerance];
      translate([0, (rails[1] - block[1] - e)/2, walls - rails_tolerance])
      xy_center_cube(rails);
      // hex nuts for attachment
      for(x = [-1, 1]) {
        translate([x * screw_location, 0, -e])
        rotate([0, 0, -90]) // translate along x axis
        union() {
          translate([0, 0, 3 * walls + e])
          hexnut("M3", screw_hole = false, z_plus = 0.2, tolerance = 0.15, stretch = 0.15, slot = block[1]/2 + e);
          machine_screw("M3", length = screw_depth + 2 * walls + 2e, tolerance = 0.15 + screws_tolerance, stretch = 0.15, countersink = false);
        }
      }
    }
    // small cut-away bottom rail for easier print if bottom_rail = false
    if (!bottom_rail) {
      rail_thickness = 0.2;
      translate([0, block[1]/2 - rail_thickness/2, 0])
      xy_center_cube([block[0], rail_thickness, rail_thickness]);
    }
  }
}

// generate attachment
// @param block [width, height, depth]
// @param walls thickness
// @param whether to include a bottom rail (by default yes)
// @param center width of the center cutout (none by default), only matters if there is a bottom rail
// @paran screws_tolerance extra tolerance for screws
module attachment(block, walls, bottom_rail = true, center = 0, screws_tolerance = 0) {
  front =
    (bottom_rail) ?
    [block[0] - 3 * walls, block[1] - 1.5 * walls, block[2]] :
    [block[0] - 3 * walls, block[1], block[2]];
  rails = (bottom_rail) ?
    [block[0] - 2 * walls, block[1] - walls, walls] :
    [block[0] - 2 * walls, block[1], walls];
  screw_location = block[0]/2 - get_hexnut("M3")[1]/2 - 1.5 * walls;
  echo(str("INFO: attachment top ", front[0], "mm x ", front[1], "mm x ", front[2], "mm with screw locations +/- ", screw_location, "mm"));
  difference() {
    union() {
      // center block
      if (bottom_rail == true && center > 0) {
        xy_center_cube([center, block[1], block[2]]);
      }
      // front
      translate([0, (front[1] - block[1])/2, 0])
      xy_center_cube(front);
      // rails
      translate([0, (rails[1] - block[1])/2, 0])
      xy_center_cube(rails);
    }
    // attachment screws
    for(x = [-1, 1]) {
      translate([x * screw_location, 0, -e])
      machine_screw("M3", length = block[2] + 2e, tolerance = 0.15 + screws_tolerance, stretch = 0, countersink = false);
    }
  }
}

// example
color("yellow")
attachment_block(block = [30, 14, 15], walls = 3, center = 10, screw_depth = 6);

color("teal")
translate([0, 0, 6])
rotate([0, 180, 0])
attachment(block = [30, 14, 10], walls = 3, center = 10);
