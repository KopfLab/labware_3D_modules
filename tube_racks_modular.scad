// Attribution: these modular racks recreate the dovetailed racks designed by the Dormant lab in OpenSCAD
// https://github.com/oplz/DormantBioLabResources/tree/main/Prints/dovetailed_rack

// helper modules
use <utils.scad>;

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres
$anti_brim_rails = 0.25; // thickness of anti brim rails (for prints with brims)
$use_anti_brim_rails = true; // whether to use anti-brim rails

// common sizes
$tr_unit_length = 40;
$tr_base_height = 30;
$tr_base_corner_radius = 5;

$tr_adapter_width_max = 15;
$tr_adapter_width_max_tol = 1.1; // extra tolerance at the max width (TODO: consider consolidating the tolerances)
$tr_adapter_width_min = 10.5;
$tr_adapter_width_min_tol = 1.1; // extra tolerance at the min width
$tr_adapter_depth = 5;
$tr_adapter_corner_radius = 1;

$tr_adapter_spring_base = 3.75; // depth start of the spring
$tr_adapter_spring_depth = 3.25; // total depth of the spring
$tr_adapter_spring_height = 5; // height at attachment points
$tr_adapter_spring_thickness = 1; // thickness at narrowest point of the spring
$tr_adapter_spring_corner_radius = 2; // radius of rounding at top/bottom of spring (not currently used)

$tr_tube_base_min = 3; // minimum thickness of base below tube holes
$tr_tube_tolerance = 0.5; // diameter tolerance for loose fit

// @param x_scale how many unit lengths in x
// @param y_scale how many unit lengths in y
module modular_rack(x_scale = 1, y_scale = 1) {
  union() {
    difference() {
      union() {
        // center cube
        rounded_center_cube([x_scale * $tr_unit_length, y_scale * $tr_unit_length, $tr_base_height], corner_radius = $tr_base_corner_radius, center_z = false, center_x = false, center_y = false, round_z = true);
        // adapters with springs
        for (x = [0:x_scale-1])
          translate([ (1/2 + x) * $tr_unit_length - $tr_adapter_width_max/2, y_scale * $tr_unit_length, 0])
            modular_rack_adapter_with_spring();
        for (y = [0:y_scale-1])
          translate([0, (1/2 + y) * $tr_unit_length - $tr_adapter_width_max/2, 0])
            rotate([0, 0, 90])
              modular_rack_adapter_with_spring();
      }
      // adapter cutouts
      for (x = [0:x_scale-1])
        translate([ (1/2 + x) * $tr_unit_length - $tr_adapter_width_max/2, 0, 0])
          modular_rack_adapter_cutout();
      for (y = [0:y_scale-1])
        translate([x_scale * $tr_unit_length, (1/2 + y) * $tr_unit_length - $tr_adapter_width_max/2, 0])
          rotate([0, 0, 90])
            modular_rack_adapter_cutout();
    }
    // anti brim rails
    if ($use_anti_brim_rails) {
      for (x = [0:x_scale-1])
        translate([ (1/2 + x) * $tr_unit_length - $tr_adapter_width_max/2, 0, 0])
          cube([$tr_adapter_width_max, $anti_brim_rails, $anti_brim_rails]);
      for (y = [0:y_scale-1])
        translate([x_scale * $tr_unit_length, (1/2 + y) * $tr_unit_length - $tr_adapter_width_max/2, 0])
          rotate([0, 0, 90])
            cube([$tr_adapter_width_max, $anti_brim_rails, $anti_brim_rails]);
    }
  }
}

// adapter cutout for attachments
module modular_rack_adapter_cutout() {
  translate([0, -$2e, $tr_base_height/2])
    linear_extrude(height = $tr_base_height + $2e, center = true)
      translate([0, $tr_adapter_depth])
        mirror([0, 1])
          difference() {
            square([$tr_adapter_width_max, $tr_adapter_depth + $e]);
            diff = ($tr_adapter_width_max - $tr_adapter_width_min)/2  * $tr_adapter_corner_radius / $tr_adapter_depth ;
            for (x = [0, 1])
              translate([x * ($tr_adapter_width_max + $2e) - $e, 0]) mirror([x, 0, 0])
              difference() {
                polygon( points=[
                  [0, 0],
                  [($tr_adapter_width_max - $tr_adapter_width_min)/2, $tr_adapter_depth],
                  [0, $tr_adapter_depth]
                ]);
                translate([($tr_adapter_width_max - $tr_adapter_width_min)/2 - $tr_adapter_corner_radius - diff, $tr_adapter_depth - $tr_adapter_corner_radius])
                difference() {
                  square( 2 * $tr_adapter_corner_radius + $e);
                  circle(r = $tr_adapter_corner_radius);
                }
              }
            }
}

// adapter with spring for attachments
module modular_rack_adapter_with_spring() {
  spring_width = ($tr_adapter_width_min - $tr_adapter_width_min_tol) +
    $tr_adapter_spring_base / $tr_adapter_depth * ($tr_adapter_width_max - $tr_adapter_width_max_tol - $tr_adapter_width_min + $tr_adapter_width_min_tol);
  spring_location =
    ($tr_adapter_width_max - $tr_adapter_width_min + $tr_adapter_width_min_tol)/2 - $tr_adapter_spring_base / $tr_adapter_depth * ($tr_adapter_width_max - $tr_adapter_width_max_tol - $tr_adapter_width_min + $tr_adapter_width_min_tol)/2;
  union() {
    // spring
    translate([spring_location, $tr_adapter_spring_base, $tr_base_height/2])
      rotate([0, 90, 0])
        difference() {
          resize([$tr_base_height, $tr_adapter_spring_depth * 2, spring_width])
            cylinder(h = spring_width, d = $tr_adapter_spring_depth * 2);
          translate([0, 0, -$e])
            resize([$tr_base_height - 2 * $tr_adapter_spring_height, ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2, spring_width + $2e])
              cylinder(h = spring_width + $2e, d = ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2);
          translate([-$tr_base_height/2, -$tr_adapter_spring_depth * 2, -$e])
            cube([$tr_base_height, $tr_adapter_spring_depth * 2, spring_width + $2e]);
        }

    // adapter base
    translate([0, 0, $tr_base_height/2])
    linear_extrude(height = $tr_base_height, center = true)
    difference() {
      // adapter shape
      polygon( points=[
        [($tr_adapter_width_max - $tr_adapter_width_min + $tr_adapter_width_min_tol)/2, 0],
        [$tr_adapter_width_max_tol/2, $tr_adapter_depth],
        [$tr_adapter_width_max - $tr_adapter_width_max_tol/2, $tr_adapter_depth],
        [($tr_adapter_width_max + $tr_adapter_width_min - $tr_adapter_width_min_tol)/2, 0],
      ]);
      // space for spring
      translate([0, $tr_adapter_spring_base])
        square($tr_adapter_width_max);
    }

    // anti brim rails
    if ($use_anti_brim_rails) {
      for (x = [0, 1])
        translate([spring_location + x * ($tr_adapter_width_max - 2 * spring_location - $anti_brim_rails), 0, 0])
          cube([$anti_brim_rails, $tr_adapter_spring_base, $anti_brim_rails]);
    }
  }
}

// bottles
50ml_falcon_diameter = 28.5; // measured diameter

// test
difference() {
  modular_rack(x_scale = 1, y_scale = 1);
  translate([($tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, $tr_tube_base_min])
    cylinder(h = $tr_base_height + $2e, d = 50ml_falcon_diameter + $tr_tube_tolerance);
}
