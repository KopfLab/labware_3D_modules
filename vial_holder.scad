// balch tube tower for optimizing culturing space in the incubator
use <utils.scad>;
use <screws.scad>;

// Generate vial holders
//
// Module for generic vial holder. All measurements are in mm.
//
// @param holder_base thickness of holder base (if any)
// @param well_depth depth of each well
// @param well_diameter diameter of each well
// @param well_gap gap between neighboring wells (can be overriden with well distances below)
// @param well_distance_rows center-to-center distance of wells along the rows (by default defined via well gap)
// @param well_distance_cols center-to-center distance of wells along the columns (by default defined via well gap)
// @param rows number of rows
// @param cols number of colums
// @param fixed_cols_width fixed width of holder (by default is calculated autmatically from cols)
// @param fixed_rows_width fixed height of holder (by default is calculated autmatically from rows)
// @param attachments what kind of hexnut and screws to use for attachment locations (use false if none)
module vial_holder(
  holder_base = 0,
  well_depth = 4, well_diameter = 12, well_gap = 4,
  well_distance_rows = false, well_distance_cols = false,
  rows = 5, cols = 5,
  fixed_rows_width = false, fixed_cols_width = false,
  attachments = "M4") {

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
        translate([(x - (cols + 1)/2) * well_distance_cols, (y - (rows + 1)/2) * well_distance_rows, holder_base + well_depth/2])
          cylinder(d = well_diameter, h = well_depth + z_plus, center=true, $fn = 60);
    // attachment screws
    if (attachments) {
      row_list = [for (i = [1 : 1 : (rows-1)]) i];
      col_list = [for (i = [1 : 1 : (cols-1)]) i];
      for (y = row_list)
        for (x = col_list)
          translate([(x + 0.5 - (cols + 1)/2) * well_distance_cols, (y + 0.5 - (rows + 1)/2) * well_distance_rows, 0])
          union() {
            hexnut(attachments, screw_hole = false, z_plus = z_plus, tolerance = 0.025, align = "center");
            machine_screw(attachments, length = base[2], tolerance = 0.15, z_plus = z_plus, countersink = false);
          }
    }
  }
}

// example default vial holder with base and 2 layers
translate([100, 0, 0]) color("gray") vial_holder(well_diameter = 15.2, holder_base = 4);
translate([100, 0, 30]) color("gray") vial_holder(well_diameter = 15.2);
translate([100, 0, 60]) color("gray") vial_holder(well_diameter = 15.2);

// specialized vial holder for GC vials in fraction collector
union() {
  vial_holder(holder_base = 6.5, well_depth = 10, well_diameter = 11.5, well_distance_rows = 15.8, well_distance_cols = 15.8, rows = 6, cols = 5, fixed_rows_width = 98);
  translate([2.1, 0, 0]) xy_center_cube([25.5, 104, 3]); // add feet
}
