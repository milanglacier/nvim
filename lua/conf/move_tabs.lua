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

local function opts_desc(desc)
    return {
        noremap = true,
        desc = desc,
    }
end

keymap('n', '<A-f>', [[<cmd>lua require("conf.move_tabs").move_to_prev_tab()<CR>]], opts_desc 'win: move to prev tab')
keymap('n', '<A-b>', [[<cmd>lua require("conf.move_tabs").move_to_next_tab()<CR>]], opts_desc 'win: move to next tab')

keymap('n', '<A-w>', [[<C-w>w]], opts_desc 'win: switch win')
keymap('n', '<A-p>', [[<C-w>p]], opts_desc 'win: prev win')
keymap('n', '<A-t>', [[<C-w>T]], opts_desc 'win: move to new tab')
keymap('n', '<A-q>', [[<C-w>q]], opts_desc 'win: quit win')
keymap('n', '<A-v>', [[<C-w>v]], opts_desc 'win: vsplit')
keymap('n', '<A-s>', [[<C-w>s]], opts_desc 'win: hsplit')
keymap('n', '<A-h>', [[<C-w>h]], opts_desc 'win: go to left')
keymap('n', '<A-j>', [[<C-w>j]], opts_desc 'win: go to below')
keymap('n', '<A-k>', [[<C-w>k]], opts_desc 'win: go to above')
keymap('n', '<A-l>', [[<C-w>l]], opts_desc 'win: go to right')
keymap('n', '<A-H>', [[<C-w>H]], opts_desc 'win: move to left')
keymap('n', '<A-J>', [[<C-w>J]], opts_desc 'win: move to below')
keymap('n', '<A-K>', [[<C-w>K]], opts_desc 'win: move to above')
keymap('n', '<A-L>', [[<C-w>L]], opts_desc 'win: move to right')
keymap('n', '<A-o>', [[<C-w>o]], opts_desc 'win: keep this only') -- keep only current window
keymap('n', '<A-=>', [[<C-w>=]], opts_desc 'win: balance win w/h') -- balance width/height of wins

keymap('n', '<A-]>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(1)<CR>]], { noremap = true })
keymap('n', '<A-[>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(-1)<CR>]], { noremap = true })

keymap('n', '<Leader>wb', [[<cmd>lua require("conf.move_tabs").move_to_prev_tab()<CR>]], opts_desc 'win: move to prev tab')
keymap('n', '<Leader>wf', [[<cmd>lua require("conf.move_tabs").move_to_next_tab()<CR>]], opts_desc 'win: move to next tab')

keymap('n', '<Leader>ww', [[<C-w>w]], opts_desc 'win: switch win')
keymap('n', '<Leader>wp', [[<C-w>p]], opts_desc 'win: go to prev win')
keymap('n', '<Leader>wT', [[<C-w>T]], opts_desc 'win: move to new tab')
keymap('n', '<Leader>wq', [[<C-w>q]], opts_desc 'win: quit win')
keymap('n', '<Leader>wv', [[<C-w>v]], opts_desc 'win: vsplit')
keymap('n', '<Leader>ws', [[<C-w>s]], opts_desc 'win: hsplit')
keymap('n', '<Leader>wh', [[<C-w>h]], opts_desc 'win: go to left')
keymap('n', '<Leader>wj', [[<C-w>j]], opts_desc 'win: go to below')
keymap('n', '<Leader>wk', [[<C-w>k]], opts_desc 'win: go to above')
keymap('n', '<Leader>wl', [[<C-w>l]], opts_desc 'win: go to right')
keymap('n', '<Leader>wH', [[<C-w>H]], opts_desc 'win: move to left')
keymap('n', '<Leader>wJ', [[<C-w>J]], opts_desc 'win: move to below')
keymap('n', '<Leader>wK', [[<C-w>K]], opts_desc 'win: move to above')
keymap('n', '<Leader>wL', [[<C-w>L]], opts_desc 'win: move to right')
keymap('n', '<Leader>wo', [[<C-w>o]], opts_desc 'win: keep this only') -- keep only current window
keymap('n', '<Leader>w|', [[<C-w>|]], opts_desc 'win: maximize win width') -- maxmize width of current win
keymap('n', '<Leader>w_', [[<C-w>_]], opts_desc 'win: maxmize win height') -- maxmize height of current win
keymap('n', '<Leader>w=', [[<C-w>=]], opts_desc 'win: balance win w/h') -- balance width/height of wins

return M
