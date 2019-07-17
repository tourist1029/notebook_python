proc PB_CMD_speed_change2 {} {
    #替换速度参数代码段
    global ptp_file_name
    global mom_template_type
    global mom_template_subtype
    global mom_operation_name
    global mom_group_name

    #写入DNC需要的传输头,这里加入判断，如果选择的是单个程序，组名变量是不存在的，通过这个判断，后处理的是单个程序，还是一个组的程序，输出程序头的名字对应
    if {info exists mom_group_name} {
        set Name $mom_group_name
    } else {
        set Name $mom_operation_name
    }
    

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

    puts $write_ss "%_N_$Name\_MPF"
    set hh [expr $mom_machine_time / 60]
    puts $write_ss ";The Total TIME = [format "%.3f" $hh] Hour."
    puts $write_ss ";The Total TIME = [format "%.3f" $mom_machine_time] MIN."

    set buf ""
    set hole "hole_making"
    set dri "drill"

    #加入判断，加工模式，如果是孔类加工，则不选择参数R3，如果是铣削加工，则加上参数R3
    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
        if {$mom_feed_engage_value == $mom_feed_retract_value} {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            #set retract_speed [format "%.f" $mom_feed_retract_value]
        } else {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set retract_speed [format "%.f" $mom_feed_retract_value]
        }
        
    } else {
        if {$mom_feed_engage_value == $mom_feed_retract_value} {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set stepover_speed [format "%.f" $mom_feed_stepover_value]
            set retract_speed $cut_speed
        } else {
            set cut_speed [format "%.f" $mom_feed_cut_value]
            set engage_speed [format "%.f" $mom_feed_engage_value]
            set stepover_speed [format "%.f" $mom_feed_stepover_value]
            set retract_speed [format "%.f" $mom_feed_retract_value]
        }
        

    }

    puts $write_ss ";$cut_speed"
    puts $write_ss ";$engage_speed"
    puts $write_ss ";$stepover_speed"
    puts $write_ss ";$mom_feed_engage_value"
    puts $write_ss ";$mom_feed_retract_value"

    while {[gets $read_ss buf] > 0} {
        if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
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
        } else {
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
                        regsub {F[0-9]*\.[0-9]*} $buf "F=R4" new_buf4
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