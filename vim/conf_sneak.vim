if exists('g:vscode')
    let g:sneak#label = 0
else
    let g:sneak#label = 1
endif

let g:sneak#use_ic_scs = 1

map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
