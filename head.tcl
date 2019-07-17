proc PB_CMD_HEAD_INFO2 {} {
    global mom_template_type
    global mom_template_subtype
    #用于确定加工模式, 还有子加工模式

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
    #层进速度并不是所有加工方式都有，因此后处理时需要加一个加工方式的判断，这样才不会报错。

    global mom_tool_name
    global mom_tool_diameter

    global mom_tool_corner1_radius
    global mom_part_name
    global mom_date

    #加入钻孔和孔加工判断，来区别加工模式
    set Name $mom_operation_name
    set hole "hole_making"
    set dri "drill"

    
    #a change in clone plus
    #a change in original 
    #用于判断是否为T型刀
    set TC "Milling Tool-T Cutter"
    #用于判断是否为钻头
    set DR "Drilling Tool"

    MOM_output_text ";%_N_$Name\_MPF"
    MOM_output_text ";File :  $mom_part_name"
    MOM_output_text ";TIME :  $mom_date"
    MOM_output_text ";Programmer: Tryx"
    #MOM_output_text "T=\"$mom_tool_name\""
    #MOM_output_text "M06"

    #判断当不存在下半径值时，将其赋值为0
    if {![info exists mom_tool_corner1_radius]} {set mom_tool_corner1_radius 0}

    if {[string equal $TC $mom_tool_type]} {
        MOM_output_text ";Current T-Cutter Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] lower_rad=[format %.3f $mom_tool_lower_corner_radius] upper_rad=[format %.3f $mom_tool_upper_corner_radius] holder_Dia=[format %.3f $mom_tool_shank_diameter]"
    } 
    if {[string equal $DR $mom_tool_type]} {
        MOM_output_text ";Current Drilling Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] Rad=[format %.3f $mom_tool_corner1_radius]"

    } else {
        MOM_output_text ";Current Tool: Name=$mom_tool_name Dia=[format %.3f $mom_tool_diameter] Rad=[format %.3f $mom_tool_corner1_radius]"
    }

    #加入一个对加工模式的判断，当是孔类加工时，不添加R3参数，否则会报错
    #加入判断，当进刀（engage），退刀（retract）不相同时，进行判断，多输出一个更改退刀的R参数
    if {[string equal $hole $mom_template_type] | [string equal $dri $mom_template_type]} {
            if {$mom_feed_engage_value == $mom_feed_retract_value} {
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
            if {$mom_feed_engage_value == $mom_feed_retract_value} {
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

}