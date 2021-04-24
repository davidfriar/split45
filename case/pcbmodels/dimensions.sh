#! /bin/sh
echo "left_size = $(awk -f dimensions.awk split45leftbase.stl);" > dimensions.scad
echo "right_size = $(awk -f dimensions.awk split45rightbase.stl);" >> dimensions.scad
