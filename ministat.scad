
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
// @param extra_rim is additional rim thickness for smaller bottles in the same bottle holder type
module stirred_bottle_holder(vial_diameter, base_height, bottom_thickness = 4, stirrer_hole_diameter = 25, adapter_height = 10, extra_rim = 0) {

  echo(str("INFO: rendering stirred bottle holder for ", vial_diameter - extra_rim, "mm tubes..."));

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
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter - extra_rim);
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
function get_slit_light_tunnel_dimensions() = [0.8, 4.0]; // width, height
function get_main_light_tunnel_dimensions() = [3.5, 4.0]; // width, height
function get_ref_light_tunnel_dimensions() = [3.0, 4.0]; // width, height
function get_sensor_light_tunnel_dimensions() = [4.0, 4.0]; // width, height
function get_blocks_screw_length() = 14.5; // length of screws + tolerance

// generate sensor block
// @param tunnel_dia (photodiode area cross section ~ 3.35mm)
module sensor_block(depth = 13, tunnel = [3,3], tolerance = 0) {
  opt = get_opt_dimensions();
  walls = 3;
  block = [35, 14, depth]; // width x height x depth
  screw_depth = get_blocks_screw_length() - 1.7; // comfort for 16mm screw, PCB is the 1.7mm
  difference() {
    // attachment block (for attachment rails, change to bottom_rail = true)
    attachment_block(block = block, walls = walls, bottom_rail = false, side_rails = false, screw_depth = screw_depth, screws_tolerance = tolerance);
    // light tunnel
    rotate([0, 0, 90])
    translate([0, 0, -e])
    light_tunnel([tunnel[1], tunnel[0], depth + 2e]);
    // opt cutout
    opt = get_opt_dimensions();
    // slanted overhang
    // FIXME: this could be improved how it's done, but it works
    translate([0, 0, opt[2] - e])
    rotate([0, 180, 180])
    union() {
      translate([0, 1 + opt[1]/2, 0])
      difference() {
        xy_center_cube([opt[0], 2, opt[2] + e]);
        rotate([-10, 0, 0]) translate([0, 0.55, -3]) xy_center_cube([opt[0] + 2e, 3, 2 * opt[2]]);
      }
      xy_center_cube([opt[0], opt[1], opt[2] + e]);
    }
  }
}

// generate led block
// @param tunnel_dia (photodiode area cross section ~ 3.35mm)
module led_block(depth = 15, tunnel = [3,3], tolerance = 0) {
  block = [30, 14, depth]; // width x height x depth
  walls = 3;
  screw_depth = get_blocks_screw_length() - 1.7; // comfort for 16mm screw, PCB is the 1.7mm
  led_diameter = 5.5; // to make sure LED fits
  led_height = 6.0; // to make sure LED fits
  led_rim = 1.0; // so electronics don't get squeezed
  difference() {
    // attachment block
    attachment_block(block = block, walls = walls, bottom_rail = false, side_rails = false, screw_depth = screw_depth, screws_tolerance = tolerance);
    // light tunnel
    rotate([0, 0, 90])
    light_tunnel([tunnel[1], tunnel[0], depth + 2e]);
    // led
    translate([0, 0, -e])
    cylinder(h = led_height + e, d = led_diameter + tolerance);
    translate([0, 0, -e])
    cylinder(h = led_rim, d = led_diameter + 2 * led_rim);
  }
}

// generate led holder
// FIXME: not used anymore? maybe just print one for soldering on the led?
/*
module led_holder(tolerance = 0) {
  led_diameter = 5.2; // to make sure LED fits
  walls = 3;
  depth = 7.0; // led is only 4.8 +/- 0.2 but better to have a slightly thicker holder
  block = [30, 14, depth]; // width x height x depth
  difference() {
    // attachment
    attachment(block = block, walls = walls, bottom_rail = false, screws_tolerance = tolerance);
    // led
    translate([0, 0, -e])
    cylinder(h = block[2] + 2e, d = led_diameter + tolerance);
  }
}
*/

// distribution board holder
// @param attachment_depth how much of an attachment bar is provided
module distribution_board_holder (attachment_depth = 5) {
  support = [10, 9, 8];
  screws_location = 22.2;
  solder_pins_depth = 3;
  solder_pins_start = 3;
  difference() {
    union() {
      translate([0, -(attachment_depth + support[1])/2, 0])
      xy_center_cube([support[0] + 2 * screws_location, attachment_depth, support[2]]);
      // screw supports
      for (x = [-1, 1]) {
        translate([x * screws_location, -2, 0]) xy_center_cube(support);
      }
      // small cut-away bottom rail for easier print if bottom_rail = false
      rail_thickness = 0.25;
      translate([0, 2 + 1.5 * rail_thickness, 0])
      xy_center_cube([support[0] + 2 * screws_location, rail_thickness, rail_thickness]);
    }
    // cutout
    for (x = [-1, 1]) {
      translate([x * screws_location, -2, 0])
      union() {
        // solder pins
        translate([x * (-solder_pins_start - 5/2), 0, support[2] - solder_pins_depth])
        xy_center_cube([5, support[1] + e, solder_pins_depth + e]);
        // screws
        translate([0, 0, -e])
        machine_screw(name = "M3", countersink=false, length = support[2] + 2e);
        translate([0, 0, -e])
        hexnut("M3", z_plus = 0.2, tolerance = 0.3, screw_hole = false);
      }
    }
  }
}

// generate light tunnel (optionally with flare)
module light_tunnel (size, flare_length = 0, flare_width = 5) {
  union() {
    rounded_cube([size[0], size[1], size[2] - flare_length]);
    if (flare_length > 0) {
      translate([0, 0, size[2] - flare_length])
      //rounded_cube([size[0], size[1], flare_length], scale_y = flare_scale);
      rounded_cube([size[0], size[1], flare_length], scale_y = flare_width/size[1]);
    }
  }
}

// generate whole ring for the light sensors
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
// @param extra_tolerance how much tolerance to add to cutouts and screws (usually material dependent)
// @param top_adapters whether top adapters are at top
module light_sensor_ring(vial_diameter, base_height = 14, adapter_height = 10, extra_tolerance = 0, top_adapters = false) {

  echo(str("INFO: rendering light sensor ring for ", vial_diameter, "mm tubes..."));

  // ring
  holder_wall = 8;  // thickness of the holder wall around the vial
  adapter_slot_width = 10; // standard width of the attachment slot
  vial_cutout_extra = 1.2; // slightly larger cutout for easier fit
  total_diameter = vial_diameter + 2 * holder_wall; // total diameter

  // sensors
  light_tunnel_diameter = 5; // photodiode area cross section ~ 3.35mm
  cover_slip = [16, 12, 0.8];
  cover_slip_access = 10;
  beam_sensor_block_depth = 24;
  ref_sensor_block_depth = 13.5;
  ref_sensor_block_y = -28.5;
  led_block_depth = 13.5;
  ref_led_block_x = 9;
  ref_ring_connector = 10;

  main_tunnel = get_main_light_tunnel_dimensions();
  slit_tunnel = get_slit_light_tunnel_dimensions();
  ref_tunnel = get_ref_light_tunnel_dimensions();
  ref_led_connect = [35-led_block_depth, 30, 14];

  difference() {
    union() {
      // vial holder
      difference() {
        cylinder(h = base_height, d = total_diameter);
        translate([-total_diameter/2, 0, -e]) xy_center_cube([5, 30, base_height + 2e]);
      }

      // top adapters
      if (top_adapters) {
        translate([0, 0, base_height])
        ring_adapters(
          vial_diameter, holder_wall, adapter_height,
          adapter_slot_width =  adapter_slot_width - 0.2 // minus tolerance for good fit
        );
      }

      // distribution board holder
      translate([0, vial_diameter/2 + holder_wall + 4.5, 0])
      distribution_board_holder(attachment_depth = 15);

      // beam sensor block
      translate([-total_diameter/2 - beam_sensor_block_depth/2, 0, 7])
      rotate([-90, 0, -90])
      sensor_block(depth = beam_sensor_block_depth, tunnel = get_sensor_light_tunnel_dimensions(), tolerance = extra_tolerance);

      // ref sensor block
      translate([total_diameter/2 + ref_led_block_x, ref_sensor_block_y, 7])
      rotate([-90, 0, 0])
      sensor_block(depth = ref_sensor_block_depth, tunnel = ref_tunnel, tolerance = extra_tolerance);

      // led block
      translate([total_diameter/2 + ref_led_block_x + 17.5, 0, 7])
      rotate([-90, 0, 90])
      led_block(depth = led_block_depth, tunnel = get_main_light_tunnel_dimensions(), tolerance = extra_tolerance);

      // ref-ring connector
      translate([total_diameter/2 - ref_led_block_x - ref_ring_connector/2 + 1, ref_sensor_block_y + ref_ring_connector/2, 0])
      xy_center_cube([ref_ring_connector, ref_ring_connector, base_height]);

      // ref-led block connector
      reveal = 0; // for debugging purposes
      flare_w = 9;
      translate([total_diameter/2 + ref_led_block_x - led_block_depth/2, 0, 0])
      difference() {
        xy_center_cube([ref_led_connect[0], ref_led_connect[1], ref_led_connect[2] - reveal]);

        // front path of main light tunnel
        front_path_length = (ref_led_connect[0] - led_block_depth)/2;
        translate([ref_led_connect[0]/2 + e, 0, ref_led_connect[2]/2])
        rotate([0, -90, 0])
        light_tunnel([main_tunnel[1], main_tunnel[0], front_path_length + e], flare_length = 3, flare_width = flare_w);

        // mid path of main light tunnel
        mid_path_length = 4.5;
        translate([ref_led_connect[0]/2 - front_path_length - mid_path_length, 0, ref_led_connect[2]/2])
        rotate([0, 90, 0])
        light_tunnel([main_tunnel[1], main_tunnel[0], mid_path_length], flare_length = 3, flare_width = flare_w);

        // main light tunnel
        end_path_length = ref_led_connect[0] - front_path_length - mid_path_length;
        translate([-ref_led_connect[0]/2 - e, 0, ref_led_connect[2]/2])
        rotate([0, 90, 0])
        light_tunnel([slit_tunnel[1], slit_tunnel[0], end_path_length + 2e]);

        // mid part of ref light tunnel
        translate([led_block_depth/2, -ref_led_connect[1]/4 - e, ref_led_connect[2]/2])
        rotate([-90, 90, 0])
        light_tunnel([main_tunnel[1], main_tunnel[0], ref_led_connect[1]/4 + e], flare_length = 3, flare_width = flare_w);

        // ref light tunnel
        translate([led_block_depth/2, -ref_led_connect[1]/2 - e, ref_led_connect[2]/2])
        rotate([-90, 90, 0])
        light_tunnel([ref_tunnel[1], ref_tunnel[0], ref_led_connect[1]/4 + e], flare_length = 0);

        // cover slip
        translate([led_block_depth/2 - 2, -2, ref_led_connect[2] - cover_slip[1]/2 + e])
        union() {
          // cover slip cutout
          rotate([90, 0, 45]) translate([0, 0, -cover_slip[2]/2])
          xy_center_cube(cover_slip);

          // access groove
          translate([0, 0, cover_slip[1]/2])
          rotate([90, 0, 45]) translate([0, 0, -cover_slip_access/2])
          cylinder(h = cover_slip_access, d = 5);
        }
      }
    }

    // center hole cutout (slightly bigger than stirred bottle holder base for easier fit)
    translate([0, 0, -e])
      cylinder(h = base_height + adapter_height + 2e, d = vial_diameter + vial_cutout_extra);

    // main light tunnel through ring
    slit_tunnel = get_slit_light_tunnel_dimensions();
    translate([vial_diameter/2 + e, 0, ref_led_connect[2]/2])
    rotate([0, 90, 0])
    light_tunnel([slit_tunnel[1], slit_tunnel[0], holder_wall + 2e]);

    // sensor light tunnel through ring
    sensor_tunnel = get_sensor_light_tunnel_dimensions();
    translate([-total_diameter/2 - e, 0, ref_led_connect[2]/2])
    rotate([0, 90, 0])
    light_tunnel([sensor_tunnel[1], sensor_tunnel[0], holder_wall + 2e]);

    // bottom adapter cutouts
    translate([0, 0, -e])
    ring_adapters(
      vial_diameter = vial_diameter + 0.3, // plus tolerance for good fit
      holder_wall = holder_wall,
      adapter_height = adapter_height + 0.3, // plus tolerance for good fit
      adapter_slot_width =  adapter_slot_width + 0.3 // plus tolerance for good fit
    );

    // attachment screw holes
    for (x = [1, 2, 4, 5]) {
      rotate([0, 0, x * 60])
        translate([vial_diameter/2 + holder_wall/2, 0, base_height + e])
          rotate([0, 180, 0])
          machine_screw(name = "M3", countersink=true, length = base_height + 2e);
    }

    // bottle alignment
    translate([0, -vial_diameter/2, base_height])
    rotate([90, 0, 0])
    cylinder(h = holder_wall, d = 2);

  }

}

// bottle adapter
module bottle_adapter(ring_diameter, vial_diameter, base_height = 14, thickness = 4, extra_tolerance = 0) {

  holder_wall = 8;  // thickness of the holder wall around the vial
  vial_cutout_extra = 0.6; // slightly larger cutout for easier fit
  total_diameter = ring_diameter + 2 * holder_wall; // total diameter

  rotate([180, 0, 0])
  difference() {
    union() {
      // vial holder
      translate([0, 0, base_height])
      cylinder(h = thickness, d = total_diameter);
      cylinder(h = base_height + thickness, d = ring_diameter);
    }

    // center hole cutout (slightly bigger than stirred bottle holder base for easier fit)
    translate([0, 0, -e])
    cylinder(h = base_height + thickness + 2e, d = vial_diameter + vial_cutout_extra);

    // attachment screw holes
    for (x = [1, 2, 4, 5]) {
      rotate([0, 0, x * 60])
        translate([ring_diameter/2 + holder_wall/2, 0, base_height-e])
          //rotate([0, 180, 0])
          machine_screw(name = "M3", countersink=true, invert_countersink = true, length = thickness + 2e);
    }

    // light tunnel through adapter ring
    sensor_tunnel = get_sensor_light_tunnel_dimensions();
    translate([-(ring_diameter + vial_cutout_extra)/2 - e, 0, base_height/2])
    rotate([0, 90, 0])
    light_tunnel([sensor_tunnel[1] * 2, sensor_tunnel[0] * 2, ring_diameter + vial_cutout_extra + 2e]);

    // bottle alignment
    // does not go all the way to the edge to avoid inside brim
    translate([0, -(vial_diameter/2), base_height + thickness])
    rotate([90, 0, 0])
    cylinder(h = holder_wall, d = 2);
  }
}

// standoffs for elevated stirrer placement
module standoff_adapter(ring_diameter, standoff_height = 10, stirrer_hole_diameter = 25) {
  tolerance = 0.6; // slightly smaller diameter than ring diameter for easier fit
  stepper_width = 42; // +/- 0.1
  difference() {
    cylinder(h = standoff_height, d = ring_diameter - tolerance);
    // motor hole
    translate([0, 0, -e])
    cylinder(h = standoff_height + 2e, d = stirrer_hole_diameter);
    // motor adapter screws
    for (x = [-1, 1]) {
      translate([x * stepper_width/2, 0, standoff_height + e])
      mirror ([0, 0, 1])
      machine_screw(name = "M3", length = standoff_height + 2e);
    }
  }
}

/* render all pieces */

no_trans = [0, 0, 0];
no_rot = [0, 0, 0];
no_col = "gray";

// stirred bottle holder for 100ml bottles
// may not render in SCAD GUI, to render by command line (may still take a while), run:
// openscad -o stirred_bottle_holder_100mL.stl stirred_bottle_holder.scad

// parts scwitch
//part = "stirrer"; // 100ml standard media bottle base
part = "standoff"; // base standoff for elevated stirrer position
//part = "magnet";
//part = "ring";
//part = "60adapter"; // 60ml serum bottle adapter
//part = "100adapter"; // 100ml serum bottle adapter
//part = "120adapter"; // 120ml serum bottle base without magnet
//part = "sensor";
//part = "ref";
//part = "led";
//part = "ministat";

//TODO: adapter ring for serum bottles

// stirred bottle holders
if (part == "stirrer" || part == "all" || part == "ministat") {
  translate((part == "all") ? [0, 0, -20] : no_trans)
  rotate((part == "all") ? [0, 0, 60] : no_rot)
  color((part == "all") ? "teal" : no_col)
  stirred_bottle_holder(vial_diameter = 56.1, base_height = 20);
}

// magnet holder
if (part == "magnet" || part == "all") {
  translate((part == "all") ? [0, 0, -26] : no_trans)
  color((part == "all") ? "navy" : no_col)
  stirrer_magnet_holder(10, 3.3);
}

// light sensor ring
nylon_tol = 0.1; // extra tolerance for nylon parts shrinkage
if (part == "ring" || part == "all" || part == "ministat") {
  translate((part == "all" || part == "ministat") ? [0, 0, 30] : no_trans)
  color((part == "all") ? "white" : no_col)
  light_sensor_ring(vial_diameter = 56.1, extra_tolerance = nylon_tol);
}

// standoff adapters for elevated stirrers
if (part == "standoff" || part == "all") {
  standoff_adapter(ring_diameter = 56.1, standoff_height = 9);
}

// adapter for 60ml serum bottles
if (part == "60adapter" || part == "all" || part == "ministat") {
  translate((part == "all" || part == "ministat") ? [0, 0, 50] : no_trans)
  rotate((part == "all" || part == "ministat") ? [180, 0, 0] : no_rot)
  bottle_adapter(ring_diameter = 56.1, vial_diameter = 41.3);
}

// adapter for 100ml serum bottles
if (part == "100adapter" || part == "all") {
  bottle_adapter(ring_diameter = 56.1, vial_diameter = 51.7);
}

// base adapter for 120ml serum bottles
if (part == "120adapter" || part == "all") {
  // base_height = 20 - 4 (regular height - regular bottom thickness)
  extra_rim = 56.1 - 54.35;
  union() {
    stirred_bottle_holder(vial_diameter = 56.1, base_height = 16, extra_rim = extra_rim, bottom_thickness = -e);
    cylinder(d = 58, h = 0.5);
  }
}

// beam sensor holder
if (part == "sensor" || part == "all") {
  translate((part == "all") ? [-56.1 + 13.7, 0, 7] : no_trans)
  rotate((part == "all") ? [90, 180, -90] : no_rot)
  color((part == "all") ? "teal" : no_col)
  //sensor_holder(tolerance = nylon_tol, tunnel_dia = 2);// too small
  sensor_holder(tolerance = nylon_tol, tunnel_dia = 2.7);
}

// ref sensor holder
if (part == "ref" || part == "all") {
  translate((part == "all") ? [56.1 - 11, -22.7, 7] : no_trans)
  rotate((part == "all") ? [90, 180, 0] : no_rot)
  color((part == "all") ? "orange" : no_col)
  sensor_holder(tolerance = nylon_tol, tunnel_dia = 5);
}

// led holder
if (part == "led" || part == "all") {
  translate((part == "all") ? [56.1 + 0.5, 0, 7] : no_trans)
  rotate((part == "all") ? [90, 180, 90] : no_rot)
  color((part == "all") ? "pink" : no_col)
  led_holder(tolerance = nylon_tol);

}
