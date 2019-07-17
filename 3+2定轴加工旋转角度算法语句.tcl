#=============================================================
proc DPP_GE_COOR_ROT { ang_mode rot_angle offset pos } {
#=============================================================
# This procedure is used to detect if an operation has coordinate rotation.
# DPP_GE_COOR_ROT_LOCAL, DPP_GE_COOR_ROT_AUTO3D, DPP_GE_CALCULATE_COOR_ROT_ANGLE are called in this proc.
#
# Input:
#   ang_mode -  coordinate matrix rotation method. Possible value: XYZ, ZXY, ZXZ, ZYX
#
# Output:
#   rot_angle - rotation angle array
#               rot_angle(0) is first rotation angle value
#               rot_angle(1) is second rotation angle value
#               rot_angle(2) is third rotation angle value
#   coord_offset - linear coordinate offset from current local CSYS rotation coordinate to parent coordinate.
#   pos - linear axes position respect to rotated cooridnate
#
# Return:
#   detected coordinate mode. Possible value: NONE, LOCAL, AUTO_3D
#   NONE - no coordinate rotation
#   LOCAL - coordinate rotation set up by LOCAL CSYS MCS
#   AUTO_3D - coordinate rotation set up by tilt work plane
#
# Revisions:
#-----------
# 2013-05-22 lili - Initial implementation
#

   upvar $rot_angle angle
   upvar $pos rot_pos
   upvar $offset coord_offset

   global mom_pos
   VMOV 3 mom_pos rot_pos

   set v0 0
   VEC3_init v0 v0 v0 coord_offset

   if {[DPP_GE_COOR_ROT_LOCAL rot_matrix coord_offset]} {
      set coord_rot "LOCAL"
   } elseif {[DPP_GE_COOR_ROT_AUTO3D rot_matrix rot_pos]} {
      set coord_rot "AUTO_3D"
   } else {
      set coord_rot "NONE"
   }

   if {[string compare "NONE" $coord_rot]} {
      DPP_GE_CALCULATE_COOR_ROT_ANGLE $ang_mode rot_matrix angle
   } else {
      set angle(0) 0.0
      set angle(1) 0.0
      set angle(2) 0.0
   }
   return $coord_rot
}





#=============================================================
proc DPP_GE_COOR_ROT_LOCAL { rot_matrix coord_offset } {
#=============================================================
# This procedure is used to detect if an operation is under a local CSYS rotation and if the coordinate is rotated.
# It will return rotation matrix.
#
# Output:
#   rot_matrix - rotation matrix, mapping from the current local CSYS rotation coordinate to parent coordinate.
#   coord_offset - linear coordinate offset from current local CSYS rotation coordinate to parent coordinate.
#
# Return:
#   1 - operation is under local CSYS rotation coordinate system and the coordinate is rotated.
#   0 - operation is not under local CSYS rotation coordinate system or the coordinate is not rotated.
#
# Revisions:
#-----------
# 2013-05-22 lili - Initial implementation
#
   upvar $rot_matrix matrix
   upvar $coord_offset offset

   global mom_csys_matrix mom_csys_origin
   global mom_kin_coordinate_system_type
   global mom_parent_csys_matrix
   global mom_part_unit mom_output_unit

   set v0 0; set v1 1
   VEC3_init v1 v0 v0 VX
   VEC3_init v0 v1 v0 VY
   VEC3_init v0 v0 v1 VZ
   MTX3_init_x_y_z VX VY VZ matrix
   MTX3_init_x_y_z VX VY VZ rr_matrix

   if {[info exists mom_kin_coordinate_system_type] && ![string compare "CSYS" $mom_kin_coordinate_system_type]} {
      if {[array exists mom_parent_csys_matrix]} {
         VMOV 9 mom_parent_csys_matrix matrix

         if {![string compare $mom_part_unit $mom_output_unit]} {
            set unit_conversion 1
         } elseif { ![string compare "IN" $mom_output_unit] } {
            set unit_conversion [expr 1.0/25.4]
         } else {
            set unit_conversion 25.4
         }
         set offset(0) [expr $unit_conversion*$mom_parent_csys_matrix(9)]
         set offset(1) [expr $unit_conversion*$mom_parent_csys_matrix(10)]
         set offset(2) [expr $unit_conversion*$mom_parent_csys_matrix(11)]

      } else {
         VMOV 9 mom_csys_matrix matrix
         VMOV 3 mom_csys_origin offset
      }
      if {[MTX3_is_equal matrix rr_matrix]} {
         return 0
      } else {
         return 1
      }
   } else {
      return 0
   }

}





#=============================================================
proc DPP_GE_COOR_ROT_AUTO3D_WCS_ROTATION { first_vec second_vec angle coord_offset rot_pos } {
#=============================================================
# This procedure is used to detect if an operation is 3+2 operation without Local CSYS rotation coordinate system. And calculate the
# parameters for G68.
#
# Output:
#   first_vec - first vector for G68.
#   second_vec - second vector for G68.
#   angle - the angles rotate around first_vec and second_vec.
#   coord_offset - the linear offset for G68.
#   rot_pos    - current position respect to rotated coordinate system
#
# Return:
#   1 - operation is 3+2 operation without Local CSYS rotation coordinate system.
#   0 - operation is not 3+2 operation without Local CSYS rotation coordinate system.
#
# Revisions:
#-----------
# 2013-05-25 levi - Initial implementation
#
   upvar $first_vec g68_first_vec
   upvar $second_vec g68_second_vec
   upvar $angle g68_coord_rotation
   upvar $coord_offset offset
   upvar $rot_pos pos

   global mom_kin_coordinate_system_type
   global mom_kin_machine_type
   global mom_kin_4th_axis_point mom_kin_5th_axis_point
   global mom_kin_4th_axis_vector mom_kin_5th_axis_vector
   global mom_out_angle_pos mom_prev_out_angle_pos
   global DEG2RAD RAD2DEG
   global mom_pos mom_mcs_goto mom_prev_pos
   global dpp_ge
   global save_mom_kin_machine_type
   global save_mom_kin_4th_axis_vector

   set v0 0.0; set v1 1.0
   VEC3_init v1 v0 v0 X
   VEC3_init v0 v1 v0 Y
   VEC3_init v0 v0 v1 Z
   MTX3_init_x_y_z X Y Z matrix
   VMOV 3 mom_pos pos

   if { ![string match "*5_axis*" $mom_kin_machine_type] } {
      return 0
   }

   if {[info exists mom_kin_coordinate_system_type] && ![string compare "CSYS" $mom_kin_coordinate_system_type]} {
      return 0
   } else {
      if {(![EQ_is_zero $mom_out_angle_pos(0)] && ![VEC3_is_equal mom_kin_4th_axis_vector Z]) || \
          (![EQ_is_zero $mom_out_angle_pos(1)] && ![VEC3_is_equal mom_kin_5th_axis_vector Z]) } {
      } else {
         return 0
      }
   }

   # Save kinematics
   DPP_GE_SAVE_KINEMATICS

   # get rotation angle
   if { [string match "5_axis_dual_head" $mom_kin_machine_type] } {
      # Swap rotary axes kinematics for dual head machine
      DPP_GE_SWAP_4TH_5TH_KINEMATICS
      set ang_pos(0) $mom_out_angle_pos(1)
      set ang_pos(1) $mom_out_angle_pos(0)
      # Swap rotary axes value due to kinemtics switched
      set mom_out_angle_pos(0) $ang_pos(0)
      set mom_out_angle_pos(1) $ang_pos(1)
      set mom_prev_out_angle_pos(0) $ang_pos(0)
      set mom_prev_out_angle_pos(1) $ang_pos(1)
      set mom_pos(3) $ang_pos(0)
      set mom_pos(4) $ang_pos(1)
      set mom_prev_pos(3) $ang_pos(0)
      set mom_prev_pos(4) $ang_pos(1)
      MOM_reload_variable -a mom_out_angle_pos
      MOM_reload_variable -a mom_prev_out_angle_pos
      MOM_reload_variable -a mom_pos
      MOM_reload_variable -a mom_prev_pos
   } else {
      set ang_pos(0) $mom_out_angle_pos(0)
      set ang_pos(1) $mom_out_angle_pos(1)
   }

   set rot0 [expr $ang_pos(0)*$DEG2RAD]
   set rot1 [expr $ang_pos(1)*$DEG2RAD]

   # Reolad kinematics to dual-table machine
   if { ![string match "5_axis_dual_table" $mom_kin_machine_type] } {
     set mom_kin_machine_type "5_axis_dual_table"
   }

   set v0 0.0
   VEC3_init v0 v0 v0 mom_kin_4th_axis_point
   VEC3_init v0 v0 v0 mom_kin_5th_axis_point
   MOM_reload_kinematics

   # Get current position respect to rotated coordinate
   VECTOR_ROTATE mom_kin_5th_axis_vector [expr -1*$rot1] mom_mcs_goto V
   VECTOR_ROTATE mom_kin_4th_axis_vector [expr -1*$rot0] V pos

  # Calculate rotation matrix
   VECTOR_ROTATE mom_kin_4th_axis_vector $rot0 X V1
   VECTOR_ROTATE mom_kin_4th_axis_vector $rot0 Y V2
   VECTOR_ROTATE mom_kin_4th_axis_vector $rot0 Z V3

   VECTOR_ROTATE mom_kin_5th_axis_vector $rot1 V1 X
   VECTOR_ROTATE mom_kin_5th_axis_vector $rot1 V2 Y
   VECTOR_ROTATE mom_kin_5th_axis_vector $rot1 V3 Z

   MTX3_init_x_y_z X Y Z matrix

   # extend the matrix between fixture offset and dummy local csys to 4X4 matrix
    for {set i 0} {$i<3} {incr i} {
       set extend_matrix($i) $matrix($i)
    }
    set extend_matrix(3) 0
    for {set i 4} {$i<7} {incr i} {
       set extend_matrix($i) $matrix([expr $i-1])
    }
    set extend_matrix(7) 0
    for {set i 8} {$i<11} {incr i} {
       set extend_matrix($i) $matrix([expr $i-2])
    }
    set extend_matrix(11) 0
    for {set i 12} {$i<15} {incr i} {
       set extend_matrix($i) 0
    }
    set extend_matrix(15) 1
 # calculate the parameters for G68 including linear offset, vectors and rotation angles
    CALCULATE_G68 "AUTO_3D" extend_matrix offset g68_first_vec g68_coord_rotation
    set g68_second_vec(0) 0
    set g68_second_vec(1) 0
    set g68_second_vec(2) 1
 # if it's a head-table machine, recalculate the vectors and angles to just output G68 once
    if {$save_mom_kin_machine_type=="5_axis_head_table"} {
       VMOV 3 save_mom_kin_4th_axis_vector g68_first_vec
       set g68_coord_rotation(0) $mom_pos(3)
       set g68_coord_rotation(1) 0
       set g68_coord_rotation(2) 0
    }
 # if it's a dual_head machine, recalculate the vectors and angles to output G68 aroud the rotary axis vectors
    if {$save_mom_kin_machine_type=="5_axis_dual_head"} {
       VMOV 3 mom_kin_5th_axis_vector g68_first_vec
       VMOV 3 mom_kin_4th_axis_vector g68_second_vec
       set g68_coord_rotation(0) [expr $rot1*$RAD2DEG]
       set g68_coord_rotation(1) [expr $rot0*$RAD2DEG]
       set g68_coord_rotation(2) 0
    }
   return 1

}




#=============================================================
proc DPP_GE_CALCULATE_COOR_ROT_ANGLE { mode MATRIX ANG } {
#=============================================================
# The command can be used to to calculate the coordinate system rotation angles
# and support coordinate rotation functions such as G68/ROT/AROT G68.2/CYCLE800/PLANE SPATIAL.
#
# Input:
#   mode   - Coordinate rotation mode: XYZ, ZXY, ZXZ, ZYX
#   MATRIX - Reference to an array of (0:8) defining a local coordinate system of 3x3 matrix
#
# Output:
#   ANG    - Reference to an array of (0:2) defining rotation angles in order
#            ang(0) - first rotation angle value
#            ang(1) - second rotation angle value
#            ang(2) - third rotation angle value
#
# Return:
#   1 - mode is available, 0 - mode is not available
#
# Revisions:
#-----------
# 2013-05-22 lili - Initial implementation
# 2106-02-02 gsl  - Clean up
#

   upvar $MATRIX rotation_matrix
   upvar $ANG rot_ang

   global RAD2DEG  #弧度转角度常量360/2PI

   set m0 $rotation_matrix(0)
   set m1 $rotation_matrix(1)
   set m2 $rotation_matrix(2)
   set m3 $rotation_matrix(3)
   set m4 $rotation_matrix(4)
   set m5 $rotation_matrix(5)
   set m6 $rotation_matrix(6)
   set m7 $rotation_matrix(7)
   set m8 $rotation_matrix(8)

   set status UNDEFINED

   if { $mode == "XYZ" } {

      set cos_b_sq [expr $m0*$m0 + $m3*$m3]

      if { [EQ_is_equal $cos_b_sq 0.0] } {

         set cos_b 0.0
         set cos_a 1.0
         set sin_a 0.0
         set cos_c $m4
         set sin_c [expr -1*$m1]

         if { [expr $m6 < 0.0] } {
            set sin_b 1.0
         } else {
            set sin_b -1.0
         }

      } else {

         set cos_b [expr sqrt($cos_b_sq)]
         set sin_b [expr -$m6]

         set cos_a [expr $m8/$cos_b]
         set sin_a [expr $m7/$cos_b]

         set cos_c [expr $m0/$cos_b]
         set sin_c [expr $m3/$cos_b]
      }

      set A [expr -atan2($sin_a,$cos_a)*$RAD2DEG]
      set B [expr -atan2($sin_b,$cos_b)*$RAD2DEG]
      set C [expr -atan2($sin_c,$cos_c)*$RAD2DEG]

      set rot_ang(0) $A; set rot_ang(1) $B; set rot_ang(2) $C
      set status OK

   } elseif { $mode == "ZXY" } {

      set cos_a_sq [expr $m3*$m3 + $m4*$m4]

      if { [EQ_is_equal $cos_a_sq 0.0] } {

         set cos_a 0.0
         set cos_c 1.0
         set sin_c 0.0
         set sin_b $m6
         set cos_b $m0

         if { [expr $m5 < 0.0] } {
            set sin_a -1.0
         } else {
            set sin_a 1.0
         }

      } else {

         set cos_a [expr sqrt($cos_a_sq)]
         set sin_a [expr $m5]

         set cos_b [expr $m8/$cos_a]
         set sin_b [expr -$m2/$cos_a]

         set cos_c [expr $m4/$cos_a]
         set sin_c [expr -$m3/$cos_a]
      }

      set A [expr atan2($sin_a,$cos_a)*$RAD2DEG]
      set B [expr atan2($sin_b,$cos_b)*$RAD2DEG]
      set C [expr atan2($sin_c,$cos_c)*$RAD2DEG]

      set rot_ang(0) $C; set rot_ang(1) $A; set rot_ang(2) $B
      set status OK

   } elseif { $mode == "ZYX" } {

      if { [EQ_is_equal [expr abs($m2)] 1.0] } {
         set C [expr atan2([expr -1*$m3],$m4)]
      } else {
         set C [expr atan2($m1,$m0)]
      }

      set length [expr sqrt($m0*$m0 + $m1*$m1)]
      set B [expr -1*atan2($m2,$length)]
      set cos_B [expr cos($B)]

      if { ![EQ_is_zero $cos_B] } {
         set A [expr atan2($m5/$cos_B,$m8/$cos_B)]
      } else {
         set A 0.0
      }

      set A [expr $A*$RAD2DEG]
      set B [expr $B*$RAD2DEG]
      set C [expr $C*$RAD2DEG]

      set rot_ang(0) $C; set rot_ang(1) $B; set rot_ang(2) $A
      set status OK

   } elseif { $mode == "ZXZ" } {

      set sin_b_sq [expr $m2*$m2 + $m5*$m5]

      if { [EQ_is_equal $sin_b_sq 0.0] } {

         set cos_b 1.0
         set sin_b 0.0
         set sin_c 0.0
         set cos_c 1.0
         set sin_a $m1

         if { [expr $m8 > 0.0] } {
            set cos_b 1.0
            set cos_a $m0
         } else {
            set cos_b -1.0
            set cos_a -$m4
         }

      } else {

         set sin_b [expr sqrt($sin_b_sq)]
         set cos_b [expr $m8]

         set cos_a [expr -$m7/$sin_b]
         set sin_a [expr $m6/$sin_b]

         set cos_c [expr $m5/$sin_b]
         set sin_c [expr $m2/$sin_b]
      }

      set A [expr atan2($sin_a,$cos_a)*$RAD2DEG]
      set B [expr atan2($sin_b,$cos_b)*$RAD2DEG]
      set C [expr atan2($sin_c,$cos_c)*$RAD2DEG]

      set rot_ang(0) $A; set rot_ang(1) $B; set rot_ang(2) $C
      set status OK
   }

   if { $status == "OK" } {
 return 1
   } else {
 return 0
   }
}










