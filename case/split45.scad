$fn = 360;
$fs = 1;


body_left();

module body_left(){
  rotate_extrude(angle=15, convexity=10)  translate([50, 0,0]) projection () pcb_left();
}


module pcb_left() {
  import("pcbmodels/split45left.stl");

}
