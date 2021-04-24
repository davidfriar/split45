function abs(v) {return v < 0 ? -v : v}
function max(a,b) {return a > b ? a : b}

BEGIN {
  offsetx = -16.668750
  offsety = -14.28750
}

/gr_arc/ {
  centerx=$3 + offsetx
  centery=substr($4, 0, length($4)-1) + offsety

  startx=$6 + offsetx
  starty=substr($7, 0, length($7)-1) + offsety

  radius = max(abs(starty-centery),abs(startx-centerx))



  print "[" centerx ", -"centery ", " radius " ],"
}



