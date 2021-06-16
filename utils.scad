// common convenience functions and modules

// x/y but not z centered cube (regular center=true also centered z)
module xy_center_cube (size) {
  translate([-size[0]/2, -size[1]/2, 0])
  cube(size, center=false);
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
