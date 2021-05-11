
use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders
$render_threads=false; // turning thread rendering on/off (renders very slowly if true)

// ring adapters (called from other modules)
// @param vial_diameter diameter of the vial/bottle
// @param holder_wall thickness of the holder wall
// @param adapter_height height of adapter
// @param adapter_slot_width how wide the adapter slots are
// @param angle_offset rotation offset of the adapater positions (0 by default)
module ring_adapters(vial_diameter, holder_wall, adapter_height, adapter_slot_width) {
  total_diameter = vial_diameter + 2 * holder_wall;
  height = (vial_diameter / 2 + holder_wall) * adapter_height / holder_wall;
  for (angle = [30, 150, 270]) {
    rotate([0, 0, angle])
    difference() {
      cylinder(h = height, d1 = total_diameter, d2 = 0);
      translate([0, 0, adapter_height]) cylinder(h = height, d = total_diameter);
      for (x = [-1, 1]) {
        translate([0, x * (total_diameter + adapter_slot_width)/2, 0])
        xy_center_cube([total_diameter, total_diameter, adapter_height + e]);
      }
    }
  }
}

// generate stirred bottle holder
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param bottom_thickness thickness of the base
// @param stirrer_hole_diameter diameter of the stirrer hole
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module stirred_bottle_holder(vial_diameter, base_height, bottom_thickness = 4, stirrer_hole_diameter = 25, adapter_height = 10) {

  echo(str("INFO: rendering stirred bottle holder for ", vial_diameter, "mm tubes..."));

  holder_wall = 8;  // thickness of the holder wall around the vial
  adapter_slot_width = 10; // standard width of the attachment slot
  total_diameter = vial_diameter + 2 * holder_wall; // total diameter

  stand_feet = [12, 12, 6]; // length, width, height of support feet
  stand_feet_support = 8; // height of support for the stand feet

  stepper_width = 42; // +/- 0.1
  attachment_screw_depth = 5;

  difference() {
    union() {
      // vial holder
      cylinder(h = base_height, d = total_diameter);

      // top adapters
      translate([0, 0, base_height])
      ring_adapters(
        vial_diameter, holder_wall, adapter_height,
        adapter_slot_width =  adapter_slot_width - 0.2 // minus tolerance for good fit
      );

      // support feet
      total_diameter_w_feet = total_diameter + 2 * stand_feet[1];
      for (x = [0, 120, 240]) {
        rotate([0, 0, x])
        difference() {
          height = (total_diameter_w_feet) * (stand_feet_support) / (holder_wall + stand_feet[1]);
          union() {
            cylinder(h = stand_feet[2], d = total_diameter_w_feet);
            translate([0, 0, stand_feet[2]])
              cylinder(h = height, d1 = total_diameter_w_feet, d2 = 0);
          }
          translate([0, 0, base_height-e]) cylinder(h = height, d = total_diameter_w_feet+2e);
          for (x = [-1, 1]) {
            translate([0, x * (total_diameter_w_feet + stand_feet[1])/2, -e])
            xy_center_cube([total_diameter_w_feet + 2e, total_diameter_w_feet, stand_feet[2] + height + 2e]);
          }
          translate([-total_diameter_w_feet/2, 0, -e])
            xy_center_cube([total_diameter_w_feet, total_diameter_w_feet, stand_feet[2] + height + 2e]);
          translate([(total_diameter_w_feet - stand_feet[1])/2, 0, -e])
            machine_screw(name = "M3", countersink = false, length = stand_feet[2] + height + 2e);
          translate([(total_diameter_w_feet - stand_feet[1])/2, 0, stand_feet[2]]) cylinder(h = height, d = 6);
        }
      }
    }

    // center hole cutout
    translate([0, 0, bottom_thickness])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter);
      translate([0, 0, -e])
        cylinder(h = base_height + adapter_height + 2e, d = stirrer_hole_diameter);

    // motor adapter screws
    for (x = [-1, 1]) {
      translate([x * stepper_width/2, 0, bottom_thickness + e])
      mirror ([0, 0, 1])
      machine_screw(name = "M3", length = bottom_thickness + 2e);
    }

    // attachment screws (using M4 although it's for M3 screws for low quality printers)
    // this is what takes very long to render if render_threads = true
    for (x = [0:5]) {
      rotate([0, 0, x * 60])
        translate([vial_diameter/2 + holder_wall/2, 0, base_height - attachment_screw_depth])
          threaded_machine_screw(name = "M4", length = attachment_screw_depth + e);
    }

  }

}

// magnet holder for the stepper stirrer
// design inspired by flexostat
// @param holder_height total thickness of the magnet holder
module stirrer_magnet_holder(holder_height = 10.0, shaft_diameter = 3.3) {

  holder_diameter = 21.0;
  magnet_diameter = 6.5;
  magnet_height = 3.2;
  magnet_offset = 5.8;
  shaft_height = holder_height - 2.0;

  difference() {
    cylinder(h = holder_height, d = holder_diameter);
    for (x = [-1, 1]) {
      translate([x * magnet_offset, 0, holder_height - magnet_height])
        cylinder(h = magnet_height + e, d = magnet_diameter);
    }
    translate([0, 0, -e])
      cylinder(h = shaft_height + e, d = shaft_diameter);
  }
}

// generate ring for the light sensors
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module light_sensor_ring(vial_diameter, base_height = 13, adapter_height = 10) {

  echo(str("INFO: rendering light sensor ring for ", vial_diameter, "mm tubes..."));

  holder_wall = 8;  // thickness of the holder wall around the vial
  adapter_rim = 4; // thickness of the adapter rim
  adapter_slot_width = 10; // standard width of the attachment slot
  vial_cutout_extra = 0.4; // slightly larger cutout for easier fit
  total_diameter = vial_diameter + 2 * holder_wall; // total diameter

  opt_board_cutout = [16.1, 1.7, 11]; // cutout for OPT board
  opt_cutout = [10.0, 4.8, opt_board_cutout[2]]; // cutout for OPT chip
  opt_pin_depth = 2; // space to leave for the OPT pins behind the board

  light_tunnel_diameter = 4; // photodiode area cross section ~ 3.35mm
  light_tunnel_opt_base_offset = 5.5; // center of sensor from base of sensor cutout
  light_tunnel_length_to_main_sensor = 4; // how far from tunnel wall is sensor located
  light_tunnel_length_to_side_sensor = 8; // how far from glass is the side sensor?
  light_tunnel_length_to_glass = 15; // how far from tunnel wall is cover glass located
  light_tunnel_length_to_led = 5; // how far from glass is led

  cover_slip = [12.4, 12.4, .3]; // dimensions of cover slip

  led_diameter = 4.9; // includes tolerance
  led_height = 5.0; // total Led height
  led_back_diameter = 5.6; // back plate diameter
  led_back_height = 0.7; // back plate thickness
  led_pin_depth = 2; // space to leave for LED pins
  led_guide = [1, 1, led_back_height]; // guide pin width, length and thickness
  led_max_diameter = led_back_diameter + 2 * led_guide[1];

  base_right = [light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height + led_pin_depth - 2e + 5, 26, base_height];
  base_right_location = [vial_diameter/2 + base_right[0]/2 - 5, -6, 0];
  base_left = [15, 20, base_height];
  base_left_location = [-vial_diameter/2 - base_left[0]/2, 0, 0];
  light_tunnel_z = base_height - opt_cutout[2] + light_tunnel_opt_base_offset;

  difference() {
    union() {
      // vial holder
      cylinder(h = base_height, d = total_diameter);

      // top adapters
      translate([0, 0, base_height])
      ring_adapters(
        vial_diameter, holder_wall, adapter_height,
        adapter_slot_width =  adapter_slot_width - 0.2 // minus tolerance for good fit
      );

      // base right
      translate(base_right_location) xy_center_cube(base_right);

      // base left
      translate(base_left_location) xy_center_cube(base_left);
    }

    // LED cutout
    color("green")
    scale([1,1,1.03]) // 3% z-stretch
    translate([vial_diameter/2 + light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height, -e, light_tunnel_z])
    rotate([0, -90, 0])
    translate([0, 0, -led_pin_depth])
    union() {
      difference() {
        cylinder(h = led_guide[2] + led_pin_depth, d = led_max_diameter);
        for (x = [-1, 1]) {
          translate([led_max_diameter/2, x * (led_max_diameter/2 + led_guide[0]/2 + e), - e])
              xy_center_cube([led_max_diameter, led_max_diameter, led_pin_depth + e]);
        }
        translate([-led_max_diameter/2 + e, 0, -e])
            xy_center_cube([led_max_diameter, led_max_diameter, led_guide[2] + led_pin_depth + 2e]);
      }
      cylinder(h = led_pin_depth + led_back_height, d = led_back_diameter);
      cylinder(h = led_height + led_pin_depth, d = led_diameter);
      // set screw
      for (x = [0, -120]) {
        translate([0, 0, led_pin_depth + led_height/2]) rotate([x, 90, 0])
        threaded_machine_screw(name = "M3", length = 20 + 2e);
      }
    }
    // cover slip cutout
    translate([vial_diameter/2 + light_tunnel_length_to_glass, 0, base_height - opt_cutout[2]])
      rotate([0, 0, -45])
      xy_center_cube([cover_slip[2], cover_slip[1], opt_cutout[2] + 2e]);

    // light tunnels (do they need distortion?)
    //// main
    translate([-(vial_diameter + base_left[0] + base_right[0])/2 - e, 0, light_tunnel_z])
      rotate([0, 90, 0])
      cylinder(h = vial_diameter + base_right[0] + base_left[0] + 2e, d = light_tunnel_diameter);
    //// side
    translate([vial_diameter/2 + light_tunnel_length_to_glass, -e, light_tunnel_z])
      rotate([90, 0, 0])
      cylinder(h = base_right[1] + 2e, d = light_tunnel_diameter);

    // opt & board cutout
    //// main
    translate([-vial_diameter/2 - light_tunnel_length_to_main_sensor, 0, base_height - opt_board_cutout[2]])
    union() {
      translate([-opt_cutout[1]/2, 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_cutout[1] + 2e, opt_cutout[0], opt_cutout[2] + 2e]);
      translate([-opt_board_cutout[1]/2 - opt_cutout[1], 0, 0])
        xy_center_cube([opt_board_cutout[1], opt_board_cutout[0], opt_board_cutout[2] + 2e]);
      translate([-opt_pin_depth/2 - opt_cutout[1] - opt_board_cutout[1], 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_pin_depth + 2e, opt_cutout[0], opt_cutout[2] + 2e]);
    };
    //// side
    translate([vial_diameter/2 + light_tunnel_length_to_glass, -light_tunnel_length_to_side_sensor, base_height - opt_board_cutout[2]])
    rotate([0, 0, 90])
    union() {
      translate([-opt_cutout[1]/2, 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_cutout[1] + 2e, opt_cutout[0], opt_cutout[2] + 2e]);
      translate([-opt_board_cutout[1]/2 - opt_cutout[1], 0, 0])
        xy_center_cube([opt_board_cutout[1], opt_board_cutout[0], opt_board_cutout[2] + 2e]);
      translate([-opt_pin_depth/2 - opt_cutout[1] - opt_board_cutout[1], 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_pin_depth + 2e, opt_cutout[0], opt_cutout[2] + 2e]);
    };

    // center hole cutout (slightly bigger than stirred bottle holder base for easier fit)
    translate([0, 0, -e])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter + vial_cutout_extra);

    // bottom adapter cutouts
    translate([0, 0, -e])
    ring_adapters(
      vial_diameter = vial_diameter + 0.2, // plus tolerance for good fit
      holder_wall = holder_wall,
      adapter_height = adapter_height + 0.2, // plus tolerance for good fit
      adapter_slot_width =  adapter_slot_width + 0.2 // plus tolerance for good fit
    );

    // attachment screw holes
    for (x = [1, 2, 4, 5]) {
      rotate([0, 0, x * 60])
        translate([vial_diameter/2 + holder_wall/2, 0, base_height + e])
          rotate([0, 180, 0])
          machine_screw(name = "M3", countersink=true, length = base_height + adapter_rim + 2e);
    }

  }

}

/* render all pieces */

// stirred bottle holder for 100ml bottles
// may not render in SCAD GUI, to render by command line (may still take a while), run:
// openscad -o stirred_bottle_holder_100mL.stl stirred_bottle_holder.scad

// FINAL stirred bottle holders (a tiny bit more tolerance)
color("green")
stirred_bottle_holder(vial_diameter = 56.1, base_height = 20);

// magnet holder
translate([0, 0, -6])
color("pink")
stirrer_magnet_holder(10, 3.3);

// light sensor ring
translate([0, 0, 40])
!color("teal")
light_sensor_ring(vial_diameter = 56.1);

module distribution_board_holder() {

}
distribution_board_holder();
