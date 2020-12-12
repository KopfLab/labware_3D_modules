
use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders
$render_threads=true; // turning thread rendering on/off (renders very slowly if true)

// generate stirred bottle holder
// @param vial_diameter diameter of the vial/bottle
// @param base_height height of the base (must be at least 13 to clear the cutouts)
// @param adapter_height height of the adapter top (make 0 to remove adapter top)
module stirred_bottle_holder(vial_diameter, base_height, adapter_height = 10) {

  echo(str("INFO: rendering stirred bottle holder for ", vial_diameter, "mm tubes..."));

  holder_wall = 8;  // thickness of the holder wall around the vial
  adapter_slot_width = 10 - 0.2; // width of the attachment slot (minus tolerance for good fit)
  total_diameter = vial_diameter + 2 * holder_wall; // total diameter

  stand_feet = [12, 12, 6]; // length, width, height of support feet
  stand_feet_support = 8; // height of support for the stand feet

  bottom_thickness = 4.5; // thickness of the bottom
  bottom_diameter = 30; // diameter of hole on bottom

  stepper_width = 42; // +/- 0.1
  attachment_screw_depth = 5;

  difference() {
    union() {
      // vial holder
      cylinder(h = base_height, d = total_diameter);

      // adapters
      height = (vial_diameter / 2 + holder_wall) * adapter_height / holder_wall;
      translate([0, 0, base_height])
      for (angle = [120, 240, 360]) {
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

      // support feet
      total_diameter_w_feet = total_diameter + 2 * stand_feet[1];
      for (x = [30, 150, 270]) {
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
        cylinder(h = base_height + adapter_height + 2e, d = bottom_diameter);

    // motor adapter screws
    for (x = [-1, 1]) {
      translate([x * stepper_width/2, 0, bottom_thickness + e])
      mirror ([0, 0, 1])
      machine_screw(name = "M3", length = bottom_thickness + 2e);
    }

    // attachment screws (using M4 although it's for M3 screws for low quality printers)
    // this is what takes very long to render if render_threads = true
    for (x = [30, 90, 150, 210, 270, 330]) {
      rotate([0, 0, x])
        translate([vial_diameter/2 + holder_wall/2, 0, base_height - attachment_screw_depth])
          threaded_machine_screw(name = "M4", length = attachment_screw_depth + e);
    }

  }

}

// stirred bottle holder for 100ml bottles
// may not render in SCAD GUI, to render by command line (may still take a while), run:
// openscad -o stirred_bottle_holder_100mL.stl stirred_bottle_holder.scad
stirred_bottle_holder(vial_diameter = 56, base_height = 20);
