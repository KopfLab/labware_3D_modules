use <utils.scad>;
use <screws.scad>;

// @todo: implement feet for the box

// generate box lid
// @param size width and height dimensions of the box (in mm)
// @param lid thickness of the lid (in mm)
// @param wall thickness of box walls (in mm)
// @param holders thickness (in mm) of holders for wall attachment
// @param gap gap between the holders and the body walls (in mm) to avoid too tight
// @param feet how many feet to include
// @param feet_params = [foot_height, tolerance, stackable]
// @param adatpers = true/false
module box_lid(size, thickness = 4, wall = 4, holders = 4, gap = 0.4, feet = 0, feet_params = [5, 0.3, true], adapters = true) {

  // constants
  z_plus = 0.1; // how much thicker to make cutouts in z
  hexnut_plus = 0.1; // allow a little extra space for hexnuts

  // screw location parameters
  screw_loc = [
    size[0]/2, // x location flush with walls
    size[1]/2 - wall - holders - 5, // y location away from sides,
    5 // z vertical offset from base
  ];

  // holder blocks
  holder_x = [
    holders + 10, // extra space for screw location
    holders,
    12 // height
  ];
  holder_y = [holder_x[1], holder_x[0], holder_x[2]];

  // assembly
  difference() {
    union() {
      // base with feet
      xy_center_cube_with_feet([size[0], size[1], thickness], feet = feet,
        foot_height = feet_params[0], tolerance = feet_params[1], stackable = feet_params[2]);

      // holders
      if (adapters) {
        for(x=[-1, 1])
          for(y=[-1, 1]) {
            translate([x*((size[0]-holder_x[0]-gap)/2-wall), y*((size[1]-holder_x[1]-gap)/2-wall), thickness])
              xy_center_cube(holder_x);
            translate([x*((size[0]-holder_y[0]-gap)/2-wall), y*((size[1]-holder_y[1]-gap)/2-wall), thickness])
              xy_center_cube(holder_y);
        }
      }
    }

    // screw holes
    if (adapters) {
      translate([0, 0, thickness])
      for(x=[-1, 1])
        for(y=[-1, 1])
            union() {
              // hexnut
              translate([x*(screw_loc[0] - wall - hexnut_plus), y*screw_loc[1], screw_loc[2]])
                rotate([0, -x*90, 0])
                  hexnut("M3", screw_hole = false, z_plus = hexnut_plus + z_plus + gap/2, tolerance = 0.025, stretch = 0.15);
              // screw
              translate([x*screw_loc[0], y*screw_loc[1], screw_loc[2]])
                rotate([0, -x*90, 0])
                  machine_screw("M3", length = wall+holders+gap, tolerance = 0.15, stretch = 0.15, z_plus=z_plus, countersink = false);
            }
    }
  }

}

// generate box body
// @param size width and height dimensions of the box (in mm)
// @param length of the box (in mm)
// @param wall thickness of box walls (in mm)
// @param holders thickness (in mm) of holders for wall attachment
// @param vents number of vents
// @param vent_width the width of each vent (in mm)
// @param vent_spacing_mod how much to change vent spacing from default (can be - or +, in mm)
// @param vents_both_sides whether vents on both or only one side
// @param attachments_tops/bottom true/false whether to include the screw holes for these
module box_body(size, length, wall = 4, holders = 4, vents = 5, vent_width = 1, vent_spacing_mod = 0, vents_both_sides = true, attachments_top = true, attachments_bottom = true) {

  // constants
  z_plus = 0.1; // how much thicker to make cutouts in z

  // screw location parameters
  screw_loc = [
    size[0]/2, // x location flush with walls
    size[1]/2 - wall - holders - 5, // y location away from sides,
    5 // z vertical offset from base
  ];

  // ventilation strip parameters
  ventilation_strip = [
    size[0] + 2*z_plus,
    vent_width,
    length - 2*screw_loc[2] - 2*7 // vent gap from top and bottom
  ];

  // ventilation location
  ventilation_location = vents_both_sides ? [0, 0, 0] : [-wall-z_plus, 0, 0];

  // assembly
  difference() {
    xy_center_cube([size[0], size[1], length]);
    // inside void
    translate([0, 0, -z_plus])
      xy_center_cube([size[0]-2*wall, size[1]-2*wall, length+2*z_plus]);

    // screw holes
    z_list = attachments_top && attachments_bottom ? [-1, 1] : (attachments_top ? [-1] : (attachments_bottom ? [1] : []));
    for(x=[-1, 1])
      for(y=[-1, 1])
        for(z=z_list)
          translate([x*screw_loc[0], y*screw_loc[1], length/2-z*(length/2-screw_loc[2])])
            rotate([0, -x*90, 0])
              machine_screw("M3", wall+holders, tolerance = 0.15, stretch = 0.15, z_plus = z_plus);

    // ventilation
    vent_list = [for (i = [1 : 1 : vents]) i];
    total_vent_space = size[1] - 2 * wall - 2 * vent_width + vents * vent_spacing_mod;
    vent_spacing = total_vent_space/(vents + 1);
    for(y = vent_list)
      translate(ventilation_location)
        translate([0, -total_vent_space/2 + y*vent_spacing, (length - ventilation_strip[2])/2])
          xy_center_cube(ventilation_strip);
  }

}

// examples (standard)
size = [40, 40];
translate([0, 70, 0]) {
  color("green") box_lid(size);
  translate([0, 0, 16]) color("red") box_body(size, length = 30);
  translate([0, 0, 64]) mirror([0, 0, 1]) color("blue") box_lid(size, thickness = 4);
}

// customized
size2 = [120, 60];
color("green") box_lid(size2, thickness = 10, wall = 8, holders = 6, gap = 1, feet = 4, feet_params = [6, 0.5, false]);
translate([0, -70, 0]) color("red") box_body(size2, length = 50, wall = 8, holders = 6, vents = 7, vent_width = 1.5);
