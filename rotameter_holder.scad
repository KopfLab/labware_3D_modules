use <utils.scad>;
use <screws.scad>;

// holder for Ki (key instruments) rotameters
module rotameter_holder() {

  base = [75, 25.4, 10];
  screw_head_diameter = 12;
  attachment_thickness = 6.35;
  cutout = [32, base[1], 25];
  bracket = [(base[0]-cutout[0])/2, base[1], cutout[2]];
  rotameter_attachment = [14.34, 4, cutout[2]];

  difference() {
    union() {
      
      // base
      xy_center_cube(base);
      translate([0, 0, base[2]]) xy_center_cube(cutout);
      for (x=[-1, 1])
        translate([x*(base[0]/2 - bracket[0]/2), 0, base[2]])
        difference() {
          xy_center_cube(bracket);
          translate([0, 0, bracket[2]/2])
          rotate([0, x*50, 0]) xy_center_cube([bracket[0]*2, bracket[1]+0.1, bracket[2]*sqrt(2)]);
        }
    };

    // center cutout
    translate([0, -rotameter_attachment[1]+0.1, base[2]+0.1]) xy_center_cube(cutout);

    // back cutout
    translate([0, base[1]/2 - rotameter_attachment[1]/2+0.05, base[2]+0.1]) xy_center_cube(rotameter_attachment);

    // screw holes
    for(x=[-1, 1])
      translate([x*base[0]/2.8, 0, attachment_thickness])
          cylinder(h=base[2]+bracket[2]+0.01, d = screw_head_diameter);

    // screws
    for(x=[-1, 1])
      translate([x*base[0]/2.8, 0, 0])
          machine_screw("1/4-20", base[1], countersink = false, tolerance = 0.15, z_plus =0.01);
  };
}


rotameter_holder();
