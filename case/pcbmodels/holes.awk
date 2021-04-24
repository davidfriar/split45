BEGIN {
  x_offset=-16.66825
  y_offset=14.287

  print "[" }

/^T[0-9]C/{
  split($1, s, "C")
  tools[s[1]] = s[2]
}

/^T[0-9]$/{
  currentTool = $1
}

/^X/ {
  split($1, val, "X|Y")
  print "  [", val[2]+x_offset, ",", val[3]+y_offset, ",", tools[currentTool] ", \x22" currentTool "\x22 ],"
  }

END { print "]" }

