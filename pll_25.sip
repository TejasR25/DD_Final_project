set_global_assignment -entity "pll_25" -library "lib_pll_25" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_25" -library "lib_pll_25" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "pll_25" -library "lib_pll_25" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_25" -name SPD_FILE [file join $::quartus(sip_path) "pll_25.spd"]

set_global_assignment -library "lib_pll_25" -name MISC_FILE [file join $::quartus(sip_path) "pll_25_sim/pll_25.vo"]
