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
interior_corner_radius=3;
min_height=5;
tilt=6; // [0:0.5:15]
tent=8; // [0:45]
socket_height=4.95;
hole_diameter=3.2;
hole_depth=4.25;
clearance_hole_depth=2;
clearance_hole_offset=1.5;
switch_clearance_hole_offset=11;
stab_clearance_hole_offset=2;
nano_length=33.3;
nano_width=18.1;
nano_thickness=1.6;
nano_clearance=1;
usb_socket_length=8.9;
usb_plug_width=8.9;
usb_plug_height=3.2;
usb_plug_length=8.54;
usb_sheath_offset=2;
usb_sheath_width=usb_plug_width+2*usb_sheath_offset;
usb_sheath_height=usb_plug_height+2*usb_sheath_offset;
usb_sheath_length=30;

/* all(); */
pack();
/* clearance_holes(true); */
/* stab_clearance_holes(true); */
/* switch_clearance_holes(true); */
/* nice_nano_cutout(); */
/* usb_cutout(); */

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

module pack() {
  right(5) xrot(180){
    body(true);
    up(40) xrot(180) back(dimensions(false).y) body(false);
  }
}


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
      down(0.1) scale([1,1, 1.1]) body3d(l, interior=true);
      bottom_holes(l);
      tilt_and_tent(l) top_holes(l);
      tilt_and_tent(l) switch_clearance_holes(l);
      tilt_and_tent(l) stab_clearance_holes(l);
      tilt_and_tent(l) name(l);
      align_nano(l, false) down(0.1) scale([1,1, 1.1]) nice_nano_cutout(l);
      tilt_and_tent(l) align_nano(l) translate([-(nano_clearance+1.5), nano_width/2, usb_plug_height/2]) usb_cutout();
    }

  tilt_and_tent(l) children();
}

module body3d(l=true, interior=false){
  for(part = corners(l)) {
    body_part(part, l, interior);
  }
  for(f=fillets(l)){
    fillet(f, l, interior);
  }

}

module body_part(corners, l=true, interior=false) {
  hull() {
    to3d() body_part_2d(corners, l, interior);
    tilt_and_tent(l) to3d() body_part_2d(corners, l, interior);
  }
}




module body_part_2d(corners, l=true, interior=false) {
  offset_interior(interior){
    hull(){
      for(corner = corners) {
        translate([corner.x, corner.y, 0]) circle(corner.z);
      }
    }
  }
}

module offset_interior(interior=false){
  if(interior){
    offset(r=interior_corner_radius)offset(r=-(wall_thickness+interior_corner_radius))  children();
  }
  else {
    children();
  }
}

module to3d(){
  for(i = [0:$children-1]){
    linear_extrude(height=0.0001) children(i);
  }
}

module fillet(f, l=true, interior=false){
  difference(){
    hull(){
      to3d() fillet_2d(f, interior);
      tilt_and_tent(l) to3d() fillet_2d(f, interior);
    }

    down(0.001) scale([1,1, 1.001]){
      hull(){
        to3d() fillet_mask_2d(f, interior);
        tilt_and_tent(l) to3d() fillet_mask_2d(f, interior);
      }
    }
  }
}

module fillet_2d(f, interior=false) {
  fillet_offset(f, interior) translate([f.x, f.y, 0]) flip(f[4], f[3]) square(f.z);
}

module fillet_offset(f, interior){
  if(interior){
    translate([f[4]?-wall_thickness:wall_thickness, f[3]?-wall_thickness:wall_thickness, 0]) children();
  }
  else{
    children();
  }
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

module fillet_mask_2d(f, interior) {
  fillet_offset(f, interior) translate([f.x, f.y, 0]) circle(f.z);
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

module clearance_holes(l=true) {
  for(hole = holes(l)){
    if (hole[3]!="T2"){
      translate([hole.x, hole.y, -clearance_hole_depth]) cylinder(d=hole.z+clearance_hole_offset, h=clearance_hole_depth+1);

    }
  }
  for(hole = plated_holes(l)){
    translate([hole.x, hole.y, -clearance_hole_depth]) cylinder(d=hole.z+clearance_hole_offset, h=clearance_hole_depth+1);
  }

}

module switch_clearance_holes(l=true){
  for(hole=switch_holes(l)) {
    color("blue") translate([hole.x, hole.y, -clearance_hole_depth]) cylinder(d=hole.z+switch_clearance_hole_offset, h=clearance_hole_depth+1);
  }
}

module stab_clearance_holes(l=true){
  for(hole=stab_holes(l)) {
    color("red") translate([hole.x, hole.y, -clearance_hole_depth]) cylinder(d=hole.z+stab_clearance_hole_offset, h=clearance_hole_depth+1);
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

function plated_holes(l) = l ? left_plated_holes : right_plated_holes ;

function tent_angle(l) = l ? -tent : tent ;

function corners(l) = l ? left_corners : right_corners;

function fillets(l) = l ?  left_fillets : right_fillets ;

function switch_holes(l) = [ for( hole = holes(l)) if (hole[3] == "T4" && hole.y > -70) hole ];

function stab_holes(l) = [ for( hole = holes(l)) if (hole[3] == "T3" || (hole[3] == "T4" && hole.y < -70)) hole ];

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
  nano_socket_border = (nano_width - 2.54*7) / 2 ;
  color("dimgray") rounded_rect([nano_length, nano_width, nano_thickness], radius=1.5);
  translate([ 0, (nano_width - usb_socket_length)/2 , 0 ]) rotate([90,0,90]) usb_socket();
  for(i=[0:1]){
    translate([2.82,nano_socket_border+i*6*2.54,nano_thickness]) socket();
  }
}


module nice_nano_cutout(left=true){

  translate([-nano_clearance, -nano_clearance]) hull(){
    rounded_rect([nano_length + 2*nano_clearance, nano_width+2*nano_clearance, 0.001], 1.5);
    tilt_and_tent(left) rounded_rect([nano_length + 2*nano_clearance, nano_width+2*nano_clearance, 0.001], 1.5);
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

module usb_cutout(){
  translate([0, -usb_sheath_width/2, -usb_sheath_height/2]) zrot(90)xrot(90) {
    translate([usb_sheath_offset, usb_sheath_offset, 0]) rounded_rect([usb_plug_width, usb_plug_height, usb_plug_length],radius=1);
    translate([0,0, -usb_sheath_length]) rounded_rect([usb_sheath_width, usb_sheath_height, usb_sheath_length],radius=3);
  }


}

module socket() {
  difference(){
    color("black") cube([30.48, 2.54, socket_height]);
    for(i=[0:11]){
      translate([1.27+i*2.54, 1.27, -1 ]) cylinder(d=1.092,h=10);
    }
  }
}


module align_nano(l=true, align_z=true){
  offsetX = l ? 3.3715 : 102.712+33.3-1.27;
  offsetY = l ? -40: -21.747;    // to do: was expecting left offset to be 40.147 - where is this error coming from?
  offsetZ = align_z ? -(1.6+socket_height) : 0 ;
  rotZ = l ? 0 : 180;
  translate([offsetX,offsetY,offsetZ ]) zrot(rotZ) children();
}


module name(l=true){
  right(dimensions(l).x- name_offset(l)) forward(1) down(10)zrot(180) xrot(90)
    scale([0.75,0.75,0.75])
    linear_extrude(height=2)
    import("../art/nameandpaw.svg");
}

function name_offset(l) = l ? 30 : 20 ;

