use <utils.scad>;
use <screws.scad>;


// holder for mounting J-KEM OH5-DSC stirrer controller
module stirrer_controller_holder() {

  rod_diameter = 15;
  rod_height = 80;
  base = [100, rod_diameter, 25.4];
  support_height = 20;
  supports = [2*support_height/sqrt(2), rod_diameter, 2*support_height/sqrt(2)];
  screw_head_diameter = 12;
  attachment_thickness = 6.35;

  difference() {
    union() {
      cylinder(h=rod_height + base[2] + support_height, d=rod_diameter, $fn = 120);
      //translate([0, 0, base[2]]) cylinder(h=support_height, d1=base[1], d2 = rod_diameter, $fn = 120);
      translate([0, 0, base[2]]) xy_center_cube([rod_diameter, rod_diameter, support_height]);
      for(x=[-1, 1])
        translate([x*supports[0]/4, 0, base[2]-support_height/2])
          translate([-support_height/2, 0, 0])
            rotate([0, 45, 0])
              xy_center_cube(supports);
      xy_center_cube(base);
    };

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
