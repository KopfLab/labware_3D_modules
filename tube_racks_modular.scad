// Attribution: these modular racks recreate the dovetailed racks designed by the Dormant lab in OpenSCAD
// https://github.com/oplz/DormantBioLabResources/tree/main/Prints/dovetailed_rack

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres
$anti_brim_rails = 0.25; // thickness of anti brim rails (for prints with brims)
$use_anti_brim_rails = true; // whether to use anti-brim rails

// common sizes
$tr_unit_length = 50;
$tr_base_height = 30;
$tr_base_corner_radius = 5;

$tr_adapter_width_max = 22;
$tr_adapter_width_max_tol = 1.1; // extra tolerance at the max width (TODO: consider consolidating the tolerances)
$tr_adapter_width_min = 17;
$tr_adapter_width_min_tol = 1.1; // extra tolerance at the min width
$tr_adapter_depth = 5;
$tr_adapter_corner_radius = 1;

$tr_horizontal_spring = true; // whether to have a horizontal spring
$tr_vertical_spring = false; // whether to have a vertical spring
$tr_adapter_spring_base = 3.75; // depth start of the spring
$tr_adapter_spring_depth = 2.75; // total depth of the spring
$tr_adapter_spring_attachment = 5; // attachment width
$tr_adapter_spring_thickness = 1; // thickness at narrowest point of the spring
$tr_adapter_spring_corner_radius = 2; // radius of rounding at top/bottom of spring (not currently used)

$tr_tube_base_min = 2; // minimum thickness of base below tube holes
$tr_tube_tolerance = 0.2; // diameter tolerance for good fit

// @param x_scale how many unit lengths in x
// @param y_scale how many unit lengths in y
module modular_rack(x_scale = 1, y_scale = 1, anti_brim_rails = $use_anti_brim_rails) {
  union() {
    difference() {
      union() {
        // center cube
        rounded_center_cube([x_scale * $tr_unit_length, y_scale * $tr_unit_length, $tr_base_height], corner_radius = $tr_base_corner_radius, center_z = false, center_x = false, center_y = false, round_z = true);
        // adapters with springs
        for (x = [0:x_scale-1])
          translate([ (1/2 + x) * $tr_unit_length - $tr_adapter_width_max/2, y_scale * $tr_unit_length, 0])
            modular_rack_adapter_with_spring(anti_brim_rails = anti_brim_rails);
        for (y = [0:y_scale-1])
          translate([0, (1/2 + y) * $tr_unit_length - $tr_adapter_width_max/2, 0])
            rotate([0, 0, 90])
              modular_rack_adapter_with_spring(anti_brim_rails = anti_brim_rails);
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
    if (anti_brim_rails) {
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
module modular_rack_adapter_with_spring(anti_brim_rails = $use_anti_brim_rails, vertical_spring = $tr_vertical_spring, horizontal_spring = $tr_horizontal_spring) {
  spring_width = ($tr_adapter_width_min - $tr_adapter_width_min_tol) +
    $tr_adapter_spring_base / $tr_adapter_depth * ($tr_adapter_width_max - $tr_adapter_width_max_tol - $tr_adapter_width_min + $tr_adapter_width_min_tol);
  spring_location =
    ($tr_adapter_width_max - $tr_adapter_width_min + $tr_adapter_width_min_tol)/2 - $tr_adapter_spring_base / $tr_adapter_depth * ($tr_adapter_width_max - $tr_adapter_width_max_tol - $tr_adapter_width_min + $tr_adapter_width_min_tol)/2;
  union() {
    // vertical spring
    if (vertical_spring) {
      translate([spring_location, $tr_adapter_spring_base, $tr_base_height/2])
        rotate([0, 90, 0])
          difference() {
            resize([$tr_base_height, $tr_adapter_spring_depth * 2, spring_width])
              cylinder(h = spring_width, d = $tr_adapter_spring_depth * 2);
            translate([0, 0, -$e])
              resize([$tr_base_height - 2 * $tr_adapter_spring_attachment, ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2, spring_width + $2e])
                cylinder(h = spring_width + $2e, d = ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2);
            translate([-$tr_base_height/2, -$tr_adapter_spring_depth * 2, -$e])
              cube([$tr_base_height, $tr_adapter_spring_depth * 2, spring_width + $2e]);
          }
    }

    // horizontal spring
    if (horizontal_spring) {
      translate([spring_width/2 + spring_location, $tr_adapter_spring_base, 0])
        difference() {
          // outer spring wall
          resize([spring_width, $tr_adapter_spring_depth * 2, $tr_base_height])
            cylinder(h = $tr_base_height, d = $tr_adapter_spring_depth * 2);
          // inner spring wall
          translate([0, 0, -$e])
            resize([spring_width - $tr_adapter_spring_attachment, ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2, $tr_base_height + $2e])
              cylinder(h = $tr_base_height + $2e, d = ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2);
          // half wall only
          translate([-spring_width/2, -$tr_adapter_spring_depth, -$e])
            cube([spring_width, $tr_adapter_spring_depth, $tr_base_height + $2e]);
        }
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
      // additional cutout for horizontal spring
      if (horizontal_spring) {
        translate([spring_width/2 + spring_location, $tr_adapter_spring_base])
          resize([spring_width - $tr_adapter_spring_attachment, ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2])
            circle(d = ($tr_adapter_spring_depth - $tr_adapter_spring_thickness) * 2);

      }
    }

    // anti brim rails
    if (anti_brim_rails) {
      for (x = [0, 1])
        translate([spring_location + x * ($tr_adapter_width_max - 2 * spring_location - $anti_brim_rails), 0, 0])
          cube([$anti_brim_rails, $tr_adapter_spring_base, $anti_brim_rails]);
    }
  }
}

// helper module for rounding a cube
// @param corner_radius what radius to use for the edges/corners
// @param round_x/y/z whether to round the edges along the axis - single value true/false for all edges along that axis, or a list of 4 true/false e.g. [true, false, false, true] to control each edge along that axis
// @param center_x/y/z whether to center cube in x/y/z - true/false
module rounded_center_cube (size, corner_radius, round_x = false, round_y = false, round_z = false, center_x = true, center_y = true, center_z = true) {
  // parameters
  corner_d = 2 * corner_radius;

  // edges
  round_x = is_list(round_x) && len(round_x) == 4 ? round_x : [round_x, round_x, round_x, round_x];
  round_y = is_list(round_y) && len(round_y) == 4 ? round_y : [round_y, round_y, round_y, round_y];
  round_z = is_list(round_z) && len(round_z) == 4 ? round_z : [round_z, round_z, round_z, round_z];
  edges = [round_x[0], round_x[2], round_x[1], round_x[3], round_y[0], round_y[2], round_y[1], round_y[3], round_z[0], round_z[1], round_z[2], round_z[3]];
  x = [0, 0, 0, 0, 1, 1, -1, -1, 1, 1, -1, -1];
  y = [1, 1, -1, -1, 0, 0, 0, 0, 1, -1, 1, -1];
  z = [1, -1, 1, -1, 1, -1, 1, -1, 0, 0, 0, 0];
  h = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2];
  corners = [[0, 4, 8], [1, 5, 8], [2, 4, 9], [3, 5, 9], [0, 6, 10], [1, 7, 10], [2, 6, 11], [3, 7, 11]];

  // helper function for the cube rounding
  module rounded_edges(size, offset, corner_radius, edges, i) {
    if (edges[i])
      translate([x[i] * (size.x/2 - corner_radius), y[i] * (size.y/2 - corner_radius), z[i] * (size.z/2 - corner_radius)])
        rotate([90 * abs(x[i] * z[i]), 90 * abs(y[i] * z[i]), 0])
          cylinder(h = size[h[i]] + offset, d = corner_d, center = true);
    else
      translate([x[i] * (size.x/2 - corner_radius), y[i] * (size.y/2 - corner_radius), z[i] * (size.z/2 - corner_radius)])
        rotate([90 * abs(x[i] * z[i]), 90 * abs(y[i] * z[i]), 0])
          cube([ corner_d, corner_d, size[h[i]] + offset], center = true);
  }

  translate([!center_x ? size.x/2 : 0, !center_y ? size.y/2 : 0, !center_z ? size.z/2 : 0])
  union() {
    // create central structure
    cube([size.x, size.y - corner_d, size.z - corner_d], center = true);
    cube([size.x - corner_d, size.y, size.z - corner_d], center = true);
    cube([size.x - corner_d, size.y - corner_d, size.z], center = true);

    // create edges
    for (i = [0:(len(x) - 1)])
      rounded_edges(size, -corner_d, corner_radius, edges, i);

    // create round corners
    for (x = [-1, 1]) for(y = [-1, 1]) for(z = [-1, 1])
      translate([x * (size.x/2 - corner_radius), y * (size.y/2 - corner_radius), z * (size.z/2 - corner_radius)])
        sphere(r = corner_radius);

    // create edged corners
    for (corner = corners)
      if (!edges[corner[0]] || !edges[corner[1]] || !edges[corner[2]])
        intersection() {
          // not a round corner
          rounded_edges(size, 0, corner_radius, edges, corner[0]);
          rounded_edges(size, 0, corner_radius, edges, corner[1]);
          rounded_edges(size, 0, corner_radius, edges, corner[2]);
        }

  }
}

// bottles
50ml_falcon_lid_diameter = 34.5; // lid diameter
50ml_falcon_tube_diameter = 28.5; // measured diameter
50ml_falcon_base_height = 14.5; // base height
50ml_falcon_base_diameter = 7.5; // base diameter

15ml_falcon_lid_diameter = 23.0; // lid diameter
15ml_falcon_tube_diameter = 16.5; // tube diameter
15ml_falcon_base_height = 21.5; // base height
15ml_falcon_base_diameter = 6.0; // base diameter

// 50 ml test
difference() {
  x_scale = 2;
  modular_rack(x_scale = x_scale, y_scale = 1);
  y_offset = 0.38;
  x_offset = sqrt(1 - pow(y_offset, 2)); // to keep overall center center distance the same
  for(x = [-1, 0, 1])
  for(y = [0])
  translate([-x * x_offset * 50ml_falcon_lid_diameter,  (-y_offset/2 + abs(x + 1)%2 * y_offset) * 50ml_falcon_lid_diameter, 0]) {
    translate([(x_scale * $tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, $tr_tube_base_min + 50ml_falcon_base_height])
      cylinder(h = $tr_base_height, d = 50ml_falcon_tube_diameter + $tr_tube_tolerance);
    translate([(x_scale * $tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, $tr_tube_base_min])
        cylinder(h = 50ml_falcon_base_height + $e, d1 = 50ml_falcon_base_diameter + $tr_tube_tolerance, d2 = 50ml_falcon_tube_diameter + $tr_tube_tolerance);
    translate([(x_scale * $tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, -$e])
      cylinder(h = $tr_base_height + $2e, d = 50ml_falcon_base_diameter + $tr_tube_tolerance);
  }
}

// 15 ml test
!difference() {
  modular_rack(x_scale = 1, y_scale = 1);
  offset = 1; //sqrt(2);
  for(x = [-1,1 ])
  for(y = [-1,1 ])
  translate([-x * 1/(offset * 2) * 15ml_falcon_lid_diameter,  y * 1/(offset * 2) * 15ml_falcon_lid_diameter, 0]) {
    translate([($tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, $tr_tube_base_min + 15ml_falcon_base_height])
      cylinder(h = $tr_base_height, d = 15ml_falcon_tube_diameter + $tr_tube_tolerance);
    translate([($tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, $tr_tube_base_min])
        cylinder(h = 15ml_falcon_base_height + $e, d1 = 15ml_falcon_base_diameter + $tr_tube_tolerance, d2 = 15ml_falcon_tube_diameter + $tr_tube_tolerance);
    translate([($tr_unit_length - $tr_adapter_depth)/2, ($tr_unit_length + $tr_adapter_depth)/2, -$e])
      cylinder(h = $tr_base_height + $2e, d = 15ml_falcon_base_diameter + $tr_tube_tolerance);
  }
}
