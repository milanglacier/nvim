local M = {}

function M.move_to_prev_tab()
    if vim.fn.tabpagenr '$' == 1 and vim.fn.winnr '$' == 1 then
        return
    end

    local tab_nr = vim.fn.tabpagenr '$'
    local cur_buf = vim.fn.bufnr '%'

    if vim.fn.tabpagenr() ~= 1 then
        vim.cmd 'close!'
        if tab_nr == vim.fn.tabpagenr '$' then
            vim.cmd 'tabprev'
        end
        vim.cmd 'sp'
    else
        vim.cmd 'close!'
        vim.cmd '0tabnew'
    end

    vim.cmd('b' .. cur_buf)
end

function M.move_to_next_tab()
    if vim.fn.tabpagenr '$' == 1 and vim.fn.winnr '$' == 1 then
        return
    end

    local tab_nr = vim.fn.tabpagenr '$'
    local cur_buf = vim.fn.bufnr '%'

    if vim.fn.tabpagenr() < tab_nr then
        vim.cmd 'close!'
        if tab_nr == vim.fn.tabpagenr '$' then
            vim.cmd 'tabnext'
        end
        vim.cmd 'sp'
    else
        vim.cmd 'close!'
        vim.cmd 'tabnew'
    end

    vim.cmd('b' .. cur_buf)
end

function M.scroll_in_float_win(move_step)
    local windows = vim.api.nvim_list_wins()

    for _, winid in ipairs(windows) do
        -- the float window's relative is none,
        -- then we can capture the float window
        if vim.api.nvim_win_get_config(winid).relative ~= '' then
            local bufid = vim.api.nvim_win_get_buf(winid)
            local max_line_num = vim.api.nvim_buf_line_count(bufid)
            local col_idx = vim.api.nvim_win_get_cursor(winid)[2]

            if move_step < 0 then
                -- upward moving
                -- if the top visible line of the current window
                -- is the first line, then don't do any move
                local row_idx = vim.fn.getwininfo(winid)[1].topline

                if row_idx + move_step <= 0 then
                    break
                end
                -- set the cursor to the top visible line - 1
                vim.api.nvim_win_set_cursor(winid, { row_idx + move_step, col_idx })
                break
            else
                -- downward moving
                -- if the bottom visible line of the current window
                -- is the last line, then don't do any move
                local row_idx = vim.fn.getwininfo(winid)[1].botline

                if row_idx + move_step > max_line_num then
                    break
                end
                -- set the cursor to the bottom visible line + 1
                vim.api.nvim_win_set_cursor(winid, { row_idx + move_step, col_idx })
                break
            end
        end
    end
end

local keymap = vim.api.nvim_set_keymap

keymap('n', '<A-f>', [[<cmd>lua require("conf.move_tabs").move_to_prev_tab()<CR>]], { noremap = true })
keymap('n', '<A-b>', [[<cmd>lua require("conf.move_tabs").move_to_next_tab()<CR>]], { noremap = true })

keymap('n', '<A-w>', [[<C-w>w]], { noremap = true })
keymap('n', '<A-p>', [[<C-w>p]], { noremap = true })
keymap('n', '<A-t>', [[<C-w>T]], { noremap = true })
keymap('n', '<A-q>', [[<C-w>q]], { noremap = true })
keymap('n', '<A-v>', [[<C-w>v]], { noremap = true })
keymap('n', '<A-s>', [[<C-w>s]], { noremap = true })
keymap('n', '<A-h>', [[<C-w>h]], { noremap = true })
keymap('n', '<A-j>', [[<C-w>j]], { noremap = true })
keymap('n', '<A-k>', [[<C-w>k]], { noremap = true })
keymap('n', '<A-l>', [[<C-w>l]], { noremap = true })
keymap('n', '<A-H>', [[<C-w>H]], { noremap = true })
keymap('n', '<A-J>', [[<C-w>J]], { noremap = true })
keymap('n', '<A-K>', [[<C-w>K]], { noremap = true })
keymap('n', '<A-L>', [[<C-w>L]], { noremap = true })
keymap('n', '<A-o>', [[<C-w>o]], { noremap = true }) -- keep only current window

keymap('n', '<A-m>', [[<C-w>|]], { noremap = true }) -- maxmize width of current win
keymap('n', '<A-n>', [[<C-w>_]], { noremap = true }) -- maxmize height of current win
keymap('n', '<A-=>', [[<C-w>=]], { noremap = true }) -- balance width/height of wins

keymap('n', '<A-]>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(1)<CR>]], { noremap = true })
keymap('n', '<A-[>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(-1)<CR>]], { noremap = true })

return M
