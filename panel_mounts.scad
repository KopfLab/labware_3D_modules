// general attachment pieces for panels
use <utils.scad>;
use <screws.scad>;

// HELPER MODULES //

// standard attachment for a rectangular module affixed on top of a board
// @param thickness how thick base board is
// @param screws array of screw parameters (type, location x, location y, tolerance)
// @param block array of attachment block parameters (length, width, thickness, [offset from base board])
// @param location central point of the cutout
// @param rotation how much to rotate
// @param show whether to show cube (not intended for printing)
module panel_attachment (thickness, screws, block, location = [0,0,0], rotation = [0,0,0], show = false) {
  // parameters
  z_plus = 0.1; // how much thicker to make cutouts in z

  difference() {
    show_block(block, location + [0, 0, thickness + block[3]], rotation, show)
    children(0);

    translate(location)
      rotate(rotation) {
        // screw holes
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*screws[1], y*screws[2], 0])
              machine_screw(screws[0], thickness+block[0]+block[1], tolerance = screws[3], z_plus = z_plus);
      }
  }
}

// just a show block (not intended for printing, just for showing location)
// @param block array of cube parameters (length, width, thickness, offset from base board)
module show_block (block, location, rotation, show = false) {
  union() {
    children(0);
    if (show) {
      // cube outline (not printed)
      translate(location) rotate(rotation)
        translate([0, 0, block[3]])
          #xy_center_cube([block[0], block[1], block[2]]);
    }
  }
}

// ATTACHMENTS //

// standard particle photon holder board cutout
// NOTE: the power part does not behave well with rotations
module photon_board(thickness, location = [0,0,0], rotation = [0,0,0], show = false) {
  screws = ["M3", 28, 16.5, 0.2];
  board = [64, 40, 1.6, 6.35];
  panel_attachment(thickness, screws, board, location, rotation, show)
  children(0);
}

// particle board
translate([-80, 80, 0])
photon_board(thickness = 5, show = true) xy_center_cube([80, 60, 5]);


// 85-240V AC to 5V 1A DC converter, enclosed (from DigiKey)
// https://www.digikey.com/products/en?keywords=102-2656-ND
module AC_DC_converter(thickness, location = [0,0,0], rotation = [0,0,0], show = false){
  screws = ["M3", 30.8, 11.5, 0.2];
  board = [76, 31.5, 23.96, 0];
  panel_attachment(thickness, screws, board, location, rotation, show)
  children(0);
}

// AC DC converter
translate([80, 80, 0])
AC_DC_converter(thickness = 5, show = true) xy_center_cube([100, 60, 5]);


// auber 25A solid state relay
// http://www.auberins.com/index.php?main_page=product_info&products_id=9
module relay(thickness, location = [0,0,0], rotation=[0,0,0], show = false) {
  screws = ["M4", 23.8, 0, 0.2];
  relay = [58, 44, 32, 0];
  panel_attachment(thickness, screws, relay, location, rotation, show)
  children(0);
}

// relay
translate([80, -100, 0]) color("green")
relay(thickness = 5, show = true) xy_center_cube([100, 80, 5]);


// auber solid 25A state relay with externally mounted heatsink
// relay: http://www.auberins.com/index.php?main_page=product_info&products_id=9
// heat sink: http://www.auberins.com/index.php?main_page=product_info&cPath=2_48&products_id=244
module relay_sink(thickness, location = [0,0,0], rotation=[0,0,0], show = false) {
  z_plus = 0.1; // how much thicker to make cutouts in z
  relay = [58, 44, 32, 0];
  cutout = [70, 55];
  screws = ["M4", 45, 39.75, 0.2];
  heat_sink = [100, 90, 30, -thickness];
  show_block (relay, location, rotation, show)
  panel_attachment(thickness, screws, heat_sink, location- [0, 0, heat_sink[2]], rotation, show)
  difference() {
    children(0);
    translate(location) rotate(rotation)
      translate([0, 0, -z_plus]) xy_center_cube([cutout[0], cutout[1], thickness+2*z_plus]);
  }
}

// relay sink
translate([-80, -100, 0]) color("green")
relay_sink(thickness = 5, show = true) xy_center_cube([120, 100, 5]);

// standard snap-in cutout for a panel
// @param thickness how thick base board is
// @param block dimensions of snap in cutout (length, width, thickness)
// @param face dimensions of the face block  (length, width, thickness)
// @param clips dimensions of the gaps for clips (location x, location y, length, width, thickness)
// @param location central point of the cutout
// @param rotation how much to rotate
// @param show whether to show cube (not intended for printing)
// @param tolerance how much tolerance to add to the snap in cutout
module panel_snap_in (thickness, cutout, face, clips, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  z_plus = 0.1; // how much thicker to make cutouts in z
  show_block (face, location - [0, 0, face[2]], rotation, show)
  show_block (cutout + [2*tolerance, 2*tolerance, 0], location, rotation, show)
  difference() {
    children(0);

    translate(location) rotate(rotation) {
      translate([0, 0, -z_plus])
        xy_center_cube([cutout[0], cutout[1], cutout[2]+2*z_plus]);
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*clips[0], y*clips[1], thickness - clips[4]])
              xy_center_cube([clips[2], clips[3], clips[4] + 2 * z_plus]);
    };

  }
}

// standard screw in for a panel
// @param thickness how thick base board is
// @param block dimensions of snap in cutout (length, width, thickness)
// @param face dimensions of the face block  (length, width, thickness)
// @param screws array of screw parameters (type, location x, location y, tolerance)
// @param location central point of the cutout
// @param rotation how much to rotate
// @param show whether to show cube (not intended for printing)
// @param tolerance how much tolerance to add to the snap in cutout
module panel_screw_in (thickness, cutout, face, screws, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  z_plus = 0.1; // how much thicker to make cutouts in z
  difference() {
    show_block (face, location - [0, 0, face[2]], rotation, show)
    show_block (cutout + [2*tolerance, 2*tolerance, 0], location, rotation, show)
    children(0);

    translate(location) rotate(rotation) {
      translate([0, 0, -z_plus])
        xy_center_cube([cutout[0], cutout[1], cutout[2]+2*z_plus]);

        // screw holes
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*screws[1], y*screws[2], -face[2]])
              machine_screw(screws[0], thickness+face[2], countersink = false, tolerance = screws[3], z_plus = z_plus);
    };
  }
}

// schurter AC power module with fuse and scwitch (rated for 10A)
// https://www.digikey.com/products/en?keywords=%09486-1965-ND
module AC_power (thickness, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  cutout = [46.9, 27.9, 30.35];
  face = [50, 30.5, 2.5];
  clips = [42.5/2, 27.8/2, 4, 3, 2];
  clips = [42.5/2, cutout[1]/2 + 1.3, 4.5, 3.2, 3.5];
  panel_snap_in(thickness, cutout, face, clips, location, rotation, show, tolerance)
  children(0);
}

// power module
color("blue") AC_power(thickness = 5, show = true) xy_center_cube([120, 80, 5]);

module AC_outlet (thickness, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  cutout = [25.1, 21.65, 24.75];
  face = [26.87, 26.95, 3.56];
  clips = [cutout[0]/2 + 2.9/2, 0, 3, 9.8, 3.5];
  panel_snap_in(thickness, cutout, face, clips, location, rotation, show, tolerance)
  children(0);
}

// NULSOM DB9 RS232 serial port
// cutoff such that connector can be vertically flipped (i.e. 5 pins up or 4 pins up)
// https://www.amazon.com/Ultra-Compact-RS232-Converter-Male/dp/B00OPU2QJ4
module DB9_serial_port (thickness, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  cutout = [19.45, 11.0, 18.35];
  face = [30.85, 12.55, 5.43];
  screws = ["M3", 12.45, 0, 0.3];
  panel_screw_in(thickness, cutout, face, screws, location, rotation, show, tolerance)
  children(0);
}

// Adafruit MicroUSB Port
// https://www.adafruit.com/product/3258
// Note: could consider making the outside of these screws countersunk
module MicroUSB_port (thickness, location = [0,0,0], rotation=[0,0,0], show = false, tolerance = 0.15) {
  cutout = [11.0, 8.0, 22.0];
  face = [25.0, 10.0, 5.43];
  screws = ["4-40", 9, 0, 0.3];
  panel_screw_in(thickness, cutout, face, screws, location, rotation, show, tolerance)
  children(0);
}

// Adafruit RJ45/Ethernet port
// https://www.adafruit.com/product/909
module RJ45_port (thickness, location = [0,0,0], rotation = [0,0,0], show = false, tolerance = 0.15) {
  cutout = [20, 20, 28.0]; // could use some refinement
  face = [33.0, 20.0, 4]; // could use some refinement
  screws = ["4-40", 12.5, 0, 0.3];
  panel_screw_in(thickness, cutout, face, screws, location, rotation, show, tolerance)
  children(0);
}
