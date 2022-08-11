include <nutsandbolts/cyl_head_bolt.scad>;

// get screw
function get_screw(name) =
  // different screws
  let(screws = [
    // screw name; screw diameter; countersink parameter (head diameter, head depth)
    ["M2", 2, [4.5, 3.0]],
    ["M3", 3, [6, 4.5]],
    ["4-40", 2.9, [5.3, 4.5]],
    ["M4", 4, [8, 5.5]], // NOTE: counter sink dimensions not confirmed
    ["M5", 5, [10, 6.5]], // NOTE: counter sink dimensions not confirmed
    ["1/4-20", 6.35, [13.50, 4.09]], // NOTE: dimensions from mcmaster carr https://www.mcmaster.com/#92210a537/=1did9kw
    ["10-24", 4.83, [10.44, 3.23]] // NOTE: dimensions from mcmaster carr https://www.mcmaster.com/92210A244/
  ])
  screws[search([name], screws)[0]];

// make a machine screw
// @param name which screw
// @param length how long to make the hole maximally
// @param countersink whether to countersink the screw
// @param tolerance what tolerance to add (in mm) to the screw radius
// @param stretch how much to stretch (in mm) the radius in the x direction (to account for collapse in vertical printing), added on top of the tolerance
// @param z_plus how much thicker to make shape in z (for cutouts)
// @param fn $fn parameter
module machine_screw (name, length, countersink = true, invert_countersink = false, tolerance = 0.15, stretch = 0, z_plus = 0, fn = 30) {
  // parameters
  screw = get_screw(name);
  screw_d = screw[1]; // diameter
  screw_cs = screw[2]; // counter snk
  if (countersink && screw_cs[1] > length) {
    echo("warning - length is shorter than countersink cutout");
  }

  union() {
    translate([0, 0, -z_plus])
      resize([screw_d+2*tolerance+2*stretch, 0, 0])
        cylinder(h=length+2*z_plus, d=screw_d+2*tolerance, center=false, $fn=fn);
    if (countersink && invert_countersink) {
      translate([0, 0, length -z_plus])
        rotate([180, 0, 0])
        resize([screw_cs[0]+2*stretch, 0, 0])
          cylinder(h=screw_cs[1], d1=screw_cs[0], d2=0, center=false, $fn=fn);
    } else if (countersink) {
      translate([0, 0, -z_plus])
        resize([screw_cs[0]+2*stretch, 0, 0])
          cylinder(h=screw_cs[1], d1=screw_cs[0], d2=0, center=false, $fn=fn);
    }
  }
}

// make a threaded machine screw --> uses the https://github.com/JohK/nutsnbolts library
// @param name which screw
// @param length how long to make the hole maximally
// @param countersink whether to countersink the screw
// @render_threads true/false whether to render the threads, set the global $render_threads = true; to turn on globally
module threaded_machine_screw (name, length, countersink = false, render_threads = $render_threads) {
  if (countersink) {
    echo("warning - countersink not yet implemented for threaded machine screws");
    // note: this should be possible with the dimensions from the screws library for head diameter and head height!
  }
  translate([0, 0, length])
  if (render_threads) {
    hole_threaded(name = name, thread = "modeled", l = length);
  } else {
    hole_threaded(name = name, thread = "no", l = length);
  }
}

// examples
color("yellow") machine_screw("M3", 5, countersink = false);
color("green") translate([0, 10, 0]) machine_screw("M3", 10);
color("purple") translate([0, 20, 0]) machine_screw("M3", 5, tolerance = 0.5, stretch = 0.5);
color("red") translate([0, -10, 0]) machine_screw("M4", 8);
color("blue") translate([0, -20, 0]) machine_screw("M4", 3, z_plus = 1);



// get hex nut
function get_hexnut(name) =
  // different nuts
  let(nuts = [
    // nut name; nut width (not the radius!); nut thickness
    ["M3", 5.5, 2.4],
    ["M4", 7, 3.2],
    ["M5", 8, 4]
  ])
  nuts[search([name], nuts)[0]];


// make a hexnut
// @param name which hexnut
// @param tolerance what tolerance to add (in mm) to the screw radius
// @param stretch how much to stretch (in mm) the radius in the x direction (to account for collapse in vertical printing), added on top of the tolerance
// @param whether to add a slot for the hexnut (provide in mm total length), default is 0 (i.e. no slot)
// @param z_plus how much thicker to make shape in z (for cutouts)
// @param align whether to align the hexnut to the "bottom" (default), "center" or "top" of the current location (not the bottom)
module hexnut (name, tolerance = 0.025, stretch = 0, slot = 0, z_plus = 0, screw_hole = true, align = "bottom") {
  nut = get_hexnut(name);
  nut_w = nut[1] + 2 * tolerance;
  nut_d = nut_w/cos(180/6); // diameter
  nut_h = nut[2]+2*z_plus; // thickness
  move_z = (align == "top") ? [0, 0, -nut[2]] : ((align == "center") ? [0, 0, -nut[2]/2] : [0, 0, 0]);
  translate([0, 0, -z_plus])
  union() {
    // whether to include a slot for the nut
    if (abs(slot) > 0) {
      translate(move_z)
      translate([-abs(slot)/2 + slot/2, -nut_w/2, 0])
      cube([abs(slot), nut_w, nut_h], center=false);
    }
    // apply stretch to whole nut shape
    resize([nut_d+2*stretch, 0, 0])
      difference() {
        translate(move_z) cylinder(h=nut_h, d=nut_d, center=false, $fn=6);
        if (screw_hole) {
          // generating screw hole with default tolerance
          translate(move_z) machine_screw(name, nut_h, z_plus = 0.1, countersink = false);
        }
      }
  }
}

// examples
color("yellow") translate([10, 0, 0]) hexnut("M3");
color("green") translate([10, 10, 0]) hexnut("M3", z_plus = 0.15);
color("purple") translate([10, 20, 0]) hexnut("M3", 5, tolerance = 0.5, stretch = 1);
color("red") translate([10, -10, 0]) hexnut("M4");
color("blue") translate([10, -20, 0]) hexnut("M4", screw_hole = false);
