// common convenience functions and modules

// x/y but not z centered cube (regular center=true also centered z)
module xy_center_cube (size) {
  translate([-size[0]/2, -size[1]/2, 0])
  cube(size, center=false);
}

xy_center_cube([100, 140, 4]);
