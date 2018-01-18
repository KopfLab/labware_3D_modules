use <utils.scad>;
use <screws.scad>;
use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

show = false;
thickness = 5;
size = [140, 120];

// back panel
color("green")
DB9_serial_port(thickness = thickness, location = [45, 40, 0], rotation = [0,0,0], show = show)
AC_outlet(thickness = thickness, location = [45, 17, 0], rotation = [0,0,0], show = show)
AC_power(thickness = thickness, location = [45, -25, 0], rotation = [0, 0, 90], show = show)
relay(thickness = thickness, location = [5, 20, 0], rotation = [0, 0, 90], show = show)
AC_DC_converter(thickness = thickness, location = [-18, -33, 0], show = show)
photon_board(thickness = thickness, location = [-40, 18, 0], rotation = [0, 0, 90], show = show)
box_lid(size, thickness = thickness, feet = 2, feet_params = [20, 0.3, false]);
