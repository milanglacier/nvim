local M = {}
local api = vim.api
local fn = vim.fn

local default_config = {
    buflisted = true,
    scratch = true,
    ft = 'REPL',
    wincmd = 'belowright 15 split',
    cmd = 'aichat',
    close_on_exit = true,
}

M.config = default_config

M.repls = {}

local function repl_is_valid(id)
    return M.repls[id] ~= nil and api.nvim_buf_is_loaded(M.repls[id].bufnr)
end

-- rearrange repls such that there's no gap in the repls table.
local function repl_cleanup()
    local valid_repls = {}
    local valid_repls_id = {}
    for id, _ in pairs(M.repls) do
        if repl_is_valid(id) then
            table.insert(valid_repls_id, id)
        end
    end

    table.sort(valid_repls_id)

    for _, id in ipairs(valid_repls_id) do
        table.insert(valid_repls, M.repls[id])
    end
    M.repls = valid_repls

    for id, repl in pairs(M.repls) do
        api.nvim_buf_set_name(repl.bufnr, string.format('#aichat#%d', id))
    end
end

local function focus_repl(id)
    if not repl_is_valid(id) then
        return
    end
    local win = fn.bufwinid(M.repls[id].bufnr)
    if win ~= -1 then
        api.nvim_set_current_win(win)
    else
        vim.cmd(M.config.wincmd)
        api.nvim_set_current_buf(M.repls[id].bufnr)
    end
end

local function create_repl(id)
    if repl_is_valid(id) then
        focus_repl(id)
        return
    end

    local bufnr = api.nvim_create_buf(M.config.buflisted, M.config.scratch)
    api.nvim_buf_set_option(bufnr, 'filetype', M.config.ft)
    vim.cmd(M.config.wincmd)
    api.nvim_set_current_buf(bufnr)

    local opts = {}
    if M.config.close_on_exit then
        opts.on_exit = function()
            local bufwinid = fn.bufwinid(bufnr)
            while bufwinid ~= -1 do
                api.nvim_win_close(bufwinid, true)
                bufwinid = fn.bufwinid(bufnr)
            end
            api.nvim_buf_delete(bufnr, { force = true })
        end
    end

    local term = fn.termopen(M.config.cmd, opts)
    api.nvim_buf_set_name(bufnr, string.format('#aichat#%d', id))
    M.repls[id] = { bufnr = bufnr, term = term }
end

-- currently only support line-wise sending in both visual and operator mode.
local function get_lines(mode)
    local begin_mark = mode == 'operator' and "'[" or "'<"
    local end_mark = mode == 'operator' and "']" or "'>"

    local begin_line = fn.getpos(begin_mark)[2]
    local end_line = fn.getpos(end_mark)[2]
    return api.nvim_buf_get_lines(0, begin_line - 1, end_line, 0)
end

local function bracketed_pasting(lines)
    local open_code = '\27[200~'
    local close_code = '\27[201~'
    local cr = '\13'
    if #lines == 1 then
        return { lines[1] .. cr }
    else
        local new = { open_code .. lines[1] }
        for line = 2, #lines do
            table.insert(new, lines[line])
        end

        table.insert(new, close_code .. cr)

        return new
    end
end

M.send_motion_internal = function(_)
    -- The `vim.v.count` variable refers to the count of motions. For example,
    -- in `y2ap`, `vim.v.count` would equal 2. To obtain the count of the
    -- normal keymap, rather than the motion count, use `vim.v.prevcount`. For
    -- instance, to obtain 3 from `3y2ap`, use `vim.v.prevcount`.
    local id = vim.v.prevcount == 0 and 1 or vim.v.prevcount

    if not repl_is_valid(id) then
        return
    end
    local lines = get_lines 'operator'
    lines = bracketed_pasting(lines)
    fn.chansend(M.repls[id].term, lines)
end

M.send_motion = function()
    vim.o.operatorfunc = [[v:lua.require'aichat_repl'.send_motion_internal]]
    -- Those magic letters 'ni' are coming from Vigemus/iron.nvim and I am not
    -- quite understand the effect of those magic letters.
    api.nvim_feedkeys('g@', 'ni', false)
end

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

api.nvim_create_user_command('AichatStart', function(opts)
    -- if calling the command without any count, we want count to become 1.
    create_repl(opts.count == 0 and 1 or opts.count)
end, { count = true })

api.nvim_create_user_command('AichatCleanup', function()
    repl_cleanup()
end, { desc = 'clean invalid repls, and rearrange the repls order.' })

api.nvim_create_user_command('AichatFocus', function(opts)
    focus_repl(opts.count == 0 and 1 or opts.count)
end, { count = true })

api.nvim_create_user_command('AichatClose', function(opts)
    local id = opts.count == 0 and 1 or opts.count
    if not repl_is_valid(id) then
        return
    end
    fn.chansend(M.repls[id].term, string.char(4))
    repl_cleanup()
end, { count = true })

api.nvim_create_user_command('AichatSendVisual', function(opts)
    -- we must use `<ESC>` to clear those marks to mark '> and '> to be able to
    -- access the updated visual range. Those magic letters 'nx' are coming
    -- from Vigemus/iron.nvim and I am not quiet understand the effect of those
    -- magic letters.
    api.nvim_feedkeys('\27', 'nx', false)

    local id = opts.count == 0 and 1 or opts.count
    if not repl_is_valid(id) then
        return
    end
    local lines = get_lines 'visual'
    lines = bracketed_pasting(lines)
    fn.chansend(M.repls[id].term, lines)
end, { count = true })

api.nvim_create_user_command('AichatSendLine', function(opts)
    local id = opts.count == 0 and 1 or opts.count
    if not repl_is_valid(id) then
        return
    end
    local line = api.nvim_get_current_line()
    line = bracketed_pasting { line }
    fn.chansend(M.repls[id].term, line)
end, { count = true })

return M
