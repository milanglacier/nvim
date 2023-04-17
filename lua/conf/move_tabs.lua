local M = {}

function M.move_to_prev_tab()
    if vim.fn.tabpagenr '$' == 1 and vim.fn.winnr '$' == 1 then
        return
    end

    local tab_nr = vim.fn.tabpagenr '$'
    local cur_buf = vim.fn.bufnr '%'

    if vim.fn.tabpagenr() ~= 1 then
        vim.cmd.close()
        if tab_nr == vim.fn.tabpagenr '$' then
            vim.cmd.tabprevious()
        end
        vim.cmd.split()
    else
        vim.cmd.close()
        vim.cmd.tabnew { range = { 0 } }
    end

    vim.cmd.buffer { count = cur_buf }
end

function M.move_to_next_tab()
    if vim.fn.tabpagenr '$' == 1 and vim.fn.winnr '$' == 1 then
        return
    end

    local tab_nr = vim.fn.tabpagenr '$'
    local cur_buf = vim.fn.bufnr '%'

    if vim.fn.tabpagenr() < tab_nr then
        vim.cmd.close()
        if tab_nr == vim.fn.tabpagenr '$' then
            vim.cmd.tabnext()
        end
        vim.cmd.split()
    else
        vim.cmd.close()
        vim.cmd.tabnew()
    end

    vim.cmd.buffer { count = cur_buf }
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
keymap('n', '<A-z>', [[<C-w>z]], opts_desc 'win: close preview win')
keymap('n', '<A-H>', [[<C-w>H]], opts_desc 'win: move to left')
keymap('n', '<A-J>', [[<C-w>J]], opts_desc 'win: move to below')
keymap('n', '<A-K>', [[<C-w>K]], opts_desc 'win: move to above')
keymap('n', '<A-L>', [[<C-w>L]], opts_desc 'win: move to right')
keymap('n', '<A-o>', [[<C-w>o]], opts_desc 'win: keep this only')
keymap('n', '<A-=>', [[<C-w>=]], opts_desc 'win: balance win w/h')
keymap('n', '<A-|>', [[<C-w>|]], opts_desc 'win: maximize win width')
keymap('n', '<A-_>', [[<C-w>_]], opts_desc 'win: maxmize win height')
keymap('n', '<A-<>', [[<C-w><]], opts_desc 'win: decrease win width')
keymap('n', '<A->>', [[<C-w>>]], opts_desc 'win: increase win width')
keymap('n', '<A-+>', [[<C-w>+]], opts_desc 'win: increase win height')
keymap('n', '<A-->', [[<C-w>-]], opts_desc 'win: decrease win height')

keymap('n', '<A-]>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(1)<CR>]], { noremap = true })
keymap('n', '<A-[>', [[<cmd>lua require('conf.move_tabs').scroll_in_float_win(-1)<CR>]], { noremap = true })

keymap(
    'n',
    '<Leader>wb',
    [[<cmd>lua require("conf.move_tabs").move_to_prev_tab()<CR>]],
    opts_desc 'win: move to prev tab'
)
keymap(
    'n',
    '<Leader>wf',
    [[<cmd>lua require("conf.move_tabs").move_to_next_tab()<CR>]],
    opts_desc 'win: move to next tab'
)

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
keymap('n', '<Leader>wz', [[<C-w>z]], opts_desc 'win: close preview win')
keymap('n', '<Leader>wH', [[<C-w>H]], opts_desc 'win: move to left')
keymap('n', '<Leader>wJ', [[<C-w>J]], opts_desc 'win: move to below')
keymap('n', '<Leader>wK', [[<C-w>K]], opts_desc 'win: move to above')
keymap('n', '<Leader>wL', [[<C-w>L]], opts_desc 'win: move to right')
keymap('n', '<Leader>wo', [[<C-w>o]], opts_desc 'win: keep this only')
keymap('n', '<Leader>w|', [[<C-w>|]], opts_desc 'win: maximize win width')
keymap('n', '<Leader>w_', [[<C-w>_]], opts_desc 'win: maxmize win height')
keymap('n', '<Leader>w=', [[<C-w>=]], opts_desc 'win: balance win w/h')
keymap('n', '<Leader>w<', [[<C-w><]], opts_desc 'win: decrease win width')
keymap('n', '<Leader>w>', [[<C-w>>]], opts_desc 'win: increase win width')
keymap('n', '<Leader>w+', [[<C-w>+]], opts_desc 'win: increase win height')
keymap('n', '<Leader>w-', [[<C-w>-]], opts_desc 'win: decrease win height')
keymap('n', '<Leader>w]', '<C-w>]', opts_desc 'win: jump to tags')
keymap('n', '<Leader>wg]', '<C-w>g]', opts_desc 'win: select tags to jump')

keymap('n', '<Leader><Tab>o', [[:tabonly<cr>]], opts_desc 'tab: delete other tabs')
keymap('n', '<Leader><Tab>n', [[:tabnew<cr>]], opts_desc 'tab: new tab')
keymap('n', '<Leader><Tab>c', [[:tabclose<cr>]], opts_desc 'tab: close this tab')
keymap('n', '<Leader><Tab>l', [[:tabmove +<cr>]], opts_desc 'tab: move tab to the right')
keymap('n', '<Leader><Tab>h', [[:tabmove -<cr>]], opts_desc 'tab: move tab to the left')
keymap('n', '<Leader><Tab>]', [[:tabnext<cr>]], opts_desc 'tab: next tab')
keymap('n', '<Leader><Tab>[', [[:tabprevious<cr>]], opts_desc 'tab: prev tab')
keymap('n', '<Leader><Tab>1', [[1gt]], opts_desc 'tab: 1st tab')
keymap('n', '<Leader><Tab>2', [[2gt]], opts_desc 'tab: 2nd tab')
keymap('n', '<Leader><Tab>3', [[3gt]], opts_desc 'tab: 3rd tab')
keymap('n', '<Leader><Tab>4', [[4gt]], opts_desc 'tab: 4th tab')
keymap('n', '<Leader><Tab>5', [[5gt]], opts_desc 'tab: 5th tab')
keymap('n', '<Leader><Tab>6', [[6gt]], opts_desc 'tab: 6th tab')
keymap('n', '<Leader><Tab>7', [[7gt]], opts_desc 'tab: 7th tab')
keymap('n', '<Leader><Tab>8', [[8gt]], opts_desc 'tab: 8th tab')
keymap('n', '<Leader><Tab>9', [[9gt]], opts_desc 'tab: 9th tab')

return M
