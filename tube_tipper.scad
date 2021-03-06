/*
 * Tube holders for rigid tubing (e.g. stainless steel, brass, etc.)
 */

use <utils.scad>;
use <screws.scad>;

// constants
e = 0.01; // small extra for removing artifacts during differencing
2e= 0.02; // twice epsilon for extra length when translating by -e
$fn=60; // number of vertices when rendering cylinders

module tube_tipper(number_tubes = 5) {

  // support feet dimensions
  foot = [20, 5, 10]; // feet dimensions

  // tube holes
  wall_thickness = 10; // width of the walls
  tube_head_gap = 9; // how big a gap for the tube heads
  tube_spacing = 2; // how much space between each tube hole
  tube_diameter = 18.2; // diameter of the tubes
  tube_z_stretch = 1; // how much to stretch in vertical direction to account for printing collapse
  total_width = number_tubes * (tube_diameter + tube_spacing) + tube_spacing + foot[1];
  total_height = 1.75 * tube_spacing + 1 * (tube_diameter + tube_z_stretch);

  // back wall dimensions
  back_wall_thickness = 3;
  back_wall_height = 0.5 * tube_spacing + 0.5 * tube_diameter + tube_z_stretch;
  tube_list = [for (i = [1 : 1 : number_tubes]) i];

  union() {
    difference() {

      // base structure
      xy_center_cube([wall_thickness, total_width, total_height]);

      // tube holes
      for(y = tube_list) {
        for (x = [0, 1]) {
          translate([-wall_thickness,
            (y - (number_tubes+1)/2) * (tube_diameter + tube_spacing),
            -0.5 * (tube_spacing + tube_diameter) + (0.5 + x) * (tube_diameter + tube_z_stretch + tube_spacing)])
          resize([0, 0, tube_diameter + tube_z_stretch])
          rotate([0, 71, 0])
          cylinder(d = tube_diameter, h = 2 * wall_thickness);
        }
      }

    }
    // back wall
    difference() {
      translate([-(wall_thickness - back_wall_thickness)/2, 0, 0])
      xy_center_cube([back_wall_thickness, total_width, back_wall_height]);

      // back wall holes
      for(y = tube_list) {
        translate([-wall_thickness,
            (y - (number_tubes+1)/2) * (tube_diameter + tube_spacing),
            0])
          rotate([0, 71, 0])
          cylinder(d = 0.5 * tube_diameter, h = 2 * wall_thickness);
      }
    }

    // feet
    for (y = [-1, 1]) {
      for (x = [-1, 1]) {
        translate([y * (wall_thickness + foot[0])/2, x * (total_width-foot[1])/2, 0])
        xy_center_cube(foot);
      }
    }
  }


}

// generate a tube tipper
module tube_tipper_old(number_tubes = 10, base_height = 10) {

  // parameters
  tower_depth = 120;
  wall_width = 10; // width of the walls
  tube_head_gap = 9; // how big a gap for the tube heads
  tube_spacing = 4; // how much space between each tube hole
  tube_diameter = 18.2; // diameter of the tubes
  tube_stretch = 1; // how much to stretch in vertical direction to account for printing collapse
  cover_width = 153.5; // 6" width with a little buffer
  cover_thickness = 3.5; // thickness of the acryl cover
  cover_rail_depth = 5; // depth of the cover rails
  cover_wall = 5; // wall in front of the cover

  // constants
  z_plus = 0.1; // how much thicker to make cutouts in z
  hexnut_plus = 0.1; // allow a little extra space for hexnuts

  // derived quantities and shapes
  base_area = [cover_width + 2 * wall_width - 2 * cover_rail_depth, tower_depth];
  tower_height = rows * (tube_diameter + tube_stretch + tube_spacing) + tube_spacing;
  base = [base_area[0], base_area[1], base_height + tower_height];
  front_cut = [base_area[0] - 2 * wall_width, tube_head_gap + cover_thickness + cover_wall + z_plus, tower_height + z_plus];
  cover_cut = [front_cut[0] + 2 * cover_rail_depth, cover_thickness, tower_height + cover_rail_depth + z_plus];
  center_cut = [front_cut[0], base_area[1] - front_cut[1] - 2 * wall_width, tower_height + z_plus];
  side_cut = [base_area[0] + z_plus, center_cut[1], tower_height - wall_width];
  support_height = side_cut[1]/2;
  support = [base_area[0], support_height, support_height];

  // info message
  echo(str("INFO: rendering tower with ", rows, " tube rows"));
  echo(str("INFO: tower dimensions [mm]: width=", base[0], ", depth=", base[1], ", height=", base[2]));
  echo(str("INFO: cover dimensions [mm]: width=", cover_cut[0], ", depth=", cover_cut[1], ", height=", cover_cut[2]));

  difference() {
    // base cube
    xy_center_cube(base);
    // tubes cuts
    row_list = [for (i = [1 : 1 : rows]) i];
    for(y = row_list)
      for (x=[-2.5, -1.5, -0.5, 0.5, 1.5, 2.5])
        translate([x * (tube_diameter + tube_spacing), 0, base_height + (y-0.5) * (tube_diameter + tube_stretch + tube_spacing) + tube_spacing/2])
          resize([0, 0, tube_diameter + tube_stretch])
            rotate([90, 0, 0])
              cylinder(d = tube_diameter, h = base[1] + z_plus, center=true, $fn = 30);
    // front cut
    translate([0, (base_area[1] - front_cut[1])/2 + z_plus, base_height])
      xy_center_cube(front_cut);
    // cover rails cut
    translate([0, (base_area[1] + cover_cut[1])/2 - front_cut[1] + tube_head_gap, base_height - cover_rail_depth])
      xy_center_cube(cover_cut);
    // interior cut
    translate([0, -front_cut[1]/2, base_height])
      union() {
        xy_center_cube(center_cut);
        difference() {
          // sides cut
          xy_center_cube(side_cut);
          // minus supports
          if (supports) {
            for(x=[-1, 1])
              for(y=[-1, 1])
                translate([0, (x * side_cut[1] - x * support[1])/2, (side_cut[2] - support[2])/2 + y * (side_cut[2] - support[2])/2])
                  difference() {
                    xy_center_cube(support);
                    translate([0, -x * support_height/2, support_height/2 - y * support_height/2])
                      rotate([0, 90, 0])
                        cylinder(d = 2 * support_height, h = support[0] + z_plus, center=true, $fn = 60);
                  }
          }
        }
      }
    // platform screws
    translate([0, -front_cut[1]/2, 0])
      union() {
        for (y = [-1, 0, 1])
          for (x = [-2, -1, 0, 1, 2])
            translate([x * screw_distance[0], y * screw_distance[1], base_height + z_plus/2])
              rotate([180, 0, 0])
                machine_screw("1/4-20", base_height + z_plus);
      }
  }

}


// medium tube tipper (5 tubes)
// tube_tipper(5);

// large tube tipper (10 tubes)
tube_tipper(10);