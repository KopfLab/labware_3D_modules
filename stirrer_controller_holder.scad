use <utils.scad>;
use <screws.scad>;


// holder for mounting J-KEM OH5-DSC stirrer controller
module stirrer_controller_holder() {

  rod_diameter = 15;
  rod_height = 80;
  base = [100, rod_diameter, 25.4];
  stop = [rod_diameter + 10, rod_diameter + 5, 10];
  right_support_height = 30;
  left_support_height = base[0]/2;
  screw_head_diameter = 12;
  attachment_thickness = 6.35;

  difference() {
    union() {
      cylinder(h=rod_height + base[2] + right_support_height, d=rod_diameter, $fn = 120);
      // right suport
      translate([-right_support_height/2, 0, base[2]-right_support_height/2])
        rotate([0, 45, 0])
          xy_center_cube([2*right_support_height/sqrt(2), rod_diameter, 2*right_support_height/sqrt(2)]);
      // left suport
      difference() {
        translate([-left_support_height/2, 0, base[2]-left_support_height/2])
          rotate([0, 45, 0])
            xy_center_cube([sqrt(2)*left_support_height, rod_diameter, sqrt(2)*left_support_height]);
        translate([left_support_height/2, 0, 0])
          xy_center_cube([left_support_height, rod_diameter+0.01, 2*left_support_height]);
      }
      // base
      xy_center_cube(base);
      // top of rod
      translate([0, rod_diameter/2 - stop[1]/2, rod_height + base[2] + right_support_height - stop[2]])
        xy_center_cube(stop);
    };

    // shave off bottom
    translate([0, 0, -base[2] - left_support_height/2 + 0.5])
      xy_center_cube([base[0]+0.01, rod_diameter+0.01, left_support_height]);

    for(x=[-1, 1])
      translate([x*base[0]/3, rod_diameter/2-attachment_thickness, base[2]/2])
        rotate([90, 0, 0])
          cylinder(h=rod_diameter-attachment_thickness+0.01, d = screw_head_diameter);

    for(x=[-1, 1])
      translate([x*base[0]/3, rod_diameter/2, base[2]/2])
        rotate([90, 0, 0])
          machine_screw("1/4-20", rod_diameter, countersink = false, tolerance = 0.15, z_plus =0.01);
  };
}

rotate([-90, 0, 0])
stirrer_controller_holder();
