include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <pcbmodels/holes.scad>
include <pcbmodels/dimensions.scad>
include <pcbmodels/corners.scad>
$fn = 360;
$fs = 1;
wall_thickness=8;
min_height=10;
tilt=6; // [0:0.5:15]
tent=15; // [0:45]


base(true) body(true) pcb(true) ;


module body(l=true){
  for(part = corners(l)) {
    body_part(part);
  }
  for(f=fillets(l)){
    fillet(f);
  }

  tilt_and_tent(l) children();
}

module body_part(corners) {
  hull() {
    to3d() body_part_2d(corners);
    tilt_and_tent() to3d() body_part_2d(corners);
  }
}


module body_part_2d(corners) {
  hull(){
    for(corner = corners) {
      translate([corner.x, corner.y, 0]) circle(corner.z);
    }
  }
}

module to3d(){
  for(i = [0:$children-1]){
    linear_extrude(height=0.01) children(i);
  }
}

module fillet(f){
  difference(){
    hull(){
      to3d() fillet_2d(f);
      tilt_and_tent() to3d() fillet_2d(f);
    }

    down(0.001) scale([1,1, 1.001]){
      hull(){
        to3d() fillet_mask_2d(f);
        tilt_and_tent() to3d() fillet_mask_2d(f);
      }
    }
  }
}

module fillet_2d(f) {
  translate([f.x, f.y, 0]) flip(f[4], f[3]) square(f.z);
}

module flip(x, y) {
  if(x){
    if(y) {
      xflip() yflip() children();
    }
    else {
      xflip() children();
    }
  }
  else{
    if(y){
      yflip() children();
    }
    else {
      children();
    }
  }
}

module fillet_mask_2d(f) {
  translate([f.x, f.y, 0]) circle(f.z);
}



module oldbody(l=true){
  difference(){
    linear_extrude(convexity=10, height=50, scale=[cos(tent), cos(tilt)]) shell2d(thickness=-wall_thickness, fill=0.793750)
    {
      projection() base(l);
      for(hole = base_holes(l)) {
        translate([hole.x, hole.y, 0]) centered(l) circle(d=hole[2]+0.1);
      }
    }
    tilt_and_tent(l) top_half(s=300) cube([200, 200, 200], center=true);
  }
  tilt_and_tent(l) children();
}


module tilt_and_tent(l=true) {
  translate([0,0, min_height + (tan(tent)*dimensions(l).x * 0.5)+(tan(tilt)*dimensions(l).y * 0.5)])
    yrot(tent_angle(l)) xrot(tilt)
    children();
}

function dimensions(l) = l ? left_size : right_size ;

function base_holes(l) = l ? left_base_holes : right_base_holes ;

function tent_angle(l) = l ? -tent : tent ;

function corners(l) = l ? left_corners: right_corners ;

function fillets(l) = l ? left_fillets: right_fillets ;

module pcb(l=true){
  color("red")up(dimensions(l).z)  {
    if (l) {
      pcb_left();
    }
    else {
      pcb_right();
    }
  }
}

module centered(l=true) {
  translate([-dimensions(l).x/2, dimensions(l).y/2, 0]) children();
}

module base(l=true){
  color("red")up(dimensions(l).z)  {
    if (l) {
      base_left();
    }
    else {
      base_right();
    }
  }
  up(dimensions(l).z) children();
}

module pcb_left() {
  import("pcbmodels/split45left.stl");
}

module pcb_right() {
  import("pcbmodels/split45right.stl");
}

module base_left() {
  import("pcbmodels/split45leftbase.stl");
}

module base_right() {
  import("pcbmodels/split45rightbase.stl");
}
