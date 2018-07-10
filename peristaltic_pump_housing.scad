use <utils.scad>;
use <screws.scad>;
use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

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
module peristaltic_pump_front(size, show_pump = false) {
  thickness = 5;
  color("green")
    wm_stepper_pump(location = [0, -33, 0], show_pump=show_pump)
    LCD(type = "20x4", location = [0, 30, 0])
    box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);
}

// make pump housing body
module peristaltic_pump_body(size) {
  color("red")
    box_body(size, length = size[2], vent_width = 3);
}

// standard particle photon holder board cutout
// NOTE: the power part does not behave well with rotations
module stepper_board(thickness, location = [0,0,0], rotation = [0,0,0], with_RJ45 = true, show = false) {
  screws = ["M3", 36.7, 20.6, 0.2];
  board = [80, 48, 1.6, 10];
  rj45 = [15.5, 16, 16];
  // fixme: locations only support normal 90 rotation at the moment (do the math properly)
  rj45_offset = [6.4, 1.2];
  rj45_location = rotation[2] == 90 ?
    [-board[1]/2 + rj45[1]/2 - rj45_offset[1], -board[0]/2 + rj45[0]/2 + rj45_offset[0], 0] :
    [board[0]/2 - rj45[0]/2 - rj45_offset[0], -board[1]/2 + rj45[1]/2 - rj45_offset[1], 0];

  // arrangment
  if (with_RJ45) {
    panel_attachment(thickness, screws, board, location, rotation, show)
    panel_cut_out(thickness, rj45, location + rj45_location, rotation, show)
    children(0);
  } else {
    panel_attachment(thickness, screws, board, location, rotation, show)
    children(0);
  }

}

// make pump housing back
module peristaltic_pump_back(size) {
  thickness = 4;
  color("yellow")
    //wm_stepper_pump(location = [0, -33, 0], show_pump=show_pump)
    //LCD(type = "20x4", location = [0, 30, 0])
    stepper_board(thickness = thickness, location = [-5, 30, 0], with_RJ45 = true, show = show)
    power_jack(thickness = thickness, location = [45, 13, 0], show = show)
    box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);
}


// render full
show = false;
size = [120, 140, 80];

!peristaltic_pump_front(size, show);
translate([0, 0, 30]) peristaltic_pump_body(size);
translate([0, 0, 120]) peristaltic_pump_back(size);
