use <utils.scad>;
use <screws.scad>;
use <box.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;




show = true;
color("green")
  AC_power(thickness = 5, location = [45, -25, 0], rotation = [0, 0, 90], show = show)
  relay(thickness = 5, location = [5, 20, 0], rotation = [0, 0, 90], show = show)
  AC_DC_converter(thickness = 5, location = [-18, -33, 0], show = show)
  photon_board(thickness = 5, location = [-40, 18, 0], rotation = [0, 0, 90], show = show)
  box_lid([140, 120], thickness = 5, feet = 2, feet_params = [20, 0.3, false]);
