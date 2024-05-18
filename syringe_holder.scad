// syringe holders for the picarro manual infusion
use <utils.scad>;
use <screws.scad>;

// constants
$e = 0.01; // small extra for removing artifacts during differencing
$2e = 2 * $e; // twice epsilon for extra length when translating by -e
$fn = 60; // number of vertices when rendering cylinders and spheres
$screw_tolerance = 0.2; // t-glass tolerance
$nut_tolerance = 0.05; // t-glass tolerance

// common sizes
$sh_rim_thickness = 2; // minimum thickness of the holder rim
$sh_base_thickness = 5; // thickness of the base
$sh_base_nut_min = 2; // nut min elevation from base
$sh_front_thickness = 2; // thickness of the ront holder

// generate syringe holder
// @param syringe_skirt the size of the front skirt (inward from the diameter rim)
// @param syringe_ring the width of the ring
module syringe_holder(syringe_diameter_front, syringe_diameter_back, syringe_diameter_front_end, syringe_length, syringe_skirt, syringe_bed, syringe_ring, syringe_ring_height = 0.8) {

  total_width = syringe_diameter_front + 2 * $sh_rim_thickness;
  difference() {
    // base
    union() {
      // base
      xy_center_cube([syringe_length, total_width, syringe_diameter_front/2 + $sh_base_thickness]);
      // ring
      translate([syringe_length/2 - syringe_ring, 0, syringe_diameter_front/2 + $sh_base_thickness])
        rotate([0, 90, 0])
          cylinder(d = total_width, h = syringe_ring);
    }
    // syringe cutout front
    translate([-$sh_front_thickness, 0, syringe_diameter_front/2 + $sh_base_thickness])
      rotate([0, 90, 0])
        cylinder(d = syringe_diameter_front, h = syringe_length/2);
    // skirt cutout
    translate([$e, 0, syringe_diameter_front/2 + $sh_base_thickness])
      rotate([0, 90, 0])
        cylinder(d = syringe_diameter_front - 2 * syringe_skirt, h = syringe_length/2);
    // ring top cutoff
    translate([syringe_length/2 - syringe_ring/2 - $sh_front_thickness, 0, syringe_ring_height * (syringe_diameter_front + $sh_rim_thickness) + $sh_base_thickness])
      xy_center_cube([syringe_ring + $2e, total_width + $2e, total_width + $2e]);
    // bed cutout
    if (2 * syringe_bed < syringe_length) {
      translate([0, 0, $sh_base_thickness])
      xy_center_cube([syringe_length - 2 * syringe_bed, total_width + $2e, syringe_diameter_front/2 + $e]);
    }
    // stringe cutout back
    translate([-syringe_length/2 - $e, 0, syringe_diameter_front/2 + $sh_base_thickness])
      rotate([0, 90, 0])
        cylinder(d = syringe_diameter_back, h = syringe_length/2);
    // hex nut cutout
    nut = "M4";
    nut_width = get_hexnut(nut)[1];
    for (x = [-1, 1]) {
      for (y = [-1, 1]) {
        translate([x * syringe_length/4, y * ((total_width - nut_width)/2 - $sh_rim_thickness), -$e])
          machine_screw(nut, length = $sh_base_thickness + $2e, countersink = false, tolerance = $screw_tolerance);
        translate([x * syringe_length/4, y * ((total_width - nut_width)/2 - $sh_rim_thickness), $sh_base_nut_min])
          hexnut(nut, align = "bottom", screw_hole = false, tolerance = $nut_tolerance);
      }
    }
  }
}

// large 100mL syringe for picarro
syringe_holder(
  syringe_diameter_front = 44,
  syringe_diameter_back = 41,
  syringe_length = 145,
  syringe_skirt = 4,
  syringe_bed = 25,
  syringe_ring = 14
);
