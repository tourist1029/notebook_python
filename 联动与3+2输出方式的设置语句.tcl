# This command is the port for user to chose the output TCP mode and 3+2 axis
# machining mode, change value of below variables to get different output
#
# 05-09-2013 levi - seperate this command from PB_CMD_set_default_dpp_value

  global dpp_ge

## dpp_ge(sys_coord_rotation_output_type)
## "WCS_ROTATION"  G68
## "SWIVELING"     G68.2

## dpp_ge(sys_tcp_tool_axis_output_mode)
## "AXIS"    output the rotation angle of axis (G43.4)
## "VECTOR"  output tool axis vector(G43.5)

## dpp_ge(sys_output_coord_mode)
## "TCP_FIX_TABLE"    use a coordinate system fixed on the table as the programming coordinate system
## "TCP_FIX_MACHINE"  use workpiece coordinate system fixed on machine as the programming coordinate system

# Do customization here to get different output
  set dpp_ge(sys_coord_rotation_output_type) "SWIVELING"
  set dpp_ge(sys_tcp_tool_axis_output_mode) "AXIS"
  set dpp_ge(sys_output_coord_mode) "TCP_FIX_MACHINE"; #this variable will be force 