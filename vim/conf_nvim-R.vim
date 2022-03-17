let rout_follow_colorscheme = 1
let Rout_more_colors = 1
let R_editing_mode = "vi"
let R_assign = 0
let R_auto_scroll = 0
let R_disable_cmds = ['RSetwd', 'RDputObj', 'RSummary']
let R_buffer_opts = "winfixwidth winfixheight buflisted"
let R_set_omnifunc = []
let R_non_r_compl = 0
let g:markdown_fenced_languages = []
let g:rmd_fenced_languages = []
let R_app = CONDA_PATHNAME .. "/bin/radian"
let R_cmd = "R"
let R_bracketed_paste = 1


" map jk as modified esc to exit terminal insert mode

" function! s:customNvimRMappings()
"    nmap <buffer> <LocalLeader>rs <Plug>RStart
" endfunction

augroup myNvimR
    au!
    autocmd FileType r,rmd nmap <buffer> <LocalLeader>rs <Plug>RStart
augroup end
