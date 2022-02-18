let rout_follow_colorscheme = 1
let Rout_more_colors = 1
let R_editing_mode = "vi"
let R_assign = 0
let R_auto_scroll = 0
let R_disable_cmds = ['RSetwd', 'RDputObj', 'RSummary']


" map jk as modified esc to exit terminal insert mode
tnoremap jk <C-\><C-n> 

" function! s:customNvimRMappings()
"    nmap <buffer> <LocalLeader>rs <Plug>RStart
" endfunction

augroup myNvimR
   au!
   autocmd FileType r,rmd nmap <buffer> <LocalLeader>rs <Plug>RStart
augroup end
