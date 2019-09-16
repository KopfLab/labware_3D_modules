use <utils.scad>;
use <screws.scad>;

module light_sensor_base(fn = 50) {

  vial_diameter = 55.5; // 100mL bottles
  holder_wall = 5;  // thickness of the holder wall around the vial
  adapter_height = 5; // height of the adapter rim
  adapter_rim = 2.5; // thickness of the adapter rim
  adapter_slot_width = 9; // width of the attachment slot

  opt_board_cutout = [15.90, 1.7, 11]; // cutout for OPT board
  opt_cutout = [10.0, 6.0, opt_board_cutout[2]]; // cutout for OPT chip
  opt_pin_depth = 2; // space to leave for the OPT pins behind the board

  light_tunnel_diameter = 4; // photodiode area cross section ~ 3.35mm
  light_tunnel_opt_base_offset = 5.5; // center of sensor from base of sensor cutout
  light_tunnel_length_to_main_sensor = 5; // how far from tunnel wall is sensor located
  light_tunnel_length_to_side_sensor = 8; // how far from glass is the side sensor?
  light_tunnel_length_to_glass = 10; // how far from tunnel wall is cover glass located
  light_tunnel_length_to_led = 5; // how far from glass is led

  cover_slip = [12.2, 12.2, .3]; // dimensions of cover slip

  led_diameter = 4.9; // includes tolerance
  led_height = 5.0; // total Led height
  led_back_diameter = 5.6; // back plate diameter
  led_back_height = 0.7; // back plate thickness
  led_pin_depth = 2; // space to leave for LED pins

  cutout_plus = 0.01; // how much thicker to make cutouts
  base = [vial_diameter + 2, 40, opt_board_cutout[2] + 2]; // holder base
  base_right = [light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height + led_pin_depth - cutout_plus + 5, 27, base[2]];
  base_right_location = [vial_diameter/2 + base_right[0]/2 - 5, -6, 0];
  base_left = [17, 19, base[2]];
  base_left_location = [-vial_diameter/2 - base_left[0]/2, 0, 0];
  light_tunnel_z = base[2] - opt_cutout[2] + light_tunnel_opt_base_offset;

  difference() {
    union() {
      // vial holder
      cylinder(h = base[2] + adapter_height, d = vial_diameter + 2 * holder_wall, $fn = fn);

      // base right
      translate(base_right_location) xy_center_cube(base_right);

      // base left
      translate(base_left_location) xy_center_cube(base_left);
    }

    // led cutout
    translate([vial_diameter/2 + light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height, -cutout_plus/2, light_tunnel_z])
    rotate([0, -90, 0])
    union() {
      cylinder(h = led_back_height, d = led_back_diameter, $fn = fn);
      translate([0, 0, -led_pin_depth]) cylinder(h = led_height + led_pin_depth, d = led_diameter, $fn = fn);
      // top access
      translate([(base[2] - light_tunnel_opt_base_offset)/2, 0, 0])
        xy_center_cube([base[2] - light_tunnel_opt_base_offset, led_back_diameter, led_back_height]);
      translate([(base[2] - light_tunnel_opt_base_offset)/2, 0, -led_pin_depth])
        xy_center_cube([base[2] - light_tunnel_opt_base_offset, led_diameter, led_height + led_pin_depth]);
    }

    // cover slip cutout
    translate([vial_diameter/2 + light_tunnel_length_to_glass, 0, base[2] - opt_cutout[2]])
      rotate([0, 0, -45])
      xy_center_cube([cover_slip[2], cover_slip[1], opt_cutout[2] + cutout_plus]);

    // light tunnels (do they need distortion?)
    //// main
    translate([-(base[0] + base_left[0] + base_right[0] + cutout_plus)/2, 0, light_tunnel_z])
      rotate([0, 90, 0])
      cylinder(h = base[0] + base_right[0] + base_left[0] + cutout_plus, d = light_tunnel_diameter, $fn = fn);
    //// side
    translate([vial_diameter/2 + light_tunnel_length_to_glass, -cutout_plus/2, light_tunnel_z])
      rotate([90, 0, 0])
      cylinder(h = base[1]/2 + cutout_plus, d = light_tunnel_diameter, $fn = fn);

    // opt & board cutout
    //// main
    translate([-vial_diameter/2 - light_tunnel_length_to_main_sensor, 0, base[2] - opt_board_cutout[2]])
    union() {
      translate([-opt_cutout[1]/2, 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_cutout[1] + cutout_plus, opt_cutout[0], opt_cutout[2] + cutout_plus]);
      translate([-opt_board_cutout[1]/2 - opt_cutout[1], 0, 0])
        xy_center_cube([opt_board_cutout[1], opt_board_cutout[0], opt_board_cutout[2] + cutout_plus]);
      translate([-opt_pin_depth/2 - opt_cutout[1] - opt_board_cutout[1], 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_pin_depth + cutout_plus, opt_cutout[0], opt_cutout[2] + cutout_plus]);
    };
    //// side
    translate([vial_diameter/2 + light_tunnel_length_to_glass, -light_tunnel_length_to_side_sensor, base[2] - opt_board_cutout[2]])
    rotate([0, 0, 90])
    union() {
      translate([-opt_cutout[1]/2, 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_cutout[1] + cutout_plus, opt_cutout[0], opt_cutout[2] + cutout_plus]);
      translate([-opt_board_cutout[1]/2 - opt_cutout[1], 0, 0])
        xy_center_cube([opt_board_cutout[1], opt_board_cutout[0], opt_board_cutout[2] + cutout_plus]);
      translate([-opt_pin_depth/2 - opt_cutout[1] - opt_board_cutout[1], 0, opt_board_cutout[2] - opt_cutout[2]])
        xy_center_cube([opt_pin_depth + cutout_plus, opt_cutout[0], opt_cutout[2] + cutout_plus]);
    };

    // center hole cutout
    translate([0, 0, -cutout_plus/2])
      cylinder(h = base[2] + adapter_height + cutout_plus, d = vial_diameter, $fn = fn);
    // adapter rim cutout
    translate([0, 0, base[2]])
      cylinder(h = adapter_height + cutout_plus, d = vial_diameter + 2 * holder_wall - 2 * adapter_rim, $fn = fn);
    // adapter slot cutouts
    translate([0, 0, base[2]])
      xy_center_cube([vial_diameter + 2 * holder_wall, adapter_slot_width, adapter_height + cutout_plus]);
    translate([0, 0, base[2]])
      xy_center_cube([adapter_slot_width, vial_diameter + 2 * holder_wall, adapter_height + cutout_plus]);
  }
}

light_sensor_base();
