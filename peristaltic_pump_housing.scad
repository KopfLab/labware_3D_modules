use <utils.scad>;
use <screws.scad>;
use <box.scad>;
use <lcd.scad>;


// watson marlow stepper pump cutout and screw holes
// (made on the first child in the stack)
// @param thickness how thick the panel is
module wm_stepper_pump(location = [0, 0, 0], show_pump = false) {
  // constants
  z_plus = 0.1;
  // screws
  screws = ["M4", 18.5, 17];
  tolerance = 0.2;

  // assembly
  difference() {
    children(0);
    translate(location) {
      // screws (relative to stepper motor)
      for (x = [-1, 1])
        translate([x*screws[1], screws[2], 0])
          machine_screw(screws[0], 48, z_plus = z_plus, tolerance = tolerance, countersink = false);
      // stepper motor cutout (centered)
      translate([0, 0, -z_plus])
        rotate([0, 0, 45])
          union() {
            xy_center_cube([42.4+2*tolerance, 42.4+2*tolerance, 48+2*z_plus]);
            translate([0, -42.5/2, 0]) xy_center_cube([9, 9, 48+2*z_plus]); //
          }
    }
  }

  if (show_pump) {
    translate(location) {
      // pump head (not printed)
      #translate([0,0,-42])
        translate([0, 1, 0]) // slightly offset from center
          xy_center_cube([64, 64, 42]);

      // stepper motor (not printed)
      #rotate([0, 0, 45])
        xy_center_cube([42, 42, 48]);
    }
  }
}


// make pump housing front
module peristaltic_pump_front(show_pump = false) {
  color("green")
    wm_stepper_pump(location = [0, -35, 0], show_pump=show_pump)
    LCD(type = "20x4", location = [0, 38, 0])
    box_lid([120, 160], thickness = 5, feet = 2);
}

// make pump housing body
module peristaltic_pump_body() {
  color("red")
    box_body([120, 160], length = 100, vent_width = 3);
}


!translate([-150, 0, 0]) peristaltic_pump_front();
peristaltic_pump_body();
