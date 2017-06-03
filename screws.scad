// get screw
function get_screw(name) =
  // different screws
  let(screws = [
    // screw diameter; countersink parameter (head diameter, head depth)
    ["M3", 3, [6, 4.5]],
    ["M4", 4, [8, 5.5]] // NOTE: dimensions not confirmed
  ])
  screws[search([name], screws)[0]];

// make a screw hole
// @param screw which screw
// @param length how long to make the hole maximally
// @param countersink whether to countersink the screw
// @param tolerance what tolerance to build in [mm] on all sides
// @param fn $fn parameter
// @param z_plus how much thicker to make shape in z (for cutouts)
module screw_hole (name, length, countersink = true, tolerance = 0.25, fn = 30, z_plus = 0.1) {
  // parameters
  screw = get_screw(name);
  screw_d = screw[1]; // diameter
  screw_cs = screw[2]; // counter snk
  if (countersink && screw_cs[1] > length) {
    echo("warning - length is shorter than countersink cutout");
  }

  union() {
    translate([0, 0, -z_plus]) cylinder(h=length+2*z_plus, d=screw_d+2*tolerance, center=false, $fn=fn);
    if (countersink) {
      translate([0, 0, -z_plus]) cylinder(h=screw_cs[1], d1=screw_cs[0], d2=0, center=false, $fn=fn);
    }
  }
}

// examples (commented out so can include this file in others)
screw_hole("M3", 5, countersink = false);
color("green") translate([0, 10, 0]) screw_hole("M3", 10, countersink = true);
color("red") translate([0, -10, 0]) screw_hole("M4", 8);
color("blue") translate([0, -20, 0]) screw_hole("M4", 3, z_plus = 1);
