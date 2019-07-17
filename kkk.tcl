if {[regexp {.*F([0-9]*\.[0-9]*)} $buf match submatch] == 1} {
    if {$mom_feed_engage_value == $mom_feed_retract_value} {
        if {$submatch == $cut_speed} {
            regsub {F[0-9]*.[0-9]*} $buf "F=R2" new_buf2
            puts $write_ss $new_buf2
            continue
        }
        if {$submatch == $engage_speed} {
            regsub {F[0-9]*\.[0-9]*} $buf "F=R1" new_buf1
            puts $write_ss $new_buf1
            continue
        }         
    } else {
        if {$submatch == $cut_speed} {
            regsub {F[0-9]*.[0-9]*} $buf "F=R2" new_buf2
            puts $write_ss $new_buf2
            continue
        }
        if {$submatch == $engage_speed} {
            regsub {F[0-9]*\.[0-9]*} $buf "F=R1" new_buf1
            puts $write_ss $new_buf1
            continue
        }
        if {$submatch == $retract_speed} {
            regsub {F[0-9]*\.[0-9]*} $buf "F=R3" new_buf3
            puts $write_ss $new_buf3
            continue
        }                           
    }
}


#加入刀具信息，用于自动换刀使用

global mom_operation_name
global mom_tool_name
global mom_tool_type

#T型刀参数，下半径，上半径，刀柄直径
global mom_tool_lower_corner_radius
global mom_tool_upper_corner_radius
global mom_tool_shank_diameter

global mom_feed_cut_value
global mom_feed_engage_value
global mom_feed_stepover_value 
global mom_feed_retract_value 

#普通5参数铣刀参数
global mom_tool_name
global mom_tool_diameter
global mom_tool_corner1_radius

if {![info exists mom_tool_corner1_radius]} {set mom_tool_corner1_radius 0}












