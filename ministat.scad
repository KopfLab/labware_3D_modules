
use <utils.scad>;
use <screws.scad>;
use <attachments.scad>;

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

/*** light sensor ring ***/

// get OPT dimensions
function get_opt_dimensions() = [10.5, 10, 4.8]; // width, height, depth

// generate sensor block
// @param tunnel_dia (photodiode area cross section ~ 3.35mm)
module sensor_block(depth = 13, tunnel_dia = 4, tolerance = 0) {
  opt = get_opt_dimensions();
  walls = 3;
  block = [35, 14, depth]; // width x height x depth
  screw_depth = 16.5 - opt[2] - walls - 1.7; // comfort for 14mm screw, PCB is the 1.7mm
  difference() {
    // attachment block
    attachment_block(block = block, walls = walls, bottom_rail = false, center = opt[0] + 2 * walls, screw_depth = screw_depth, screws_tolerance = tolerance);
    // light tunnel
    translate([0, 0, -e])
    cylinder(h = depth + 2e, d = tunnel_dia);
  }
}

// generate sensor holder
module sensor_holder(tunnel_dia = 2, tolerance = 0) {
  opt = get_opt_dimensions();
  walls = 3;
  block = [35, 14, opt[2] + walls];
  difference() {
    // attachment
    attachment(block = block, walls = walls, bottom_rail = false, center = opt[0] + 2 * walls, screws_tolerance = tolerance);
    // opt cutout
    translate([0, 0, walls])
    xy_center_cube([opt[0], opt[1], opt[2] + e]);
    // light tunnel
    translate([0, 0, -e])
    cylinder(h = block[2] + 2e, d = tunnel_dia);
  }
}

// generate led block
// @param tunnel_dia (photodiode area cross section ~ 3.35mm)
module led_block(depth = 15, tunnel_dia = 4, tolerance = 0) {
  block = [30, 14, depth]; // width x height x depth
  walls = 3;
  screw_depth = 16.5 - 7.0 - 1.7; // comfort for 16mm screw, PCB is the 1.7mm
  difference() {
    // attachment block
    attachment_block(block = block, walls = walls, bottom_rail = false, center = 10, screw_depth = screw_depth, screws_tolerance = tolerance);
    // light tunnel
    translate([0, 0, -e])
    cylinder(h = depth + 2e, d = tunnel_dia);
  }
}

// generate led holder
module led_holder(tolerance = 0) {
  led_diameter = 4.7; // +/- 0. 2
  ledge_diameter = 5.4; // +/- 0.2
  ledge_thickness = 0.6; // no error estimate
  error_range = 0.2;
  guide_pin = [1, 1, ledge_thickness]; // guide pin width, length and thickness
  walls = 3;
  depth = 7.0; // led is only 4.8 +/- 0.2 but better to have a slightly thicker holder
  block = [30, 14, depth]; // width x height x depth
  difference() {
    // attachment
    attachment(block = block, walls = 3, bottom_rail = false, center = 10, screws_tolerance = tolerance);
    // led
    translate([0, 0, -e])
    cylinder(h = block[2] + 2e, d = led_diameter + error_range + tolerance);
    // this doesn't really print well
    if (false) { // FIXME
      // ledge
      rotate([0, 0, -135])
      translate([0, 0, block[2] - ledge_thickness])
      union() {
        cylinder(h = ledge_thickness + e, d = ledge_diameter + error_range + 2 * tolerance);
        translate([(ledge_diameter + error_range + guide_pin[0])/2, 0, 0])
        xy_center_cube([guide_pin[0] + error_range + tolerance, guide_pin[1] + error_range + tolerance, guide_pin[2] + e]);
      }
    }
  }
}

// generate whole ring for the light sensors
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module light_sensor_ring(vial_diameter, base_height = 14, adapter_height = 10) {

  echo(str("INFO: rendering light sensor ring for ", vial_diameter, "mm tubes..."));

  // ring
  holder_wall = 8;  // thickness of the holder wall around the vial
  adapter_rim = 4; // thickness of the adapter rim
  adapter_slot_width = 10; // standard width of the attachment slot
  vial_cutout_extra = 0.4; // slightly larger cutout for easier fit
  total_diameter = vial_diameter + 2 * holder_wall; // total diameter

  // sensors
  light_tunnel_diameter = 4; // photodiode area cross section ~ 3.35mm
  nylon_tol = 0.1; // extra tolerance for nylon parts shrinkage
  cover_slip = [16, 12, 0.45];
  cover_slip_access = 10;
  beam_sensor_block_depth = 24;
  ref_sensor_block_depth = 13.5;
  ref_sensor_block_y = -28.5;
  led_block_depth = 13.5;
  ref_led_block_x = 9;
  ref_ring_connector = 10;

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

      // beam sensor block
      translate([-total_diameter/2 - beam_sensor_block_depth/2, 0, 7])
      rotate([-90, 0, -90])
      sensor_block(depth = beam_sensor_block_depth, tunnel_dia = light_tunnel_diameter, tolerance = nylon_tol);

      // ref sensor block
      translate([total_diameter/2 + ref_led_block_x, ref_sensor_block_y, 7])
      rotate([-90, 0, 0])
      sensor_block(depth = ref_sensor_block_depth, tunnel_dia = light_tunnel_diameter, tolerance = nylon_tol);

      // led block
      translate([total_diameter/2 + ref_led_block_x + 17.5, 0, 7])
      rotate([-90, 0, 90])
      led_block(depth = led_block_depth, tunnel_dia = light_tunnel_diameter, tolerance = nylon_tol);

      // ref-led block connector
      translate([total_diameter/2 + ref_led_block_x - led_block_depth/2, 0, 0])
      xy_center_cube([35-led_block_depth, 30, base_height]);

      // ref-ring connector
      translate([total_diameter/2 - ref_led_block_x - ref_ring_connector/2 + 1, ref_sensor_block_y + ref_ring_connector/2, 0])
      xy_center_cube([ref_ring_connector, ref_ring_connector, base_height]);
    }

    // center hole cutout (slightly bigger than stirred bottle holder base for easier fit)
    translate([0, 0, -e])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter + vial_cutout_extra);

    // cover slip cutout
    translate([total_diameter/2 + ref_led_block_x, 0, 14 - cover_slip[1]/2 + e])
    rotate([90, 0, 45])
    translate([-2.5, 0, -cover_slip[2]/2])
    xy_center_cube(cover_slip);

    // cover slip access
    translate([total_diameter/2 + ref_led_block_x, 0, 14])
    rotate([90, 0, 45])
    translate([-2.5, 0, -cover_slip_access/2])
    cylinder(h = cover_slip_access, d = 5);

    // ref light tunnel
    translate([total_diameter/2 + ref_led_block_x, 0, 7])
    rotate([90, 0, 0])
    cylinder(h = 100, d = light_tunnel_diameter);

    // main light tunnel
    translate([total_diameter/2 + ref_led_block_x - 100, 0, 7])
    rotate([0, 90, 0])
    cylinder(h = 200, d = light_tunnel_diameter);

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
color("teal")
!light_sensor_ring(vial_diameter = 56.1);
