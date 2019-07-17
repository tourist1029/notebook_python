global dpp_ge
MOM_output_literal "大小为： [array size dpp_ge]"

global mom_kin_spindle_axis

MOM_output_literal "$mom_kin_spindle_axis(0)"
MOM_output_literal "$mom_kin_spindle_axis(1)"
MOM_output_literal "$mom_kin_spindle_axis(2)"

#global mom_msys_matrix  #用于CLSF，还需测试
global mom_csys_matrix
global RAD2DEG
global mom_tool_axis
#upvar #0 $mom_msys_matrix rot_matrix

set xx $mom_csys_matrix(0)
set xy $mom_csys_matrix(1)
set xz $mom_csys_matrix(2)
set yx $mom_csys_matrix(3)
set yy $mom_csys_matrix(4)
set yz $mom_csys_matrix(5)
set zx $mom_csys_matrix(6)
set zy $mom_csys_matrix(7)
set zz $mom_csys_matrix(8)

set ori_X $mom_csys_matrix(9)
set ori_Y $mom_csys_matrix(10)
set ori_Z $mom_csys_matrix(11)

MOM_output_literal "Xx is $xx"
MOM_output_literal "Xy is $xy"
MOM_output_literal "Xz is $xz"
MOM_output_literal "Yx is $yx"
MOM_output_literal "Yy is $yy"
MOM_output_literal "Yz is $yz"
MOM_output_literal "Zx is $zx"
MOM_output_literal "Zy is $zy"
MOM_output_literal "Zz is $zz"

MOM_output_literal "原点X： $ori_X"
MOM_output_literal "原点Y： $ori_Y"
MOM_output_literal "原点Z： $ori_Z"

#********************************************************************************************
#mode is "XYZ"
set cos_b_sq [expr $xx*$xx + $yx*$yx]

if {[EQ_is_equal $cos_b_sq 0.0]} {
    set cos_b 0.0
    set cos_a 1.0
    set sin_a 0.0
    set cos_c $yy
    set sin_c [expr -1*$xy]

    if {$zx < 0} {
        set sin_b 1.0
    } else {
        set sin_b -1.0
    }

} else {
    set cos_b [expr sqrt($cos_b_sq)]
    set sin_b [expr -$zx]

    set cos_a [expr $zz/$cos_b]
    set sin_a [expr $zy/$cos_b]

    set cos_c [expr $xx/$cos_b]
    set sin_c [expr $yx/$cos_b]

}

set A [expr -atan2($sin_a,$cos_a)*$RAD2DEG]
set B [expr -atan2($sin_b,$cos_b)*$RAD2DEG]
set C [expr -atan2($sin_c,$cos_c)*$RAD2DEG]

MOM_output_literal "Rot X: $A"
MOM_output_literal "Rot Y: $B"
MOM_output_literal "Rot Z: $C"

MOM_output_literal "Tool X value: $mom_tool_axis(0)"
MOM_output_literal "Tool Y value: $mom_tool_axis(1)"
MOM_output_literal "Tool Z value: $mom_tool_axis(2)"

#******************************************************************************************
#mode is "ZXY"

set cos_a_sq [expr $yx*$yx + $yy*$yy]

if {[EQ_is_equal $cos_a_sq 0.0]} {
    set cos_a 0.0
    set cos_c 1.0
    set sin_c 0.0
    set sin_b $zx
    set cos_b $xx

    if {$yz < 0.0} {
        set sin_a -1.0
    } else {
        set sin_a 1.0
    }
} else {
    set cos_a [expr sqrt($cos_a_sq)]
    set sin_a [expr $yz]

    set cos_b [expr $zz/$cos_a]
    set sin_b [expr -$xz/$cos_a]

    set cos_c [expr $yy/$cos_a]
    set sin_c [expr -$yx/cos_a]
}

set A [expr atan2($sin_a,$cos_a)*RAD2DEG]
set B [expr atan2($sin_b,$cos_b)*RAD2DEG]
set C [expr atan2($sin_c,$cos_c)*RAD2DEG]

#***************************************************************************************

#mode is "ZYX"

if {[EQ_is_equal [expr abs($xz)] 1.0]} {
    set C [expr atan2([expr -1*$yx],$yy)]
} else {
    set C [expr atan2($xy,$xx)]
}

set length [expr sqrt($xx*$xx + $xy*$xy)]
set B [expr -1*atan2($xz,$length)]
set cos_B [expr cos($B)]

if {!EQ_is_zero $cos_B} {
    set A [expr atan2($yz/$cos_B,$zz/cos_B)]
} else {
    set A 0.0
}

set A [expr $A*RAD2DEG]
set B [expr $B*RAD2DEG]
set C [expr $C*RAD2DEG]

#***************************************************************************************

#mode is "ZXZ"

set sin_b_sq [$xz*$xz + $yz*$yz]

if {[EQ_is_equal $sin_b_sq 0.0]} {
    set cos_b 1.0
    set sin_b 0.0
    set sin_c 0.0
    set cos_c 1.0
    set sin_a $xy
    if {$zz > 0} {
        set cos_b 1.0
        set cos_a $xx
    } else {
        set cos_b -1.0
        set cos_a -$yy
    }
} else {
    set sin_b [expr sqrt($sin_b_sq)]
    set cos_b [expr $zz]

    set cos_a [expr -$zy/$sin_b]
    set sin_a [expr $zx/$sin_b]

    set cos_c [expr $yz/$sin_b]
    set sin_c [expr $xz/$sin_b]
}

set A [expr atan2($sin_a,$cos_a)*RAD2DEG]
set B [expr atan2($sin_b,$cos_b)*RAD2DEG]
set C [expr atan2($sin_c,$cos_c)*RAD2DEG]

#***************************************************************************************



