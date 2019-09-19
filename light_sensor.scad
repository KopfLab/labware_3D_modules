
use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders
$render_threads=true; // turning thread rendering on/off


// generate base for the light sensors
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module light_sensor_base(vial_diameter, base_height = 13, adapter_height = 5) {

  holder_wall = 5;  // thickness of the holder wall around the vial
  adapter_rim = 2.5; // thickness of the adapter rim
  adapter_slot_width = 7; // width of the attachment slot

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

  base_right = [light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height + led_pin_depth - 2e + 5, 27, base_height];
  base_right_location = [vial_diameter/2 + base_right[0]/2 - 5, -6, 0];
  base_left = [17, 19, base_height];
  base_left_location = [-vial_diameter/2 - base_left[0]/2, 0, 0];
  light_tunnel_z = base_height - opt_cutout[2] + light_tunnel_opt_base_offset;

  difference() {
    union() {
      // vial holder
      cylinder(h = base_height + adapter_height, d = vial_diameter + 2 * holder_wall);

      // base right
      translate(base_right_location) xy_center_cube(base_right);

      // base left
      translate(base_left_location) xy_center_cube(base_left);
    }

    // led cutout
    translate([vial_diameter/2 + light_tunnel_length_to_glass + light_tunnel_length_to_led + led_height, -e, light_tunnel_z])
    rotate([0, -90, 0])
    union() {
      cylinder(h = led_back_height, d = led_back_diameter);
      translate([0, 0, -led_pin_depth]) cylinder(h = led_height + led_pin_depth, d = led_diameter);
      // top access
      translate([(base_height - light_tunnel_opt_base_offset)/2, 0, 0])
        xy_center_cube([base_height - light_tunnel_opt_base_offset, led_back_diameter, led_back_height]);
      translate([(base_height - light_tunnel_opt_base_offset)/2, 0, -led_pin_depth])
        xy_center_cube([base_height - light_tunnel_opt_base_offset, led_diameter, led_height + led_pin_depth]);
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

    // center hole cutout
    translate([0, 0, -e])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter);
    // adapter rim cutout
    translate([0, 0, base_height])
      cylinder(h = adapter_height + 2e, d = vial_diameter + 2 * holder_wall - 2 * adapter_rim);
    // adapter slot cutouts
    translate([0, 0, base_height])
      xy_center_cube([vial_diameter + 2 * holder_wall, adapter_slot_width, adapter_height + 2e]);
    translate([0, 0, base_height])
      xy_center_cube([adapter_slot_width, vial_diameter + 2 * holder_wall, adapter_height + 2e]);

    // slide adapter cutouts
    for (x = [-1, 1]) {
      rotate([0, 0, x * 45])
      translate([0, 0, -e])
      difference() {
        radius = vial_diameter/2 + holder_wall - adapter_rim;
        cylinder(h = base_height + 2e, d = radius * 2);
        translate([-radius/2 - adapter_slot_width/2, 0, -e])
          xy_center_cube([radius, radius * 2, base_height + 2e]);
        translate([radius/2 + adapter_slot_width/2, 0, -e])
          xy_center_cube([radius, radius * 2, base_height + 2e]);
      }
    }
  }
}

// light sensor base
color("grey") translate([0, 0, 35])
light_sensor_base(vial_diameter = 55.5); // for 100mL bottles

// generate stirred bottle holder
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module stirred_bottle_holder(vial_diameter, base_height, adapter_height = 10) {

  holder_wall = 5;  // thickness of the holder wall around the vial
  adapter_rim = 2.5 + 0.2; // thickness of the adapter rim (plus tolerance for good fit)
  adapter_slot_width = 7 - 0.2; // width of the attachment slot (minus tolerance for good fit)

  support_feet = [10, 10, 6]; // length, width, height of support feet

  bottom_thickness = 4; // thickness of the bottom
  bottom_diameter = 30; // diameter of hole on bottom

  stepper_width = 42; // +/- 0.1

  difference() {
    union() {
      // vial holder
      cylinder(h = base_height + adapter_height, d = vial_diameter + 2 * holder_wall);
      // support feet
      total_diameter = vial_diameter + 2 * holder_wall + 2 * support_feet[1];
      for (x = [90, 210, 330]) {
        rotate([0, 0, x])
        difference() {
          cylinder(h = support_feet[2], d = total_diameter);
          for (x = [-1, 1]) {
            translate([0, x * (total_diameter + support_feet[1])/2, -e])
            xy_center_cube([total_diameter + 2e, total_diameter, support_feet[2] + 2e]);
          }
          translate([-total_diameter/2, 0, -e])
            xy_center_cube([total_diameter, total_diameter, support_feet[2] + 2e]);
          translate([(total_diameter - support_feet[1])/2, 0, -e])
            threaded_machine_screw(name = "M4", length = support_feet[2] + 2e);
        }
      }
    }

    // slide adapters
    translate([0, 0, base_height])
    difference() {
      cylinder(h = adapter_height + e, d = vial_diameter + 2 * holder_wall + e);
      for (x = [-1, 1]) {
        rotate([0, 0, x * 45])
        xy_center_cube([vial_diameter + 2 * holder_wall - 2 * adapter_rim, adapter_slot_width, adapter_height + 2e]);
      }
    }

    // center hole cutout
    translate([0, 0, bottom_thickness])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter);
      translate([0, 0, -e])
        cylinder(h = base_height + adapter_height + 2e, d = bottom_diameter);

    // motor adapter screws
    for (x = [-1, 1]) {
      translate([x * stepper_width/2, 0, bottom_thickness + e])
      mirror ([0, 0, 1])
      machine_screw(name = "M3", length = bottom_thickness + 2e);
    }

  }

/*
  difference() {
  	translate([-15, -15, 0]) cube([80, 30, 50]);
  	rotate([180,0,0]) nutcatch_parallel("M5", l=5);
  	//translate([-15, 0, 50+e]) hole_through(name="M5", l=50+5, cld=0.1, h=10, hcld=0.4);
  	translate([-15, 0, 50+e]) threaded_machine_screw(name = "M4", length = 50+2e);
  	translate([55, 0, 9+e]) nutcatch_sidecut("M8", l=100, clk=0.1, clh=0.1, clsl=0.1);
  	translate([55, 0, 50+e]) hole_through(name="M8", l=50+5, cld=0.1, h=10, hcld=0.4);
  	translate([27.5, 0, 50+e]) hole_threaded(name="M5", l=60);
  }*/

}

!stirred_bottle_holder(vial_diameter = 55.5, base_height = 20);
