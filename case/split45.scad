include <BOSL/constants.scad>
use <BOSL/transforms.scad>
include <pcbmodels/holes.scad>
include <pcbmodels/dimensions.scad>
include <pcbmodels/corners.scad>
$fn = 360;
$fs = 1;

show_left=true;
show_right=true;
show_base=true;
show_pcb=true;

wall_thickness=8;
min_height=10;
tilt=6; // [0:0.5:15]
tent=15; // [0:45]
socket_height=4.95;
hole_diameter=3.2;
hole_depth=4.25;

all();
/* name(); */
/*
to do:


all function
explode
bottom holes
top holes
pcb clearance
right interior
name
pcb / usb cutout
check weird alignment error with nano holes
battery holder
info panel (including clearance height for nano)

pack for printing
*/

module all(){
   if(show_left) {
      base(true) body(true) pcb(true) ;
   }
   if(show_right) {
     if(show_left) {
       xmove(left_size.x *1.25)
         base(false) body(false) pcb(false) ;
     }
     else{
       base(false) body(false) pcb(false) ;
     }
   }
}

module body(l=true){
  color("grey")
    difference(){
      body3d(l);
      down(0.001) scale([1,1, 1.001]) body3d(l, interior=true);
      bottom_holes(l);
      tilt_and_tent(l) top_holes(l);
      tilt_and_tent(l) name();
    }

  tilt_and_tent(l) children();
}

module body3d(l=true, interior=false){
  for(part = corners(l, interior)) {
    body_part(part, l);
  }
  for(f=fillets(l, interior)){
    fillet(f, l);
  }

}

module body_part(corners, l=true) {
  hull() {
    to3d() body_part_2d(corners, l);
    tilt_and_tent(l) to3d() body_part_2d(corners, l);
  }
}


module body_part_2d(corners, l=true) {
  hull(){
    for(corner = corners) {
      translate([corner.x, corner.y, 0]) circle(corner.z);
    }
  }
}

module to3d(){
  for(i = [0:$children-1]){
    linear_extrude(height=0.0001) children(i);
  }
}

module fillet(f, l=true){
  difference(){
    hull(){
      to3d() fillet_2d(f);
      tilt_and_tent(l) to3d() fillet_2d(f);
    }

    down(0.0001) scale([1,1, 1.0001]){
      hull(){
        to3d() fillet_mask_2d(f);
        tilt_and_tent(l) to3d() fillet_mask_2d(f);
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

module bottom_holes(l=true){
  for(hole = base_holes(l)){
    translate([hole.x, hole.y, -1]) cylinder(d=hole_diameter, h=hole_depth+1);
  }
}


module top_holes(l=true){
  for(hole = holes(l) ){
    if (hole[3]=="T2"){
      translate([hole.x, hole.y, -hole_depth]) cylinder(d=hole_diameter, h=hole_depth+1);
    }
  }
}

module tilt_and_tent(l=true) {
  /* translate([0,0, min_height + (tan(tent)*dimensions(l).x * 0.5)+(tan(tilt)*dimensions(l).y * 0.5)]) */
  zmove(min_height)
    ymove(-dimensions(l).y) xmove(l?0:right_size.x) yrot(tent_angle(l)) xrot(tilt) xmove(l?0:-right_size.x) ymove(dimensions(l).y)
    children();
}

function dimensions(l) = l ? left_size : right_size ;

function base_holes(l) = l ? left_base_holes : right_base_holes ;

function holes(l) = l ? left_holes : right_holes ;

function tent_angle(l) = l ? -tent : tent ;

function corners(left, interior) =
  left ?
(interior ? left_interior_corners : left_corners)
  :
  (interior ? right_interior_corners : right_corners);


  function fillets(l, interior) = l ?
(interior? left_interior_fillets : left_fillets)
  :
  (interior? right_interior_fillets : right_fillets) ;

  module pcb(l=true){
    if(show_pcb){
      color("red")up(dimensions(l).z)  {
        if (l) {
          pcb_left();
        }
        else {
          pcb_right();
        }
      }
      //translate([0,0,-(1.6+socket_height)]) nice_nano();
      align_nano(l) nice_nano();
    }
  }

module centered(l=true) {
  translate([-dimensions(l).x/2, dimensions(l).y/2, 0]) children();
}

module base(l=true){
  if(show_base){
    color("red")up(dimensions(l).z)  {
      if (l) {
        base_left();
      }
      else {
        base_right();
      }
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

module nice_nano() {
  nano_length=33.3;
  nano_width=18.1;
  nano_thickness=1.6;
  usb_socket_length=8.9;
  nano_socket_border = (nano_width - 2.54*7) / 2 ;
  color("dimgray") rounded_rect([nano_length, nano_width, nano_thickness], radius=1.5);
  translate([ 0, (nano_width - usb_socket_length)/2 , 0 ]) rotate([90,0,90]) usb_socket();
  for(i=[0:1]){
    translate([2.82,nano_socket_border+i*6*2.54,nano_thickness]) socket();
  }
}


module rounded_rect(size, radius=5){
  hull(){
    translate([radius, radius]) cylinder(h=size.z, r=radius);
    translate([size.x-radius, radius]) cylinder(h=size.z, r=radius);
    translate([radius, size.y-radius]) cylinder(h=size.z, r=radius);
    translate([size.x-radius, size.y-radius]) cylinder(h=size.z, r=radius);
  }
}

module usb_socket(){
  color("silver") rounded_rect([8.9, 3.2, 6.5],radius=1);
}

module socket() {
  difference(){
    color("black") cube([30.48, 2.54, socket_height]);
    for(i=[0:11]){
      translate([1.27+i*2.54, 1.27, -1 ]) cylinder(d=1.092,h=10);
    }
  }
}


module align_nano(l=true){
  offsetX = l ? 3.3715 : 102.712+33.3-1.27;
  offsetY = l ? -40: -21.747;    // to do: was expecting left offset to be 40.147 - where is this error coming from?
  rotZ = l ? 0 : 180;
  translate([offsetX,offsetY, -(1.6+socket_height)]) zrot(rotZ) children();
}


module name(l=true){
  right(dimensions(l).x-20) forward(1) down(10)zrot(180) xrot(90)
  scale([0.75,0.75,0.75])
  linear_extrude(height=2)
    import("../art/nameandpaw.svg");
}
