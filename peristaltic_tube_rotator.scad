// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = $preview ? 30 : 90; // number of default vertices when rendering cylinders
nylon_tol = 0.1; // extra tolerance for carbon fibre nylon parts shrinkage

/** general print settings **/

$extra_tolerance = 2 * nylon_tol; // for cutouts, shaft holes, etc.
$layer_height = 0.25;
$nozzle = 0.4; // nozzle width for spacing decisions (= line width)
$slit = 0.05; // width of print enhancement slits

/** rotator settings **/

// central hub
$hub_wall = 8 * $nozzle; // wall thickness around the shaft hole (in line widths)
$hub_height = 35; // total height of the hub

// D-shaft (stainless steel motor shaft)
$shaft_diameter = 6.7; // diameter of the round part of the D shaft
$shaft_flat_thickness = 6; // distance from the flat to the opposite side of the shaft
$shaft_tolerance = $extra_tolerance; // buffer so the hub slides onto the shaft

// spokes
$spoke_count = 12; // number of spokes
$spoke_length = 60; // distance from the hub center to the center of the tube rings
$spoke_height = 5; // height of the spokes and rings
$spoke_width = 8 * $nozzle; // thickness of the spokes (in line widths)
$spoke_z = 0; // height of the spokes' bottom above the hub's bottom

// print enhancement slits in the hub
$slit_angle = 180 / $spoke_count; // angle of the lower slit (default: halfway between the first two spokes)
$slit_split_z = $spoke_z + $spoke_height; // lower slit goes up to here, the opposite upper slit continues from here

// tube rings at the end of the spokes
$ring_inner_diameter = 10.5; // inner diameter of the rings
$ring_tolerance = $extra_tolerance; // extra on the inner diameter for nylon shrinkage
$ring_wall = 4 * $nozzle; // ring wall thickness (in line widths)
$ring_opening = 1; // width of the gap on the outer side of the rings (0 = fully closed)

/** derived values **/

$shaft_hole_diameter = $shaft_diameter + $shaft_tolerance;
$shaft_hole_flat = $shaft_flat_thickness + $shaft_tolerance;
$hub_diameter = $shaft_hole_diameter + 2 * $hub_wall; // outer diameter of the hub
$ring_hole_diameter = $ring_inner_diameter + $ring_tolerance;
$ring_outer_diameter = $ring_hole_diameter + 2 * $ring_wall;

/** modules **/

// D-shaped 2D profile, flat side towards +x
module d_shaft_profile(diameter = $shaft_hole_diameter, flat = $shaft_hole_flat) {
  intersection() {
    circle(d = diameter);
    // keep everything from the far side up to the flat
    translate([-diameter/2 - $e, -diameter/2 - $e])
      square([flat + $e, diameter + $2e]);
  }
}

// one spoke with its open ring at the end (pointing along +x)
module spoke() {
  difference() {
    union() {
      // spoke arm (starts at the center so it fuses with the hub)
      translate([0, -$spoke_width/2, 0])
        cube([$spoke_length, $spoke_width, $spoke_height]);
      // ring
      translate([$spoke_length, 0, 0])
        cylinder(d = $ring_outer_diameter, h = $spoke_height);
    }
    // ring hole
    translate([$spoke_length, 0, -$e])
      cylinder(d = $ring_hole_diameter, h = $spoke_height + $2e);
    // ring opening on the outer side
    if ($ring_opening > 0)
      translate([$spoke_length, -$ring_opening/2, -$e])
        cube([$ring_outer_diameter/2 + $e, $ring_opening, $spoke_height + $2e]);
  }
}

module peristaltic_tube_rotator(slits = true) {
  difference() {
    union() {
      // central hub
      cylinder(d = $hub_diameter, h = $hub_height);
      // spokes
      for (i = [0 : $spoke_count - 1])
        rotate([0, 0, i * 360 / $spoke_count])
          translate([0, 0, $spoke_z])
            spoke();
    }
    // D-shaft hole all the way through
    translate([0, 0, -$e])
      linear_extrude($hub_height + $2e)
        d_shaft_profile();
    // print enhancement slits through the hub wall
    if (slits) {
      // lower slit between two spokes, up to the top of the spokes
      rotate([0, 0, $slit_angle])
        translate([0, -$slit/2, -$e])
          cube([$hub_diameter/2 + $e, $slit, $slit_split_z + $e]);
      // upper slit on the opposite side, from the top of the spokes to the top of the hub
      rotate([0, 0, $slit_angle + 180])
        translate([0, -$slit/2, $slit_split_z])
          cube([$hub_diameter/2 + $e, $slit, $hub_height - $slit_split_z + $e]);
    }
  }
}

/** standard prints **/

peristaltic_tube_rotator();

