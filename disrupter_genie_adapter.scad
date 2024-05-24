// disruptor genie adapters
use <utils.scad>;
use <screws.scad>;

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres

// common sizes
$ga_base_thickness = 1.0; // thickness of the base
$ga_vial_diameter = 11.7 + 0.8; // with tolerance
$ga_vial_distance = 0.5 * (75+53)/2; // distance from center
$ga_vial_wall = 1.0; // thickness of the vial wall
$ga_outer_diameter = 2 *($ga_vial_distance + $ga_vial_diameter/2 + $ga_vial_wall);
$ga_inner_diameter = 2 *($ga_vial_distance - $ga_vial_diameter/2 - $ga_vial_wall);
$ga_cut_to_vial = 4; // thickness of cut to vial holder (for better printing)
$ga_vial_height = 8.0; // height of the vial holder hole/compartment
$ga_n_vials = 12; // how many vials in a circle
$ga_screw_diameter = 7.0; // hole for attachment screws

// generate genie adapater
// @param cut_in_half whether to print only half of the adapter (for easier assembly)
module genie_adapter(cut_in_half = false, walls = true, holders = false, base = false) {

  difference(){
    union() {
      // base
      if (base)
        cylinder(d = $ga_outer_diameter, h = $ga_base_thickness);
      // inner ring
      translate([0, 0, 0])
        cylinder(d = $ga_inner_diameter + 2 * $ga_vial_wall, h = $ga_base_thickness + $ga_vial_height);
      // outer ring
      if (walls)
        difference() {
          cylinder(d = $ga_outer_diameter, h = $ga_base_thickness + $ga_vial_height);
          translate([0, 0, -$e])
          cylinder(d = $ga_outer_diameter - 2 * $ga_vial_wall, h = $ga_base_thickness + $ga_vial_height + $2e);
        }
      // vial holds
      if (holders)
        for (i = [1:1:$ga_n_vials]) {
          translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), $ga_base_thickness])
            cylinder(d = $ga_vial_diameter + 2 * $ga_vial_wall, h = $ga_vial_height);
        }
      // compartment walls
      if (walls)
        for (i = [1:1:$ga_n_vials/2]) {
          rotate([0, 0, 180/$ga_n_vials + i * 360/$ga_n_vials])
          translate([0, 0, ($ga_base_thickness + $ga_vial_height)/2])
          cube([$ga_outer_diameter, $ga_vial_wall, $ga_base_thickness + $ga_vial_height], center = true);
        }
    }
    // inner ring cutout
    translate([0, 0, -$e])
      cylinder(d = $ga_inner_diameter, h = $ga_base_thickness + $ga_vial_height + $2e);
    // vial holds cutouts
    for (i = [1:1:$ga_n_vials]) {
      translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), -$e])
        cylinder(d = $ga_screw_diameter, h = $ga_base_thickness + $2e);
      if (holders)
        translate([$ga_vial_distance * cos((i-1) * 360/$ga_n_vials), $ga_vial_distance * sin((i-1) * 360/$ga_n_vials), $ga_base_thickness])
          cylinder(d = $ga_vial_diameter, h = $ga_vial_height + $e);
      translate([$ga_outer_diameter/2 * cos((i-1) * 360/$ga_n_vials), $ga_outer_diameter/2 * sin((i-1) * 360/$ga_n_vials), $ga_vial_height/2 + $e + $ga_base_thickness])
        rotate([0, 0, (i-1) * 360/$ga_n_vials])
          cube([4 * $ga_vial_wall, $ga_cut_to_vial, $ga_vial_height + $2e], center = true);
    }
    // only half?
    if (cut_in_half) {
      translate([0, $ga_outer_diameter/2 + $e, ($ga_base_thickness + $ga_vial_height)/2])
          cube([2 * $ga_outer_diameter, $ga_outer_diameter + $2e, $ga_base_thickness + $ga_vial_height + $2e], center = true);
    }

    rotate([0, 0, -180/$ga_n_vials + 0.7])
      translate([0, 0, -$e])
        rotate_extrude(angle = (360/$ga_n_vials - 1.4)) square([$ga_outer_diameter, $ga_base_thickness + $ga_vial_height + $2e]);

  }

}

// parameters
$ga_lid_base = 1.0; // thickness of lid
$ga_lid_wall = 1.0; // thickness of lid walls
$ga_lid_spindle_diameter = 6.35 + 0.4; // spindle in center
$ga_spindle_height = 9; // lid spindle height
$ga_lid_inner_diameter = $ga_inner_diameter - 3.0; // inner diameter wall for lid offset
$ga_lid_height = 14; // lid height

module genie_lid() {
  difference(){
    union() {
      // outer ring
      cylinder(d = $ga_outer_diameter, h = $ga_lid_base);
      // middle ring
      difference() {
        cylinder(d = $ga_lid_inner_diameter, h = $ga_lid_base + $ga_lid_height);
        translate([0, 0, -$e])
        cylinder(d = $ga_lid_inner_diameter - 2 * $ga_lid_wall, h = $ga_lid_base + $ga_lid_height + $2e);
      }
      // inner ring
      translate([0, 0, 0])
        cylinder(d = $ga_lid_spindle_diameter + 2 * $ga_lid_wall, h = $ga_lid_base + $ga_spindle_height);
      // spokes
      difference() {
        for (i = [1:1:$ga_n_vials/2]) {
          rotate([0, 0, 180/$ga_n_vials + i * 360/$ga_n_vials])
          translate([0, 0, ($ga_lid_base + $ga_lid_height)/2])
          cube([$ga_outer_diameter, $ga_vial_wall, $ga_lid_base + $ga_lid_height], center = true);
        }
        translate([0, 0, -$e])
          cylinder(d = $ga_lid_inner_diameter - 2 * $ga_lid_wall, h = $ga_lid_base + $ga_lid_height + $2e);
      }
      // central connectors
      rotate([0, 0, 3 * 180/$ga_n_vials])
        translate([0, 0, ($ga_lid_base + $ga_spindle_height)/2])
          cube([$ga_lid_inner_diameter, $ga_vial_wall, $ga_lid_base + $ga_spindle_height], center = true);
    }
    // central cutout
    translate([0, 0, -$e])

      cylinder(d = $ga_lid_spindle_diameter, h = $ga_lid_height + $ga_lid_base + $2e);
    // screw  holes
    /*for (x = [-1, 1]) {
      translate([x * $ga_vial_distance, 0, -$e])
        cylinder(d = $ga_screw_diameter, h = $ga_lid_height + $2e);
    }
    for (y = [-1, 1]) {
      translate([0, y * $ga_vial_distance, -$e])
        cylinder(d = $ga_screw_diameter, h = $ga_lid_height + $2e);
    }*/
  }
}

// beater adapater sizes
$ba_base_diameter = 145; // location for the vials
$ba_base_ring = 128; // inner support ring
$ba_base_max_height = 12.5;
$ba_base_min_height = 9;
$ba_base_screw_height = 6; // leaving 3mm for the screw head
$ba_base_hole_diameter = 10.5;
$ba_wall = 0.9;
$ba_vial_diameter = 11.7 + 0.5; // gc vial diameter plus tolerance
$ba_vial_n = 24;
$ba_vials_effective = 5; // arc for how many vials to actually show
$ba_spokes = 0.1;
$ba_screw_diameter = 3.0;
$ba_screw_hole_extra = 0.8; // extra diameter for screw hole (for easy screw threading)
$ba_screw_bridge = 3; // distance from rings to the screws

module beater_adapter() {

  // calculat screw location
  outer_screw_location = $ba_base_diameter/2 + $ba_vial_diameter/2 + $ba_wall + $ba_screw_bridge + $ba_wall + $ba_screw_diameter/2;
  inner_screw_location = $ba_base_diameter/2 - $ba_vial_diameter/2 - $ba_wall - $ba_screw_bridge - $ba_wall - $ba_screw_diameter/2;

  difference() {
    union() {

      difference() {

        union() {

          // inner ring
          difference() {
            cylinder(d = $ba_base_ring + 2 * $ba_wall, $ba_base_min_height);
            translate([0, 0, -$e]) cylinder(d = $ba_base_ring, $ba_base_min_height + $2e);
          }

          // spokes to hole adapters
          difference() {
            for (i = [1:1:$ba_vial_n/2]) {
              rotate([0, 0, (i - 0.5) * 360/$ba_vial_n])
                translate([0, 0, $ba_base_min_height/2])
                  cube([$ba_base_diameter - $ba_base_hole_diameter + $ba_wall, 3 * $ba_wall + 2 * $ba_spokes, $ba_base_min_height], center = true);
            }
            translate([0, 0, -$e]) cylinder(d = $ba_base_ring, $ba_base_min_height + $2e);
          }

          // spokes to outer screw holes
          difference() {
            for (i = [1:1:$ba_vial_n/4]) {
              rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
                translate([0, 0, $ba_base_screw_height/2])
                  cube([2 * outer_screw_location, 2 * $ba_wall + $ba_spokes, $ba_base_screw_height], center = true);
            }
            translate([0, 0, -$e]) cylinder(d = $ba_base_diameter, $ba_base_min_height + $2e);
          }

          // spokes to inner screw holes
          difference() {
            for (i = [1:1:$ba_vial_n/4]) {
              rotate([0, 0, (2 * i) * 360/$ba_vial_n])
                translate([0, 0, $ba_base_screw_height/2])
                  cube([$ba_base_ring, 2 * $ba_wall + $ba_spokes, $ba_base_screw_height], center = true);
            }
            translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location, $ba_base_min_height + $2e);
          }

          // hole adapters
          difference() {
            // walls
            for (i = [1:1:$ba_vial_n]) {
              translate([$ba_base_diameter/2 * cos( (i-0.5) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-0.5) * 360/$ba_vial_n), 0])
                cylinder(d = $ba_base_hole_diameter, h = $ba_base_max_height);
            }
            // center cutout
            for (i = [1:1:$ba_vial_n]) {
              translate([$ba_base_diameter/2 * cos( (i-0.5) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-0.5) * 360/$ba_vial_n), -$e])
                cylinder(d = $ba_base_hole_diameter - 2 * $ba_wall, h = $ba_base_min_height + $e);
            }
          }

          // vial holders
          for (i = [1:1:$ba_vial_n]) {
            translate([$ba_base_diameter/2 * cos((i-1) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-1) * 360/$ba_vial_n), 0])
              cylinder(d = $ba_vial_diameter + 2 * $ba_wall, h = $ba_base_min_height);
          }

          // outer screw holes
          for (i = [1:1:$ba_vial_n/2]) {
            translate([outer_screw_location * cos((2 * i-1) * 360/$ba_vial_n), outer_screw_location * sin((2 * i-1) * 360/$ba_vial_n), 0])
              cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra + 2 * $ba_wall, h = $ba_base_screw_height);
          }

          // inner screw holes
          for (i = [1:1:$ba_vial_n/2]) {
            translate([inner_screw_location * cos((2 * i) * 360/$ba_vial_n), inner_screw_location * sin((2 * i) * 360/$ba_vial_n), 0])
              cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra + 2 * $ba_wall, h = $ba_base_screw_height);
          }
        }

        // spokes cutout to all holes
        difference() {
          union() {
            for (i = [1:1:$ba_vial_n/2]) {
              rotate([0, 0, (2 * i) * 360/$ba_vial_n])
                translate([0, 0, $ba_base_min_height/2])
                  cube([$ba_base_diameter, $ba_spokes, $ba_base_min_height + $2e], center = true);
            }
            for (i = [1:1:$ba_vial_n]) {
              rotate([0, 0, (i - 0.5) * 360/$ba_vial_n])
                translate([0, 0, $ba_base_min_height/2])
                  cube([$ba_base_diameter, $ba_wall + 2 * $ba_spokes, $ba_base_min_height + $2e], center = true);
            }
          }
          translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location, $ba_base_min_height + $2e);
        }

        // spokes cutout to outer screw holes
        difference() {
          for (i = [1:1:$ba_vial_n/4]) {
            rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
              translate([0, 0, $ba_base_min_height/2])
                cube([2 * outer_screw_location, $ba_spokes, $ba_base_min_height + $2e], center = true);
          }
          translate([0, 0, -$e]) cylinder(d = $ba_base_ring + 2 * $ba_wall, $ba_base_min_height + $2e);
        }
        for (i = [1:1:$ba_vial_n/4]) {
          rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
            translate([0, 0, $ba_base_screw_height/2])
              cube([2 * outer_screw_location, $ba_spokes, $ba_base_screw_height + $2e], center = true);
        }

        // spokes cutout to inner screw holes
        difference() {
          for (i = [1:1:$ba_vial_n/4]) {
            rotate([0, 0, (2 * i) * 360/$ba_vial_n])
              translate([0, 0, $ba_base_screw_height/2])
                cube([2 * outer_screw_location, $ba_spokes, $ba_base_screw_height + $2e], center = true);
          }
          translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location, $ba_base_min_height + $2e);
        }

        // vial holes
        for (i = [1:1:$ba_vial_n]) {
          translate([$ba_base_diameter/2 * cos((i-1) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-1) * 360/$ba_vial_n), -$e])
            cylinder(d = $ba_vial_diameter, h = $ba_base_max_height + $2e);
        }

        // outer screw holes
        for (i = [1:1:$ba_vial_n/2]) {
          translate([outer_screw_location * cos((2 * i-1) * 360/$ba_vial_n), outer_screw_location * sin((2 * i-1) * 360/$ba_vial_n), -$e])
            cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra, h = $ba_base_screw_height + $2e);
        }

        // inner screw holes
        for (i = [1:1:$ba_vial_n/2]) {
          translate([inner_screw_location * cos((2 * i) * 360/$ba_vial_n), inner_screw_location * sin((2 * i) * 360/$ba_vial_n), -$e])
            cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra, h = $ba_base_screw_height + $2e);
        }
      }
      // inside spokes
      for (i = [1:1:$ba_vial_n/2]) {
        rotate([0, 0, (i - 0.5) * 360/$ba_vial_n])
          translate([0, 0, $ba_base_min_height/2])
            cube([$ba_base_diameter + $ba_base_hole_diameter - $ba_wall/2, $ba_wall, $ba_base_min_height], center = true);
      }
    }
    // cutoff for insides spokes
    translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location - $ba_screw_diameter - $ba_screw_hole_extra - 2 * $ba_wall, $ba_base_min_height + $2e);
    // wedge only
    radius = 2 * outer_screw_location;
    //angles = [4, 56];
    angles = [4,  ($ba_vials_effective + 1) * 15 - 4];
    translate([0, 0, -$e])
      linear_extrude($ba_base_max_height + $2e)
        difference() {
          circle(r = radius + $2e);
          polygon(concat([[0, 0]], [for(a = angles) [radius * cos(a), radius * sin(a)]]));
        }

  }

}

$ba_lid_thickness = 0; // thickness of the lid
$ba_lid_height = 16; // + the 9mm base = 25mm total, i.e. vial minus caps
$ba_lid_screw_height = 6; // plus 10mm for the hex adapter

module beater_lid() {

  // calculat screw location
  outer_screw_location = $ba_base_diameter/2 + $ba_vial_diameter/2 + $ba_wall + $ba_screw_bridge + $ba_wall + $ba_screw_diameter/2;
  inner_screw_location = $ba_base_diameter/2 - $ba_vial_diameter/2 - $ba_wall - $ba_screw_bridge - $ba_wall - $ba_screw_diameter/2;
  ring_location = $ba_base_diameter/2 + $ba_vial_diameter/2 + $ba_wall + $ba_screw_bridge/2;
  total_height = $ba_lid_thickness + $ba_lid_height;
  screws_height = $ba_lid_thickness + $ba_lid_screw_height;

  difference() {

    union() {

      // connector ring
      difference() {
        cylinder(d = 2 * ring_location + $ba_wall, total_height);
          translate([0, 0, -$e])
            cylinder(d = 2 * ring_location - $ba_wall, total_height + $2e);
      }

      // spokes for vials
      difference() {
        union() {
          // thick bottom + thin top for holders with inner screws
          for (i = [1:1:$ba_vial_n/4]) {
            rotate([0, 0, i * 360/$ba_vial_n])
              translate([0, 0, screws_height/2])
                cube([2 * ring_location, 2 * $ba_wall + $ba_spokes, screws_height], center = true);
            rotate([0, 0, 2 * i * 360/$ba_vial_n])
              translate([0, 0, (total_height + screws_height)/2])
                cube([2 * ring_location, $ba_wall, (total_height - screws_height)], center = true);
          }
          // thick spokes for holders with outer screws
          for (i = [1:1:$ba_vial_n/4]) {
            rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
              translate([0, 0, total_height/2])
                cube([2 * ring_location, 2 * $ba_wall + $ba_spokes, total_height], center = true);
          }
        }
        translate([0, 0, -$e]) cylinder(d = $ba_base_diameter, total_height + $2e);
      }

      // spokes to outer screws
      difference() {
        for (i = [1:1:$ba_vial_n/4]) {
          rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
            translate([0, 0, screws_height/2])
              cube([2 * outer_screw_location, 2 * $ba_wall + $ba_spokes, screws_height], center = true);
        }
        translate([0, 0, -$e]) cylinder(d = $ba_base_diameter, screws_height + $2e);
      }

      // spokes to inner screws
      difference() {
        for (i = [1:1:$ba_vial_n/4]) {
          rotate([0, 0, (2 * i) * 360/$ba_vial_n])
            translate([0, 0, screws_height/2])
              cube([$ba_base_diameter, 2 * $ba_wall + $ba_spokes, screws_height], center = true);
        }
        translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location, screws_height + $2e);
      }

      // vial holders
      for (i = [1:1:$ba_vial_n]) {
        translate([$ba_base_diameter/2 * cos((i-1) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-1) * 360/$ba_vial_n), 0])
          cylinder(d = $ba_vial_diameter + 2 * $ba_wall, h = total_height);
      }

      // outer screw holders
      for (i = [1:1:$ba_vial_n/2]) {
        translate([outer_screw_location * cos((2 * i-1) * 360/$ba_vial_n), outer_screw_location * sin((2 * i-1) * 360/$ba_vial_n), 0])
          cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra + 2 * $ba_wall, h = screws_height);
      }

      // inner screw holders
      for (i = [1:1:$ba_vial_n/2]) {
        translate([inner_screw_location * cos((2 * i) * 360/$ba_vial_n), inner_screw_location * sin((2 * i) * 360/$ba_vial_n), 0])
          cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra + 2 * $ba_wall, h = screws_height);
      }
    }
    // spokes cutout to outer screw holes
      // low cut
      for (i = [1:1:$ba_vial_n/4]) {
        rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
          translate([0, 0, screws_height/2])
            cube([2 * outer_screw_location, $ba_spokes, screws_height + $2e], center = true);
      }
      // high cut
      translate([0, 0, screws_height])
      difference() {
        for (i = [1:1:$ba_vial_n/2]) {
          rotate([0, 0, (2 * i - 1) * 360/$ba_vial_n])
            translate([0, 0, total_height/2])
              cube([2 * outer_screw_location, $ba_spokes, total_height + $2e], center = true);
        }
        translate([0, 0, -$e]) cylinder(d = $ba_base_diameter, total_height + $2e);
      }

    // spokes cutout to inner screw holes
    difference() {
      union() {
        for (i = [1:1:$ba_vial_n/4]) {
          // low cu
          rotate([0, 0, 2 * i * 360/$ba_vial_n])
            translate([0, 0, screws_height/2])
              cube([2 * outer_screw_location, $ba_spokes, screws_height + $2e], center = true);
          // high cut
          rotate([0, 0, 2 * i * 360/$ba_vial_n])
            translate([0, 0, total_height/2])
              cube([$ba_base_diameter, $ba_spokes, total_height + $2e], center = true);
        }
      }
      translate([0, 0, -$e]) cylinder(d = 2 * inner_screw_location, screws_height + $2e);
    }

    // vial holes
    for (i = [1:1:$ba_vial_n]) {
      translate([$ba_base_diameter/2 * cos((i-1) * 360/$ba_vial_n), $ba_base_diameter/2 * sin((i-1) * 360/$ba_vial_n), $ba_lid_thickness - $e])
        cylinder(d = $ba_vial_diameter, h = total_height - $ba_lid_thickness + $2e);
    }

    // outer screw holes
    for (i = [1:1:$ba_vial_n/2]) {
      translate([outer_screw_location * cos((2 * i-1) * 360/$ba_vial_n), outer_screw_location * sin((2 * i-1) * 360/$ba_vial_n), -$e])
        cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra, h = screws_height + $2e);
    }

    // inner screw holes
    for (i = [1:1:$ba_vial_n/2]) {
      translate([inner_screw_location * cos((2 * i) * 360/$ba_vial_n), inner_screw_location * sin((2 * i) * 360/$ba_vial_n), -$e])
        cylinder(d = $ba_screw_diameter + $ba_screw_hole_extra, h = screws_height + $2e);
    }

    // wedge only
    radius = 2 * outer_screw_location;
    angles = [8,  ($ba_vials_effective + 1) * 15 - 8];
    translate([0, 0, -$e])
      linear_extrude(total_height + $2e)
        difference() {
          circle(r = radius + $2e);
          polygon(concat([[0, 0]], [for(a = angles) [radius * cos(a), radius * sin(a)]]));
        }

  }

}

//beater_adapter();
beater_lid();
//genie_adapter();
//genie_lid();
