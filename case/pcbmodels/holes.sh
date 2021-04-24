#! /bin/sh

echo "left_holes = $(awk -f holes.awk ../../pcb/split45left/gerbers/split45left-NPTH.drl);" > holes.scad
echo "left_plated_holes = $(awk -f holes.awk ../../pcb/split45left/gerbers/split45left-PTH.drl);" >> holes.scad
echo "right_holes = $(awk -f holes.awk ../../pcb/split45right/gerbers/split45right-NPTH.drl);" >> holes.scad
echo "right_plated_holes = $(awk -f holes.awk ../../pcb/split45right/gerbers/split45right-PTH.drl);" >> holes.scad
echo "left_base_holes = $(awk -f holes.awk ../../pcb/split45leftbase/gerbers/split45leftbase-NPTH.drl );" >> holes.scad
echo "left_plated_base_holes = $(awk -f holes.awk ../../pcb/split45leftbase/gerbers/split45leftbase-PTH.drl);" >> holes.scad
echo "right_base_holes = $(awk -f holes.awk ../../pcb/split45rightbase/gerbers/split45rightbase-NPTH.drl);" >> holes.scad
echo "right_plated_base_holes = $(awk -f holes.awk ../../pcb/split45rightbase/gerbers/split45rightbase-PTH.drl);" >> holes.scad
