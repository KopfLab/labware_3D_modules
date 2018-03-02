use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

show = true;
thickness = 5;
size = [100, 60, 50];

// back panel
color("gray")
photon_board(thickness = thickness, location = [9, 0, 0], with_RJ45 = true, show = show)
DB9_serial_port(thickness = thickness, location = [-32, 0, 0], rotation = [0, 0, 90], show = show)
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);

// body
translate([0, 0, 5])
color("green")
MicroUSB_port(thickness = thickness, location = [size[0]/2, 0, 25], rotation = [270, 0, 90], port_only = true, show = show)
box_body(size, length = size[2], vent_width = 3, vents = 3, vents_both_sides = false);

// front panel
translate([0, 0, 60])
mirror([0, 0, 1])
color("red")
LCD(type = "16x2", location = [0, 0, 0])
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);
