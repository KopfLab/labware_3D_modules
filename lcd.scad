use <utils.scad>;
use <screws.scad>;

// lcd cutout and screw holes (made on the first child in the stack)
// @param type which type of LCD, see types below for supported types
// @param location where the lcd should be centered
module LCD(type = "16x2", location = [0,0,0], rotation = [0,0,0]) {

  // check if there are children (needs at least one to place LCD)
  if ($children == 0) {
    echo("WARNING - need at least one child to build LCD into");
  }

  // parameters
  z_plus = 0.1; // how much thicker to make cutouts in z

  // different types of supported LCDs
  types = [
    // name; lcd w, h, thickness (-pcb); lcd center offset (rel. to screws); screw type, x, y, tolerance; screw socket diamter
    ["16x2", [71.5, 24.5, 7.0], [0, -0.8, 0], ["M3", 37.5, 15.5, 0.35], 6],
    ["20x4", [97.5, 40.3, 9.5], [0,  0.0, 0], ["M3", 46.5, 27.6, 0.35], 6], // FIXME not exact
    ["20x4SF", [87.6, 42.4, 9.2], [0,  0.0, 0], ["M2.5", 46.35, 27.55, 0.35], 5]
  ];
  type_idx = search([type], types)[0];
  if (type_idx == []) {
    echo(str("cannot render LCD - unrecognized type '", type , "'"));
  } else {
    echo(str("rendering LCD type '", type , "'"));

    // information text (not visible in rendered version - % modifier)
    %translate(location)
    %rotate(rotation)
    {
      translate([0, 1, 0])
      #text("this way up + inside", size = 5, valign = "bottom",
        halign = "center");
      translate([0, -1, 0])
      #text(str(type, " LCD"), size = 5, valign = "top",
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
        translate(location)
        rotate(rotation)
        {
          // screw sockets
          for(x=[-1, 1])
            for(y=[-1, 1])
              translate([x*screws[1], y*screws[2], 0])
                cylinder(h=lcd_size[2], d=screw_socket_d, center = false, $fn=30);
        }
      }
      translate(location)
      rotate(rotation)
      {
        // screw holes
        for(x=[-1, 1])
          for(y=[-1, 1])
            translate([x*screws[1], y*screws[2], 0])
              machine_screw(screws[0], lcd_size[2], tolerance = screws[3], z_plus = z_plus);

        // lcd cutout
        translate(lcd_offset)
          translate([0, 0, -z_plus])
          resize([0, 0, lcd_size[2] + 2*z_plus])
          xy_center_cube(lcd_size);

        // backlighting cutout
        if (type_idx == 0) {
          backlight = [5, 13.5, 4.75];
          translate(lcd_offset)
            translate([-lcd_size[0]/2 - backlight[0]/2, 0, lcd_size[2] - backlight[2]])
            xy_center_cube([backlight[0] + 2 * z_plus, backlight[1], backlight[2]]);
        }

        // pins cutout
        if (type_idx == 0) {
          pins = [41, 4.0, 5.0];
          offset = 2.75;
          translate(lcd_offset)
            translate([lcd_size[0]/2 - pins[0]/2 - offset, lcd_size[1]/2 + pins[1]/2 + 3, lcd_size[2] - pins[2] + z_plus])
            xy_center_cube(pins);
        }
      }
    }
  }
}


// example
color("red")
LCD(type = "16x2", location = [0, 35, 0])
LCD(type = "20x4", location = [0, -30, 0])
xy_center_cube_with_feet([110, 140, 4], feet = 3);
