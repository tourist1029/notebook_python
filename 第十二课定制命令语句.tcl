



#输出加工时间到程序头

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
set cutting_time "(CUTTING TIME: [ format  "%.2f" $mom_machine_time])"
puts "%"
puts $cutting_time
set buf ""

while { [gets $ifile buf] > 0 } {
puts $ofile $buf
}
close $ifile
close $ofile
MOM_remove_file $tmp_file_name
MOM_open_output_file $ptp_file_name








#输出刀具直径大小和圆角大小信息

 global mom_tool_diameter    
 global mom_tool_corner1_radius
     
MOM_output_literal "( D: [ format  "%.2f" $mom_tool_diameter] R: [ format  "%.2f" $mom_tool_corner1_radius] )"
