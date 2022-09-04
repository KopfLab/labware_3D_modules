use <utils.scad>;
use <screws.scad>;
use <lcd.scad>;
use <panel_mounts.scad>;

e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

show = false;
thickness = 3;
size = [115, 75, 75];

// dimensions
$walls = 3;
$adapter_height = 8;
$adapter_width = 6;
$rail_width = 2;
$vents = 5;
$vent_width = 3;
$lipo_cage = [11, 52, 40];
$lipo_cage_walls = 1;
$microusb_port = 12;

// general settings
$vertical_stretch = 0.2; // vertical extra stretch
$material_tolerance = 0.025; // t-glase
$hexnut_z_tolerance = 0.1 + 2 * $material_tolerance; // extra depth cut out to fit hex nut
$screw_hole_tolerance = 0.1 + 2 * $material_tolerance; // tolerance for screw holes

// @param base_plane (which layer should be oriented at the base)
module box_base(size, walls = $walls, adapter_height = $adapter_height, adapter_width = $adapter_width) {
  union() {
    // walls
    difference() {
      xy_center_cube(size);
      translate([walls, walls, walls]) xy_center_cube(size);
      // base attachment screws
      for (x = [-1, 0, 1])
        for (z = [-1, 1])
          translate([x * size[0]/3, -size[1]/2 + walls, 0.55 * size[2] + x * z * size[2]/5])
          rotate([90, 90, 0])
          translate([0, 0, -e])
          machine_screw("M4", length = walls + 2e, stretch = 2 * $vertical_stretch, tolerance = $screw_hole_tolerance);
    }
    // lipo battery cage - don't use, can be too far away from the connector and makes the print messy
    /*
    translate([-(size[0] - $lipo_cage[0] - $lipo_cage_walls)/2 + walls, -(size[1] - $lipo_cage[1] - $lipo_cage_walls)/2 + walls, walls])
    difference() {
      xy_center_cube($lipo_cage + [$lipo_cage_walls, $lipo_cage_walls, 0]);
      translate([-$lipo_cage_walls/2, -$lipo_cage_walls/2, 0])
        xy_center_cube($lipo_cage + [e, e, e]);
    }
    */
    // adapters
    difference() {
      // adapter rails
      union() {
        translate([-walls/2, (size[1] - $rail_width - 2 * walls)/2, walls])
          xy_center_cube([size[0] - walls, $rail_width, adapter_height]);
        translate([(size[0] - $rail_width - 2 * walls)/2, -walls/2, walls])
          xy_center_cube([$rail_width, size[1] - walls, adapter_height]);
        for(x = [-1, 1])
          translate([x * (size[0] - 2 * adapter_height - 2 * walls)/2, (size[1] - adapter_width)/2 - walls, walls])
            xy_center_cube([2 * adapter_height, adapter_width, adapter_height]);
        for(y = [-1, 1])
          translate([(size[0] - adapter_width)/2 - walls, y * (size[1] - 2 * adapter_height - 2 * walls)/2, walls])
            xy_center_cube([adapter_width, 2 * adapter_height, adapter_height]);
      }
      // adapters
      box_adapters(size = size, walls = walls, adapter_height = adapter_height);
    }
  }
}

// lid with lcd screen
module box_top(size, walls = $walls, adapter_height = $adapter_height, vents = $vents, vent_width = $vent_width) {
  difference() {
    // base block
    translate([walls/2, walls/2, walls]) xy_center_cube(size - [walls, walls, walls]);
    // main cutout
    translate([-walls/2, -walls/2, 0]) xy_center_cube(size - [walls, walls, walls]);
    // adapter holes
    box_adapters(size = size, walls = walls, adapter_height = adapter_height, turn_y = 90, stretch_x = 0);
    // vents
    vent_list = [for (i = [1 : 1 : vents]) i];
    vent_spacing = size[0]/(vents + 1);
    for(x = vent_list)
      translate([0, 0, size[2] - walls])
        translate([-size[0]/2 + x*vent_spacing, 0, -e])
          union() {
            xy_center_cube([vent_width, 0.7 * size[1], walls + 2e]);
            for (y = [-1, 1])
              translate([0, y * (0.7 * size[1])/2, 0])
                cylinder(d = vent_width, h = walls + 2e);
          }
     // micro usb port to reach microcontroller
     translate([size[0]/2 - walls - e, -size[1]/2 + 39.2, 24.2])
     rotate([0, 90, 0])
     union() {
       for (y = [-1, 1]) translate([0, y * $microusb_port/2, 0])
         cylinder(d = $microusb_port, h = walls + 2e);
       xy_center_cube([$microusb_port, $microusb_port, walls + 2e]);
     }
  }
}

// attachment screw adapters
module box_adapters(size, walls = $walls, adapter_height = $adapter_height, adapter_width = $adapter_width, stretch_x = $vertical_stretch, stretch_y = $vertical_stretch, turn_x = 0, turn_y = 0) {
  // adapter holes
  for (x = [-1, 1])
    //translate([x * (size[0] - adapter_height - 4 * walls)/2, (size[1] - walls - 4 * walls + e)/2, walls])
      //rotate([0, 0, 90])
        //translate([walls/2, 0, adapter_height/2])
        translate([x * (size[0] - 3 * adapter_height)/2, size[1]/2 - walls - adapter_width, walls + adapter_height/2])
          rotate([-90, 90, 0])
            box_adapter_nut_and_screw(walls = walls, adapter_height = adapter_height, adapter_width = adapter_width, vertical_stretch = stretch_x, turn = turn_x);
  for (y = [-1, 1])
    //translate([(size[0] - walls - 4 * walls + e)/2, y * (size[1] - adapter_height - 4 * walls)/2, walls])
    //  translate([walls/2, 0, adapter_height/2])
      translate([size[0]/2 - walls - adapter_width, y * (size[1] - 3 * adapter_height)/2, walls + adapter_height/2])
        rotate([0, 90, 0])
          box_adapter_nut_and_screw(walls = walls, adapter_height = adapter_height, adapter_width = adapter_width, vertical_stretch = stretch_y, turn = turn_y);
}

module box_adapter_nut_and_screw(walls = $walls, adapter_height = $adapter_height, adapter_width = $adapter_width, vertical_stretch = $vertical_stretch, turn = 0) {
  // nut and screw for adapters
  union() {
    translate([0, 0, (adapter_width - get_hexnut("M3")[2])/2])
    hexnut("M3", screw_hole = false, z_plus = $hexnut_z_tolerance, tolerance = $material_tolerance, stretch = vertical_stretch, slot = -adapter_height);
    translate([0, 0, -e])
    rotate([0, 0, turn])
    machine_screw("M3", length = walls + adapter_width + 2e, tolerance = $screw_hole_tolerance, stretch = vertical_stretch, invert_countersink = true);
  }
}

// standard swiss board cutout
// rotations don't work!
module swiss_board(thickness, location = [0,0,0], show = false) {
  rotation = [0,0,0];
  screws = ["M3", 28, 16.5, 0.2];
  board = [64, 42, 1.6, 6];
  antenna = [9, 3, 15];
  antenna_location = [-15, board[1]/2 - antenna[1]/2 + 3, 0];

  // ll = max xy distance of the cut out relative to the lower left corner of the pcb
  // up = max xy distance of the cut out relative to the upper right corner of the pcb
  function get_cutout(ll, ur, tolerance = [1, 1]) =
    [ll[0] + ur[0] - board[0] + tolerance[0], ll[1] + ur[1] - board[1] + tolerance[1], board[3] + thickness];
  function get_pos(ll, ur) =
    [(ll[0] - ur[0])/2, (ll[1] - ur[1])/2, 0];

  signal_top_ll= [48.9, 41.8]; signal_top_ur= [29.7, 7.2];
  signal_bot_ll = [55.9, 6.2]; signal_bot_ur = [29.7, 42.6];
  power1_ll = [7.3, 12.4]; power1_ur = [64.3, 36.2];
  power2_ll = [16.3, 12.4]; power2_ur = [55.3, 36.2];
  mosfet_ll = [28.9, 24.9]; mosfet_ur = [42.8, 24.1];

  // arrangment
  panel_attachment(thickness, screws, board, location, rotation, show)
  panel_cut_out(cutout = get_cutout(signal_top_ll, signal_top_ur), location = location + get_pos(signal_top_ll, signal_top_ur), rotation = rotation, show = show)
  panel_cut_out(cutout = get_cutout(signal_bot_ll, signal_bot_ur), location = location + get_pos(signal_bot_ll, signal_bot_ur), rotation = rotation, show = show)
  panel_cut_out(cutout = get_cutout(power1_ll, power1_ur), location = location + get_pos(power1_ll, power1_ur), rotation = rotation, show = show)
  panel_cut_out(cutout = get_cutout(power2_ll, power2_ur), location = location + get_pos(power2_ll, power2_ur), rotation = rotation, show = show)
  panel_cut_out(cutout = get_cutout(mosfet_ll, mosfet_ur), location = location + get_pos(mosfet_ll, mosfet_ur), rotation = rotation, show = show)
  panel_cut_out(cutout = antenna, location = location + antenna_location, rotation = rotation, show = show)
  children(0);

}


// base
rotate([90, 0, 0])
swiss_board(thickness = thickness, location = [15, 2, 0], show = show)
DB9_serial_port(thickness = thickness, location = [-4, -29, 0], show = show)
DB9_serial_port(thickness = thickness, location = [32, -29, 0], show = show)
box_base(size = size);

// lid
translate([0, -30, 30])
rotate([90, 0, 0])
color("green")
!LCD(type = "20x4SF", location = [0, size[1]/2, size[2]/2 + 4.5], rotation = [90, 0, 0])
box_top(size = size);
