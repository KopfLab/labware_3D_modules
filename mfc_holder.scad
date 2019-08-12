use <utils.scad>;
use <screws.scad>;


// holder for alicat mfcs
module mfc_holder() {

  mfc_base = [92, 27, 12];
  rim_height = 11;
  rim_depth = 7;
  rim_thickness = 2;
  screw_head_diameter = 12;
  attachment_distance = 25.4;
  attachment_thickness = 6.35;
  base = mfc_base + [2 * rim_thickness, 2 * rim_thickness, 0];

  difference() {
    union() {
      // base + rim
      xy_center_cube(base + [0, 0, rim_height]);
    }

    // rim
    translate([0, 0, base[2]]) xy_center_cube(mfc_base);
    translate([0, 0, base[2]]) xy_center_cube(base - [-0.01, 2 * rim_depth, 0]);

    // 1/4-20 attachment screws
    for(x=[-1, 1])
      translate([x*base[0]/5, (attachment_distance - base[1])/2, attachment_thickness])
          cylinder(h = base[2], d = screw_head_diameter);

    for(x=[-1, 1])
      translate([x*base[0]/5, (attachment_distance - base[1])/2, 0])
          machine_screw("1/4-20", base[2], countersink = false, tolerance = 0.15, z_plus =0.01);

    // M4 attachment screw
    for(x=[-1, 0, 1])
      translate([x*base[0]/3, base[1]/2, base[2]/2])
        rotate([90, 0, 0]) rotate([0, 0, 90])
          machine_screw("M4", base[1], countersink = false, tolerance = 0.15, z_plus =0.01, stretch = 0.15);
  };
}

mfc_holder();
