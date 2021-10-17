use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

// holder for extraction vials
// @param positions number of positions
// @param diameter vial diameter (including tolerance)
// @param spacing center-to-center spacing
// @param fixed_length if provided, fixes the overall length for the holder
// @param ledge if provided, includes a ledge (thickness/2) of this width for the vials
module extraction_vial_holder(positions, diameter, spacing, fixed_length = 0, ledge = 0, thickness = 4, lip_thickness = 2, lip_height = 0, edge_gap = 3, supports_gap = 5, window = true) {

    // dimensions
    length = positions * spacing;
    lip_diameter = diameter + 2 * lip_thickness;
    width = lip_diameter + 2 * edge_gap;
    supports = [16, 80, thickness];
    bar = (fixed_length > 0) ?
      [fixed_length - 2 * supports[0], width, thickness] :
      [length + 2 * supports_gap, width, thickness];
    holes = 6.5;
    holes_height = 10;
    connect_bars = 2; // connecting bars thickness

    echo(str("INFO: rendering spe holder with overall dimensions: ",
      bar[0] + 2 * supports[0], "mm (width) x ",
      supports[1], "mm (length)"));

    difference() {
      union() {
        // base
        xy_center_cube(bar);
        // vial holders
        for (i = [1 : 1 : positions]) {
          translate([i * spacing - length/2 - spacing/2, 0, 0])
          cylinder(d = lip_diameter, h = thickness + lip_height);
        }
        // supports
        for (x = [-1, 1]) {
          translate([x * (bar[0] + supports[0])/2, 0, 0])
            xy_center_cube([supports[0], supports[1] - supports[0], supports[2]]);
          translate([x * (bar[0]/2 + supports[0] - connect_bars/2), 0, 0])
            xy_center_cube([connect_bars, supports[1] - supports[0], holes_height]);
          for (y = [-1, 1]) {
            translate([x * (bar[0] + supports[0])/2, y * (supports[1] - supports[0])/2, 0])
                cylinder(d = supports[0], h = holes_height);
          }
        }
        // crosss bar
        if (lip_height > 0) {
          xy_center_cube([bar[0] + 2 * supports[0], connect_bars, holes_height]);
          xy_center_cube([bar[0], connect_bars, thickness + lip_height]);
        } else {
          translate([0, -bar[1]/2, 0])
          xy_center_cube([bar[0] + 2 * supports[0], connect_bars, holes_height]);
        }
      }

      // vial holders
      base_offset = (ledge > 0) ? thickness : -e;
      for (i = [1 : 1 : positions]) {
        // vial holes
        translate([i * spacing - length/2 - spacing/2, 0, base_offset])
          cylinder(d = diameter, h = thickness + lip_height + 2e);
        // ledged holes
        if (ledge > 0) {
          translate([i * spacing - length/2 - spacing/2, 0, -e])
            cylinder(d = diameter - 2 * ledge, h = thickness + lip_height + 2e);
        }
        // vial windows
        if (window) {
          for (y = [1]) {
            translate([i * spacing - length/2 - spacing/2, y * diameter/2, thickness])
            rotate([0, 0, y * 30])
            cylinder(d = 1.2 * diameter, h = lip_height + e, $fn=3);
          }
        }
      }

      // support holes
      for (x = [-1, 1]) {
        for (y = [-1, 1]) {
          translate([x * (bar[0] + supports[0])/2, y * (supports[1] - supports[0])/2, -e])
            cylinder(d = holes, h = holes_height + 2e);
        }
      }

      // support set screws --> use tolerance = -0.1 to make them just small enough for threading
      for (x = [-1, 1]) {
        for (y = [-1, 1]) {
          translate([x * (bar[0]/2 -e), y * (supports[1] - supports[0])/2, holes_height/2])
            rotate([0, x*90, 0])
              machine_screw(name = "M3", countersink = false, length = supports[0] + 2e, tolerance = -0.1);
          translate([x * (bar[0]/2 + supports[0]/2 -e), y * (supports[1])/2, holes_height/2])
            rotate([y*90, 0])
              machine_screw(name = "M3", countersink = false, length = supports[0]/2 + 2e, tolerance = -0.1);
        }
      }
    }

}

// which one to render (useful if $render_threads is on)
render_type = "GC";

// spacing for whole set
spacing = 36.0;
positions = 6;
fixed_length = 35 * positions;
y_spacing = 25;

// VOA vial holder for capturing SPE effluent
if (render_type == "VOA" || render_type == "all") {
  color("blue")
  translate([0, 0, 0 * y_spacing])
  extraction_vial_holder(
    positions = positions,
    diameter = 27.5 + 1.0, // tolerance for nylon print
    spacing = spacing,
    fixed_length = fixed_length,
    ledge = 5,
    lip_height = 40
  );
}

// 16ml vial holder for capturing SPE effluent
if (render_type == "16ml" || render_type == "all") {
  color("green")
  translate([0, 0, 2 * y_spacing])
  //translate([0, 33, 0])
  extraction_vial_holder(
    positions = positions,
    diameter = 20.8 + 1.0, // tolerance for nylon print
    spacing = spacing,
    fixed_length = fixed_length,
    lip_height = 30,
    ledge = 4
  );
}

// SPE vial holder
if (render_type == "SPE" || render_type == "all") {
  color("red")
  translate([0, 0, 3.5 * y_spacing])
  //translate([27, 30, 0])
  extraction_vial_holder(
    positions = positions,
    diameter = 15.2 + 0.8, // tolerance for nylon print
    spacing = spacing,
    fixed_length = fixed_length,
    lip_height = 16
  );
}

// 4ml vial holder for capturing effluent
if (render_type == "4ml" || render_type == "all") {
  color("pink")
  translate([0, 0, 4.5 * y_spacing])
  //translate([28, 5, 0])
  extraction_vial_holder(
    positions = positions * 2 - 1,
    diameter = 14.8 + 0.5, // tolerance for nylon print
    spacing = spacing/2,
    fixed_length = fixed_length,
    ledge = 2,
    lip_height = 20
  );
}

// GC vial holder for capturing effluent
if (render_type == "GC" || render_type == "all") {
  color("gray")
  translate([0, 0, 5.5 * y_spacing])
  //translate([50, 28, 0])
  extraction_vial_holder(
    positions = positions * 2 - 1,
    diameter = 12.0 + 0.4, // tolerance for nylon print
    spacing = spacing/2,
    fixed_length = fixed_length,
    ledge = 2,
    lip_height = 14
  );
}

// pasteur pipette holder
if (render_type == "pasteur-bottom" || render_type == "all") {
  color("orange")
  translate([0, 0, 6.5 * y_spacing])
  extraction_vial_holder(
    positions = positions * 2 - 1,
    diameter = 4.0, // resting holder for pasteur pipette
    spacing = spacing/2,
    fixed_length = fixed_length
  );
}

if (render_type == "pasteur-top" || render_type == "all") {
  color("yellow")
  translate([0, 0, 7.5 * y_spacing])
  extraction_vial_holder(
    positions = positions * 2 - 1,
    diameter = 7.0 + 0.8, // actual hole for pasteur pipette
    spacing = spacing/2,
    fixed_length = fixed_length
  );
}
