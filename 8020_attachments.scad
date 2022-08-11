use <utils.scad>;
use <screws.scad>;

// global rendering constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e= 0.02; // twice epsilon for extra length when translating by -e
$fn = $preview ? 30 : 60; // number of default vertices when rendering cylinders

// material constants
nylon_tol = 0.1; // extra tolerance for nylon parts shrinkage
$extra_tolerance = nylon_tol; // for cutouts, screws, etc.
$screw_hole_tolerance = 0.15 + 2 * $extra_tolerance; // tolernace for screw holes
$screw_threadable_tolerance = 0; // tolerance for screw holes that can be threaded into

// rod attachment for 1010 80/20 aluminum extrusions
module rod_holder (rod_diameter, wall_thickness = 4, base_thickness = 6.35, base_width = 25) {

  // rod dimensions
  rod_w_walls = rod_diameter + 2 * wall_thickness;
  skirt = rod_w_walls - 2 * base_thickness;

  // block dimensions
  screw_head_diameter = 12;
  screws_distance = rod_diameter + 2 * wall_thickness + screw_head_diameter + skirt + 2;
  holder_length = screws_distance + screw_head_diameter + 4;
  base = [holder_length, base_width, base_thickness];

  // assembly
  difference() {
    union() {
      // base
      xy_center_cube(base);
      // rod holder base with skirts
      difference() {
        xy_center_cube([rod_w_walls + skirt, base_width, rod_w_walls/2]);
        for(x=[-1, 1])
          translate([x * (rod_w_walls/2 + skirt/2), base_width/2 + $e, rod_w_walls/2])
            rotate([90, 0, 0])
            cylinder(d = skirt, h = base_width + $2e);
      }
      // rod holder top
      translate([0, base_width/2, rod_w_walls/2])
        rotate([90, 0, 0])
        cylinder(d = rod_w_walls, h = base_width);
    }

    // rod
    translate([0, base_width/2 + $e, rod_w_walls/2])
      rotate([90, 0, 0])
      cylinder(d = rod_diameter + $screw_hole_tolerance, h = base_width + $2e);

    // 1/4-20 attachment screws
    for(x=[-1, 1])
      translate([x*screws_distance/2, 0, -$e])
        machine_screw("1/4-20", base[2] + $2e, countersink = false, tolerance = $screw_hole_tolerance);

    // rod set screw
    translate([0, 0, rod_w_walls - wall_thickness])
      machine_screw(name = "M3", length = wall_thickness, countersink = false, tolerance = $screw_threadable_tolerance);
  };
}

// make rod holder for 1/2" diameter rod
// print on the side for better strength
rotate([90, 0, 0]) rod_holder(rod_diameter = 12.7);
