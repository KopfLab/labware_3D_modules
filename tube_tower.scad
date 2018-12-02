// balch tube tower for optimizing culturing space in the incubator
use <utils.scad>;
use <screws.scad>;

// generate a tube tower
// @param rows how many rows of tubes (default is 8 for a 40 tube tower)- determines tower height
// @param supports whether to print supports (required for stability of tall towers)
module tube_tower(rows = 8, supports = true) {

  // parameters
  base_height = 15;
  base_area = [150, 150];
  wall_width = 12; // width of the walls
  tube_head_gap = 9; // how big a gap for the tube heads
  tube_spacing = 6; // how much space between each tube hole
  tube_diameter = 18.2; // diameter of the tubes
  tube_stretch = 2; // how much to stretch in vertical direction to account for printing collapse
  cover_thickness = 3.5; // thickness of the acryl cover
  cover_rail_depth = 5; // depth of the cover rails
  cover_wall = 6; // wall in front of the cover
  screw_distance = [30, 30]; // x/y displacement of platform screws

  // constants
  z_plus = 0.1; // how much thicker to make cutouts in z
  hexnut_plus = 0.1; // allow a little extra space for hexnuts

  // derived quantities and shapes
  tower_height = rows * (tube_diameter + tube_stretch + tube_spacing) + tube_spacing;
  base = [base_area[0], base_area[1], base_height + tower_height];
  front_cut = [base_area[0] - 2 * wall_width, tube_head_gap + cover_thickness + cover_wall + z_plus, tower_height + z_plus];
  cover_cut = [front_cut[0] + 2 * cover_rail_depth, cover_thickness, tower_height + cover_rail_depth + z_plus];
  center_cut = [front_cut[0], base_area[1] - front_cut[1] - 2 * wall_width, tower_height + z_plus];
  side_cut = [base_area[0] + z_plus, center_cut[1], tower_height - wall_width];
  support_height = side_cut[1]/2;
  support = [base_area[0], support_height, support_height];

  difference() {
    // base cube
    xy_center_cube(base);
    // tubes cuts
    row_list = [for (i = [1 : 1 : rows]) i];
    for(y = row_list)
      for (x=[-2, -1, 0, 1, 2])
        translate([x * (tube_diameter + tube_spacing), 0, base_height + (y-0.5) * (tube_diameter + tube_stretch + tube_spacing) + tube_spacing/2])
          resize([0, 0, tube_diameter + tube_stretch])
            rotate([90, 0, 0])
              cylinder(d = tube_diameter, h = base[1] + z_plus, center=true, $fn = 60);
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
                        cylinder(d = 2 * support_height, h = support[0] + z_plus, center=true, $fn = 30);
                  }
          }
        }
      }
    // platform screws
    translate([0, -front_cut[1]/2, 0])
      union() {
        for (x=[-1, 0, 1])
          for (y=[-1, 0, 1])
            translate([x * screw_distance[0], y * screw_distance[1], base_height + z_plus/2])
              rotate([180, 0, 0])
                machine_screw("1/4-20", base_height + z_plus);
      }
  }

}


// test print
color("red") translate([200, 0, 0]) tube_tower(2, supports = false);

// big print
!tube_tower(8);
