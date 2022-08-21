// common convenience functions and modules

module center_cube (size, center_x = true, center_y = true, center_z = true) {
  translate([!center_x ? size.x/2 : 0, !center_y ? size.y/2 : 0, !center_z ? size.z/2 : 0])
    cube(size, center = true);
}


// x/y but not z centered cube (regular center=true also centered z)
module xy_center_cube (size) {
  center_cube(size, center_z = false);
}

xy_center_cube([40, 20, 4]);

// rounded cube that can be flared
module rounded_cube (size, round_left = true, round_right = true, scale_y = 1.0, scale_x = 1.0, z_center = false) {
  move = (z_center) ? [0, 0, 0] : [0, 0, size[2]/2];
  translate(move)
  linear_extrude(height = size[2], center = true, convexity = 10, slices = 20, scale = [scale_x, scale_y])
  union() {
    rounds = (round_left && round_right) ? [-1, 1] : ((round_left) ? [-1] : ((round_right) ? [+1] : []));
    nonrounds = (!round_left && !round_right) ? [-1, 1] : ((!round_left) ? [-1] : ((!round_right) ? [+1] : []));
    for (x = rounds) translate([x * (size[0] - size[1])/2, 0]) circle(d = size[1]);
    for (x = nonrounds) translate([x * (size[0] - size[1])/2, 0]) square(size[1], center = true);
    square([size[0] - size[1], size[1]], center = true);
  }
}

translate([0, 80, 0]) color("aqua")
rounded_cube([30, 10, 20], round_left = true, round_right = true, scale_y = 0.5, scale_x = 0.25);

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

translate([0, 120, 0]) color("gray")
rounded_center_cube([50, 20, 30], corner_radius = 5, round_y = [true, true, false, false], round_x = [true, true, false, false], round_z = true);

// x/y center cube with feet
// @param feet how many feet to add
// @param foot_height what the height of each foot is (in mm)
// @param tolerance what tolerance to build into the feet to make sure stacking works
// @param stackable whether it should be stackable or not
module xy_center_cube_with_feet (size, feet = 2, foot_height = 5, tolerance = 0.3, stackable = true) {
  foot_d = foot_height/cos(180/6);
  foot_list = [for (i = [1 : 1 : feet]) i];
  foot_spacing = size[0]/(2*feet);
  foot_width = size[2]/sqrt(3); // width of bottom foot size
  difference() {
    union() {
      translate([-size[0]/2, -size[1]/2, 0])
        cube(size, center=false);

      // add feet
      for(i = foot_list)
        translate([-size[0]/2 + (2*i - 1) * foot_spacing, - size[1]/2, 0])
          rotate([0, 0, 0])
            union() {
              translate([-foot_width/2, 0, 0])
              cylinder(h=size[2] - tolerance, d=foot_d, $fn=6, center = false);
              translate([+foot_width/2, 0, 0])
              cylinder(h=size[2] - tolerance, d=foot_d, $fn=6, center = false);
            }
    }
    if (stackable) {
      // add feet cutout
      z_plus = 0.1; // z plus for cutouts
      for(i = foot_list)
        translate([-size[0]/2 + (2*i - 1) * foot_spacing, + size[1]/2, -z_plus])
          rotate([0, 0, 0])
            union() {
              translate([-foot_width/2, 0, 0])
              cylinder(h=size[2]+2*z_plus, d=foot_d+tolerance, $fn=6, center = false);
              translate([+foot_width/2, 0, 0])
              cylinder(h=size[2]+2*z_plus, d=foot_d+tolerance, $fn=6, center = false);
            }
    }
  }
}

translate([0, 40, 0])
  color("green")
    xy_center_cube_with_feet([40, 20, 4]);


translate([0, -40, 0])
  color("red")
    xy_center_cube_with_feet([80, 20, 4], feet = 5, foot_height = 6, stackable = false);
