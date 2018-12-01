use <utils.scad>;
use <screws.scad>;

// 80/20 attachable bottle holder for media bottles
module bottle_holder(diameter) {

  base = [diameter + 45, 25.4, 10];
  screw_head_diameter = 12;
  attachment_thickness = 6.35;
  bracket = [(base[0] - diameter)/2, base[1], 20];

  difference() {
    union() {

      // base
      xy_center_cube(base);
      translate([0, 0, base[2]]) xy_center_cube([diameter, base[1], bracket[2]]);
      for (x=[-1, 1])
        translate([x*(base[0]/2 - bracket[0]/2), 0, base[2]])
        difference() {
          xy_center_cube(bracket);
          translate([0, 0, bracket[2]/2])
          rotate([0, x*42, 0]) xy_center_cube([bracket[0]*2, bracket[1]+0.1, bracket[2]*sqrt(2)]);
        }
    };

    // bottle cutout
    translate([0, 0, base[2]+0.1]) cylinder(h=bracket[2], d=diameter);

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

color("gray") bottle_holder(55.5); // 100mL bottle
