// balch tube tower for optimizing culturing space in the incubator
use <utils.scad>;
use <screws.scad>;

// Generate vial holders
//
// Module for generic vial holder. All measurements are in mm.
//
// @param holder_base thickness of holder base (if any)
// @param well_depth depth of each well
// @param well_diameter diameter of each well (recommend at least 0.3mm tolerance on top of tube diameter)
// @param well_gap gap between neighboring wells (can be overriden with well distances below)
// @param well_distance_rows center-to-center distance of wells along the rows (by default defined via well gap)
// @param well_distance_cols center-to-center distance of wells along the columns (by default defined via well gap)
// @param rows number of rows
// @param cols number of colums
// @param fixed_cols_width fixed width of holder (by default is calculated autmatically from cols)
// @param fixed_rows_width fixed height of holder (by default is calculated autmatically from rows)
// @param holder_screws what kind of screws to use for attachment locations between the wells (use false if none)
// @param holder_edge_screws if > 0, adds screws on the edge of the holder with the indicated offset (so they fit)
// @param well_screws what kind of countersink screws to use at the base of each well (use false if none)
module vial_holder(
  holder_base = 0,
  well_depth = 4, well_diameter = 12, well_gap = 4,
  well_distance_rows = false, well_distance_cols = false,
  rows = 5, cols = 5,
  fixed_rows_width = false, fixed_cols_width = false,
  holder_screws = "M4", holder_edge_screws = false,
  well_screws = "M4") {

  // constants
  z_plus = 0.01; // how much thicker to make cutouts in z
  well_distance_rows = (well_distance_rows) ? well_distance_rows : well_diameter + well_gap;
  well_distance_cols = (well_distance_cols) ? well_distance_cols : well_diameter + well_gap;

  // dimensions
  cols_width = (fixed_cols_width) ? fixed_cols_width : cols * well_distance_cols;
  rows_width = (fixed_rows_width) ? fixed_rows_width : rows * well_distance_rows;
  base = [cols_width, rows_width, holder_base + well_depth];

  // info message
  echo(str("INFO: rendering vial holder with overall dimensions: ",
    cols_width, "mm (", cols, " cols) x ",
    rows_width, "mm (", rows, " rows) x ",
    base[2], "mm (height)"));

  difference() {
    // base cube
    xy_center_cube(base);
    // wells
    row_list = [for (i = [1 : 1 : rows]) i];
    col_list = [for (i = [1 : 1 : cols]) i];
    for (y = row_list)
      for (x = col_list)
        translate([(x - (cols + 1)/2) * well_distance_cols, (y - (rows + 1)/2) * well_distance_rows, 0])
          union() {
            translate([0, 0, holder_base + well_depth/2])
              cylinder(d = well_diameter, h = well_depth + z_plus, center=true, $fn = 60);
            if (well_screws) {
              translate([0, 0, holder_base])
                rotate([180, 0, 0])
                  machine_screw(well_screws, length = holder_base, tolerance = 0.15, z_plus = z_plus, countersink = true);
            }
          }
    // attachment screws
    if (holder_screws) {
      row_list = (holder_edge_screws) ? [for (i = [0 : 1 : rows]) i] : [for (i = [1 : 1 : (rows-1)]) i];
      col_list = (holder_edge_screws) ? [for (i = [0 : 1 : cols]) i] : [for (i = [1 : 1 : (cols-1)]) i];
      for (y = row_list)
        for (x = col_list) {
          x_offset = (x == 0) ? holder_edge_screws : ((x == cols) ? -holder_edge_screws : 0);
          y_offset = (y == 0) ? holder_edge_screws : ((y == rows) ? -holder_edge_screws : 0);
          translate([x_offset + (x + 0.5 - (cols + 1)/2) * well_distance_cols, y_offset + (y + 0.5 - (rows + 1)/2) * well_distance_rows, 0])
          machine_screw(holder_screws, length = base[2], tolerance = 0.15, z_plus = z_plus, countersink = false);
        }
    }
  }
}

// example default vial holder for ~25mm vials with base and 2 layers
translate([200, 0, 0])
color("gray")
union() {
  dia = 25.2 + 1; // enough tolerance for very easy use
  holder = "M5";
  well_screws = "1/4-20";
  vial_holder(well_diameter = dia, rows = 3 , cols = 3, holder_screws = holder,
      holder_base = 4, well_screws = well_screws);
  translate([0, 0, 30])
    vial_holder(well_diameter = dia, rows = 3 , cols = 3, holder_screws = holder);
  translate([0, 0, 60])
    vial_holder(well_diameter = dia, rows = 3 , cols = 3, holder_screws = holder);
}

// specialized vial holder for GC vials in fraction collector
union() {
  // base vial holder
  width = 98;
  base = 6.5;
  depth = 10;
  dia = 11.7 + 0.5; // enough tolerance for easy use
  vial_holder(holder_base = base, well_depth = depth, well_diameter = dia, well_distance_rows = 15.8, well_distance_cols = 15.8, rows = 6, cols = 15, fixed_rows_width = width);
  // attachment feet
  feet = [25.5, width + 6, base + depth];
  for (x = [-1, 1]) {
    pos = [x * (79-2.1), 0, 0];
    translate(pos)
      difference() {
        xy_center_cube(feet);
        translate([0, 0, -0.1]) xy_center_cube([feet[0] + 0.5, width - 1, feet[2] + 0.2]);
      }
  }
}

// specialized vial holder for 40ml VOA vials in fraction collector tray (assemble two with standoffs)
!union() {
  // base vial holder
  width = 98;
  length = 241.5;
  base = 0;
  depth = 5;
  dia = 27.5 + 0.5; // enough tolerance for easy use
  vial_holder(
    holder_base = base, well_depth = depth, well_diameter = dia,
    well_distance_rows = dia + 3.5, well_distance_cols = dia + 5.75,
    rows = 3, cols = 7,
    fixed_rows_width = width, fixed_cols_width = length,
    holder_screws = "M3",
    holder_edge_screws = 3
  );
  // attachment feet
  feet = [25, width + 6, base + depth];
  for (x = [-1, 1]) {
    translate([x * (79-2.1), 0, 0])
      difference() {
        xy_center_cube(feet);
        translate([0, 0, -0.1]) xy_center_cube([feet[0] + 0.5, width - 1, feet[2] + 0.2]);
      }
  }

  // y tags
  y_tags = [3.5, width + 6, 3.3];
  for (x = [-1, 1]) {
    for (y = [-1, 1]) {
      translate([x * (79-2.1) + y * 41.25/2, 0, 0])
        difference() {
          xy_center_cube(y_tags);
          translate([0, 0, -0.1]) xy_center_cube([y_tags[0] + 0.5, width - 1, y_tags[2] + 0.2]);
        }
    }
  }

  // x tags
  x_tags = [length + 6, 3.5, 3.3];
  for (y = [-1, 1]) {
    translate([0, y * 26.5, 0])
      difference() {
        xy_center_cube(x_tags);
        translate([0, 0, -0.1]) xy_center_cube([length - 1, x_tags[1] + 0.5, x_tags[2] + 0.2]);
      }
  }

}
