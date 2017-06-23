// common convenience functions and modules
use <screws.scad>;

// x/y but not z centered cube (regular center=true also centered z)
module xy_center_cube (size) {
  translate([-size[0]/2, -size[1]/2, 0])
  cube(size, center=false);
}

xy_center_cube([40, 20, 4]);


// x/y center cube with feet
// @param feet how many feet to add
// @param foot_height what the height of each foot is (in mm)
// @param tolerance what tolerance to build into the feet to make sure stacking works
// @param stackable whether it should be stackable or not
module xy_center_cube_with_feet (size, feet = 2, foot_height = 5, tolerance = 0.3, stackable = true) {
  foot_d = foot_height/cos(180/6);
  foot_list = [for (i = [1 : 1 : feet]) i];
  foot_spacing = size[0]/(2*feet);
  difference() {
    union() {
      translate([-size[0]/2, -size[1]/2, 0])
        cube(size, center=false);

      // add feet
      for(i = foot_list)
        translate([-size[0]/2 + (2*i - 1) * foot_spacing, - size[1]/2, 0])
          rotate([0, 0, 0])
            cylinder(h=size[2] - tolerance, d=foot_d, $fn=6, center = false);
    }
    if (stackable) {
      // add feet cutout
      z_plus = 0.1; // z plus for cutouts
      for(i = foot_list)
        translate([-size[0]/2 + (2*i - 1) * foot_spacing, + size[1]/2, -z_plus])
          rotate([0, 0, 0])
            cylinder(h=size[2]+2*z_plus, d=foot_d+tolerance, $fn=6, center = false);
    }
  }
}

translate([0, 40, 0])
  color("green")
    xy_center_cube_with_feet([40, 20, 4]);


translate([0, -40, 0])
  color("red")
    xy_center_cube_with_feet([80, 20, 4], feet = 5, foot_height = 6, stackable = false);


// standard attachment for a rectangular module affixed on top of a board
// @param thickness how thick base board is
// @param screws array of screw parameters (type, location x, location y, tolerance)
// @param block array of cube parameters (length, width, thickness, offset from base board)
// @param location central point of the cutout
// @param rotation how much to rotate
// @param show whether to show cube (not intended for printing)
module block_attachment (thickness, screws, block, location = [0,0,0], rotation = [0,0,0], show = false) {
  // parameters
  z_plus = 0.1; // how much thicker to make cutouts in z

  difference() {
    union() {
      children(0);
      if (show) {
        // cube outline (not printed)
        translate(location) rotate(rotation)
          translate([0, 0, thickness+block[3]])
            #xy_center_cube([block[0], block[1], block[2]]);
      }
    }

    translate(location)
      rotate(rotation) {
        // screw holes
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*screws[1], y*screws[2], 0])
              machine_screw(screws[0], thickness+block[0]+block[1], tolerance = screws[3], z_plus = z_plus);
      }
  }
}

translate([80, 30, 0])
  color("blue")
    block_attachment(10, ["M3", 15, 5, 0.2], [40, 20, 10, 5], show = true)
      xy_center_cube([60, 30, 10]);

translate([80, -30, 0])
  color("blue")
    block_attachment(10, ["M3", 15, 5, 0.2], [40, 20, 10, 5], show = false)
      xy_center_cube([60, 30, 10]);
