use <utils.scad>;
use <screws.scad>;

// lcd cutout and screw holes (made on the first child in the stack)
// @param type which type of LCD, see types below for supported types
// @param location where the lcd should be centered
module LCD(type = "16x2", location = [0,0,0]) {

  // check if there are children (needs at least one to place LCD)
  if ($children == 0) {
    echo("WARNING - need at least one child to build LCD into");
  }

  // parameters
  z_plus = 0.1; // how much thicker to make cutouts in z

  // different types of supported LCDs
  types = [
    // name; lcd w, h, thickness (-pcb); lcd center offset (rel. to screws); screw type, x, y, tolerance; screw socket diamter
    ["16x2", [71.8, 24.8, 7], [0, -0.3, 0], ["M3", 37.5, 15.5, 0.35], 6],
    ["20x4", [80.5, 40.2, 7], [0, -0.3, 0], ["M3", 37.5, 25.5, 0.35], 6] // FIXME not exact
  ];
  type_idx = search([type], types)[0];

  if (len(type_idx) == 0) {
    echo(str("cannot render LCD - unrecognized type '", type , "'"));
  } else {
    echo(str("rendering LCD type '", type , "'"));

    // information text (not visible in rendered version - % modifier)
    %translate(location)
    {
      translate([0, 1, 0])
      text("this way up + inside", size = 5, valign = "bottom",
        halign = "center");
      translate([0, -1, 0])
      text(str(type, " LCD"), size = 5, valign = "top",
        halign = "center");
    }

    // parameters
    lcd_size = types[type_idx][1];
    lcd_offset = types[type_idx][2];
    screws = types[type_idx][3];
    screw_socket_d = types[type_idx][4];

    difference() {
      union() {
        children(0);
        translate(location) {
          // screw sockets
          for(x=[-1, 1])
            for(y=[-1, 1])
              translate([x*screws[1], y*screws[2], 0])
                cylinder(h=lcd_size[2], d=screw_socket_d, center = false, $fn=30);
        }
      }
      translate(location) {
        // screw holes
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*screws[1], y*screws[2], 0])
              screw_hole(screws[0], lcd_size[2], tolerance = screws[3], z_plus = z_plus);

        // lcd cutout
        translate(lcd_offset)
          translate([0, 0, -z_plus])
          resize([0, 0, lcd_size[2] + 2*z_plus])
          xy_center_cube(lcd_size);
      }
    }
  }
}


// example
color("red")
LCD(type = "16x2", location = [0, 35, 0])
LCD(type = "20x4", location = [0, -30, 0])
xy_center_cube([100, 140, 4]);
