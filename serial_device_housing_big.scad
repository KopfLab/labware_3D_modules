use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

show = false;
thickness = 4;
size = [120, 80, 80];

// back panel
color("gray")
photon_board(thickness = thickness, location = [-18, 10, 0], with_RJ45 = true, show = show)
DB9_serial_port(thickness = thickness, location = [0, -21, 0], show = show)
MicroUSB_port(thickness = thickness, location = [31, -21, 0], show = show)
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);

// body
translate([0, 0, 30])
color("green")
box_body(size, length = size[2], vent_width = 3);

// front panel
translate([0, 0, 140])
mirror([0, 0, 1])
color("red")
LCD(type = "20x4", location = [0, 0, 0])
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);
