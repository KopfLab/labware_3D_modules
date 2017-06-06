use <box.scad>;
use <lcd.scad>;

color("green")
  LCD(type = "20x4", location = [0, 10, 0])
    box_lid([120, 100], feet = 2);
