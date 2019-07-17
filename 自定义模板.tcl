
#Tcl中用于描述时间语句
puts [clock format [clock seconds] -format "%Y-%m-%d-%B-%A: %H:%M:%S-%P"]


proc PB_CMD_head_info {} 
{
    global mom_template_type
    global mom_template_subtype
    #用于确定加工模式, 还有子加工模式

    global mom_operation_name
    global mom_tool_name

    global mom_feed_cut_value
    global mom_feed_engage_value
    global mom_feed_stepover_value 
    global mom_feed_retract_value 
    #层进速度并不是所有加工方式都有，因此后处理时需要加一个加工方式的判断，这样才不会报错。

    global mom_tool_name
    global mom_tool_diameter

    global mom_tool_corner1_radius
    global mom_part_name
    global mom_date


    set Name $mom_operation_name
    set hole "hole_making"
    set dri "drill"

    #set lastname "_MPF"
    #MOM_output_literal "%_N_$Name$lastname"
    set TC "Milling Tool-T Cutter"

    MOM_output_text "%_N_$Name\_MPF"
    MOM_output_text ";File :  $mom_part_name"
    MOM_output_text ";TIME :  $mom_date"
    MOM_output_text ";Programmer: Tryx"
    #MOM_output_text "T=\"$mom_tool_name\""
    #MOM_output_text "M06"

    if {[string equal $TC $mom_tool_type]} {
        MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] lower_rad=[format %.3f $mom_tool_lower_corner_radius] upper_rad=[format %.3f $mom_tool_upper_corner_radius] holder_Dia=[format %.3f $mom_tool_shank_diameter]"
    } else {
        MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] Rad=[format %.3f $mom_tool_corner1_radius]"
    }

    #加入一个对加工模式的判断，当是孔类加工时，不添加R3参数，否则会报错
    #加入判断，当进刀（engage），退刀（retract）不相同时，进行判断，多输出一个更改退刀的R参数
    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
            if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
                MOM_output_literal "the Process type is $mom_template_type"
                MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
                MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
            } else {
                MOM_output_literal "the Process type is $mom_template_type"
                MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
                MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
                MOM_output_text "R3=[format "%.3f" $mom_feed_retract_value]"
            }
            
        } else {
            if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
                MOM_output_literal "the Process type is $mom_template_type"
                MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
                MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
                MOM_output_text "R3=[format "%.3f" $mom_feed_stepover_value]"
            } else {
                MOM_output_literal "the Process type is $mom_template_type"
                MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
                MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
                MOM_output_text "R3=[format "%.3f" $mom_feed_stepover_value]"
                MOM_output_text "R4=[format "%.3f" $mom_feed_retract_value]"
            }
        }

    # if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
    #     MOM_output_literal "the Process type is $mom_template_type"
    #     MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
    #     MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
    # } else {
    #     MOM_output_literal "the Process type is $mom_template_type"
    #     MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
    #     MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
    #     MOM_output_text "R3=[format "%.3f" $mom_feed_stepover_value]"
    # }

    MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format "%.3f" $mom_tool_diameter] Rad=[format "%.3f" $mom_tool_corner1_radius]"
}

#在程序尾添加加工时间
proc PB_CMD_time_end {} 
{
    global mom_machine_time

    MOM_output_txet "; (Total Operation Machine Time : [format "%.3f" $mom_machine_time] min)"
}
#####################################################################################

proc PB_CMD_time_head {} 
{
    ##在程序头添加加工时间
    global ptp_file_name
    set tmp_file_name "${ptp_file_name}_"
    if {[file exists $tmp_file_name]} {
        MOM_remove_file $tmp_file_name
    }
    MOM_close_output_file $ptp_file_name
    file rename $ptp_file_name $tmp_file_name
    set ifile [open $tmp_file_name r]
    set ofile [open $ptp_file_name w]
    global mom_machine_time
    puts $ofile "(CYCLE TIME = [format "%.3f" $mom_machine_time] MIN.)"
    set buf ""
    while {[gets $ifile buf] > 0} {
        puts $ofile $buf
    }
    close $ifile
    close $ofile
    MOM_remove_file $tmp_file_name
    MOM_open_output_file $ptp_file_name
}

################################################################
###############################################################

proc PB_CMD_speed_change {} {
    #替换速度参数代码段
    global ptp_file_name
    global mom_template_type
    global mom_template_subtype

    set tmp_file_name "${ptp_file_name}_"
    if {[file exists $tmp_file_name]} {
        MOM_remove_file $tmp_file_name
    }

    MOM_close_output_file $ptp_file_name
    file rename $ptp_file_name $tmp_file_name

    set read_ss [open $tmp_file_name r]
    set write_ss [open $ptp_file_name w]

    global mom_machine_time
    global mom_feed_cut_value
    global mom_feed_engage_value
    global mom_feed_stepover_value
    global mom_feed_retract_value

    puts $write_ss ";The Total TIME = [format "%.3f" $mom_machine_time] MIN."

    set buf ""
    set hole "hole_making"
    set dri "drill"

    #加入判断，加工模式，如果是孔类加工，则不选择参数R3，如果是铣削加工，则加上参数R3
    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
        if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            #set retract_speed [format "%.f" $mom_feed_retract_value]
        } else {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set retract_speed [format "%.f" $mom_feed_retract_value]
        }
        
    } else {
        if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set stepover_speed [format "%.f" $mom_feed_stepover_value]
        } else {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set stepover_speed [format "%.f" $mom_feed_stepover_value]
            set retract_speed [format "%.f" $mom_feed_retract_value]
        }
        

    }

    #puts $write_ss ";$cut_speed"
    #puts $write_ss ";$engage_speed"
    #puts $write_ss ";$stepover_speed"

    while {[gets $read_ss buf] > 0} {
        if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
            if {[regexp {.*F([0-9]*\.[0-9]*)} $buf match submatch] == 1} {

                if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
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
        } else {
            if {[regexp {.*F([0-9]*\.[0-9]*)} $buf match submatch] == 1} {
                if {[$mom_feed_engage_value == $mom_feed_retract_value]} {
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

                    if {$submatch == $stepover_speed} {
                        regsub {F[0-9]*\.[0-9]*} $buf "F=R3" new_buf3
                        puts $write_ss $new_buf3
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

                    if {$submatch == $stepover_speed} {
                        regsub {F[0-9]*\.[0-9]*} $buf "F=R3" new_buf3
                        puts $write_ss $new_buf3
                        continue
                    }

                    if {$submatch == $retract_speed} {
                        regsub {F[0-9]*\.[0-9]*} $buf "F=R3" new_buf4
                        puts $write_ss $new_buf4
                        continue
                    }
                }
                
            
        }
        }
        puts $write_ss $buf
        
    }
    close $read_ss
    close $write_ss
    MOM_remove_file $tmp_file_name
    MOM_open_output_file $ptp_file_name

}


if { abs($mom_tool_axis(2)) == 1.0 && [format %.1f $mom_tool_axis(0)] == 0.0 && [format %.1f $mom_tool_axis(1)] == 0.0 } {
    MOM_output_literal "G17"
}
if { abs($mom_tool_axis(1)) == 1.0 && [format %.1f $mom_tool_axis(0)] == 0.0 && [format %.1f $mom_tool_axis(2)] == 0.0 } {
    MOM_output_literal "G18"
}
if { abs($mom_tool_axis(0)) == 1.0 && [format %.1f $mom_tool_axis(1)] == 0.0 && [format %.1f $mom_tool_axis(2)] == 0.0 } {
    MOM_output_literal "G19"
}


#进行刀具详细信息输出前，需要单独对T型刀进行一个判断，才能正确输出T型刀的刀具信息
if {[string equal $TC $mom_tool_type]} {
    MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] lower_rad=[format %.3f $mom_tool_lower_corner_radius] upper_rad=[format %.3f $mom_tool_upper_corner_radius] holder_Dia=[format %.3f $mom_tool_shank_diameter]"
} else {
    MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] Rad=[format %.3f $mom_tool_corner1_radius]"
}



proc PB_CMD_head_info_using {}
{
    global mom_feed_stepover_value
    global mom_feed_retract_value
    #层进速度并不是所有加工方式都有，因此后处理时需要加一个加工方式的判断，这样才不会报错。

    global mom_tool_name
    global mom_tool_diameter

    #普通牛鼻铣刀下半径
    global mom_tool_corner1_radius
    global mom_part_name
    global mom_date


    set Name $mom_operation_name
    set hole "hole_making"
    set dri "drill"

    set TC "Milling Tool-T Cutter"

    MOM_output_text "%_N_$Name\_MPF"
    MOM_output_text ";File :  $mom_part_name"
    MOM_output_text ";TIME :  $mom_date"
    MOM_output_text ";Programmer: Tryx"
    #MOM_output_text "$mom_tool_type"

    if {[string equal $TC $mom_tool_type]} {
        MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] lower_rad=[format %.3f $mom_tool_lower_corner_radius] upper_rad=[format %.3f $mom_tool_upper_corner_radius] holder_Dia=[format %.3f $mom_tool_shank_diameter]"
    } else {
        MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] Rad=[format %.3f $mom_tool_corner1_radius]"
    }

    #MOM_output_text "$mom_tool_lower_corner_radius"
    #MOM_output_text "$mom_tool_upper_corner_radius"
    #MOM_output_text "$mom_tool_shank_diameter"
    #MOM_output_text "$mom_tool_corner1_radius"
    #MOM_output_text "$mom_tool_corner2_radius"


    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
        MOM_output_literal ";the Process type is $mom_template_type"
        MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
        MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
    } else {
        MOM_output_literal ";the Process type is $mom_template_type"
        MOM_output_text "R1=[format "%.3f" $mom_feed_engage_value]"
        MOM_output_text "R2=[format "%.3f" $mom_feed_cut_value]"
        MOM_output_text "R3=[format "%.3f" $mom_feed_stepover_value]"
        MOM_output_text "$mom_feed_retract_value"
    }

}

proc PB_CMD_speed_change_backup {}
{
    #替换速度参数代码段
    global ptp_file_name
    global mom_template_type
    global mom_template_subtype

    set tmp_file_name "${ptp_file_name}_"
    if {[file exists $tmp_file_name]} {
        MOM_remove_file $tmp_file_name
    }

    MOM_close_output_file $ptp_file_name
    file rename $ptp_file_name $tmp_file_name

    set read_ss [open $tmp_file_name r]
    set write_ss [open $ptp_file_name w]

    global mom_machine_time
    global mom_feed_cut_value
    global mom_feed_engage_value
    global mom_feed_stepover_value

    puts $write_ss ";The Total TIME = [format "%.3f" $mom_machine_time] MIN."

    set buf ""
    set hole "hole_making"
    set dri "drill"

    #加入判断，加工模式，如果是孔类加工，则不选择参数R3，如果是铣削加工，则加上参数R3
    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
        set cut_speed [format "%.f" $mom_feed_cut_value]
        set engage_speed [format "%.f" $mom_feed_engage_value]
    } else {
        set cut_speed [format "%.f" $mom_feed_cut_value]
        set engage_speed [format "%.f" $mom_feed_engage_value]
        set stepover_speed [format "%.f" $mom_feed_stepover_value]

    }

    #puts $write_ss ";$cut_speed"
    #puts $write_ss ";$engage_speed"
    #puts $write_ss ";$stepover_speed"

    while {[gets $read_ss buf] > 0} {
        if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
            if {[regexp {.*F([0-9]*\.[0-9]*)} $buf match submatch] == 1} {
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

        }
        } else {
            if {[regexp {.*F([0-9]*\.[0-9]*)} $buf match submatch] == 1} {
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

            if {$submatch == $stepover_speed} {
                regsub {F[0-9]*\.[0-9]*} $buf "F=R3" new_buf3
                puts $write_ss $new_buf3
                continue
            }

        }
        }
        puts $write_ss $buf

    }
    close $read_ss
    close $write_ss
    MOM_remove_file $tmp_file_name
    MOM_open_output_file $ptp_file_name

}
