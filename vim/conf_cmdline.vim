let cmdline_map_start          = '<LocalLeader>rs' " REPLStart
let cmdline_map_send           = '<LocalLeader>ss' "send selection
let cmdline_map_send_and_stay  = '<LocalLeader>sas' "send and stay
let cmdline_map_source_fun     = '<LocalLeader>sf' "send function
let cmdline_map_send_paragraph = '<LocalLeader>sp' "send paragraph
let cmdline_map_send_block     = '<LocalLeader>sb' "send block
let cmdline_map_send_motion    = '<LocalLeader>sm' "send motion
let cmdline_map_quit           = '<LocalLeader>rq' "REPL quit


let cmdline_app           = {}
let cmdline_app['python']   = CONDA_PATHNAME . '/bin/ipython'

let cmdline_follow_colorscheme = 1
