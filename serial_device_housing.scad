use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

show = true;
thickness = 5;
size = [120, 80];

// back panel
!color("gray")
photon_board(thickness = thickness, location = [-18, 10, 0], rotation = [0, 0, 0], show = show)
DB9_serial_port(thickness = thickness, location = [0, -21, 0], show = show)
MicroUSB_port(thickness = thickness, location = [31, -21, 0], show = show)
RJ45_port(thickness = thickness, location = [-35, -21, 0], show = show)
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);


// body
translate([0, 0, 5])
color("green")
box_body(size, length = 80);

// front panel
translate([0, 0, 90])
mirror([0, 0, 1])
color("red")
LCD(type = "20x4", location = [0, 0, 0])
box_lid(size, thickness = thickness, feet = 3, feet_params = [8, 0.3, true]);
