local M = {}
local api = vim.api
local fn = vim.fn

M.formatter = {}

local default_config = function()
    return {
        buflisted = true,
        scratch = true,
        ft = 'REPL',
        wincmd = 'belowright 15 split',
        metas = {
            aichat = { cmd = 'aichat', formatter = M.formatter.bracketed_pasting },
            radian = { cmd = 'radian', formatter = M.formatter.bracketed_pasting },
            ipython = { cmd = 'ipython', formatter = M.formatter.bracketed_pasting },
            python = { cmd = 'python', formatter = M.formatter.trim_empty_lines },
            R = { cmd = 'R', formatter = M.formatter.trim_empty_lines },
            -- bash version >= 4.4 supports bracketed paste mode. but macos
            -- shipped with bash 3.2, so we don't use bracketed paste mode for
            -- bash.
            bash = { cmd = 'bash', formatter = M.formatter.trim_empty_lines },
        },
        default_repl = 'aichat',
        close_on_exit = true,
    }
end

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
        api.nvim_buf_set_name(repl.bufnr, string.format('#%s#%d', repl.name, id))
    end
end

local function focus_repl(id)
    if not repl_is_valid(id) then
        -- if id is nil, print it as -1
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
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

local function create_repl(id, repl)
    if repl_is_valid(id) then
        vim.notify(string.format('REPL %d already exists, no new REPL is created', id))
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

    if repl == nil or repl == '' then
        repl = M.config.default_repl
    end
    local term = fn.termopen(M.config.metas[repl].cmd, opts)
    api.nvim_buf_set_name(bufnr, string.format('#%s#%d', repl, id))
    M.repls[id] = { bufnr = bufnr, term = term, name = repl }
end

-- get the id of the closest repl whose name is `NAME` from the `ID`
local function find_closest_repl_from_id_with_name(id, name)
    local closest_id = nil
    local closest_distance = math.huge
    for repl_id, repl in pairs(M.repls) do
        if repl.name == name then
            local distance = math.abs(repl_id - id)
            if distance < closest_distance then
                closest_id = repl_id
                closest_distance = distance
            end
            if distance == 0 then
                break
            end
        end
    end
    return closest_id
end

-- currently only support line-wise sending in both visual and operator mode.
local function get_lines(mode)
    local begin_mark = mode == 'operator' and "'[" or "'<"
    local end_mark = mode == 'operator' and "']" or "'>"

    local begin_line = fn.getpos(begin_mark)[2]
    local end_line = fn.getpos(end_mark)[2]
    return api.nvim_buf_get_lines(0, begin_line - 1, end_line, false)
end

function M.formatter.bracketed_pasting(lines)
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

function M.formatter.trim_empty_lines(lines)
    local cr = '\13'
    if #lines == 1 then
        return { lines[1] .. cr }
    else
        local new = {}
        for _, line in ipairs(lines) do
            if line ~= '' then
                table.insert(new, line)
            end
        end

        table.insert(new, cr)
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
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
        return
    end
    local lines = get_lines 'operator'
    lines = M.config.metas[M.repls[id].name].formatter(lines)
    fn.chansend(M.repls[id].term, lines)
end

M.send_motion_internal_to_closest_repl = function(_)
    local id = vim.v.prevcount == 0 and 1 or vim.v.prevcount
    id = find_closest_repl_from_id_with_name(id, vim.b[0].closest_repl_name)

    if not repl_is_valid(id) then
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
        return
    end
    local lines = get_lines 'operator'
    lines = M.config.metas[M.repls[id].name].formatter(lines)
    fn.chansend(M.repls[id].term, lines)
end

M.send_motion = function(closest_repl_name)
    if closest_repl_name then
        vim.b[0].closest_repl_name = closest_repl_name
        vim.o.operatorfunc = [[v:lua.require'REPL'.send_motion_internal_to_closest_repl]]
        api.nvim_feedkeys('g@', 'ni', false)
    else
        vim.b[0].closest_repl_name = nil
        vim.o.operatorfunc = [[v:lua.require'REPL'.send_motion_internal]]
        -- Those magic letters 'ni' are coming from Vigemus/iron.nvim and I am not
        -- quite understand the effect of those magic letters.
        api.nvim_feedkeys('g@', 'ni', false)
    end
end

M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', default_config(), opts or {})
end

api.nvim_create_user_command('REPLStart', function(opts)
    -- if calling the command without any count, we want count to become 1.
    create_repl(opts.count == 0 and 1 or opts.count, opts.args)
end, {
    count = true,
    nargs = '?',
    complete = function()
        local metas = {}
        for name, _ in pairs(M.config.metas) do
            table.insert(metas, name)
        end
        return metas
    end,
})

api.nvim_create_user_command('REPLCleanup', function()
    repl_cleanup()
end, { desc = 'clean invalid repls, and rearrange the repls order.' })

api.nvim_create_user_command('REPLFocus', function(opts)
    local id = opts.count == 0 and 1 or opts.count
    if opts.args ~= '' then
        id = find_closest_repl_from_id_with_name(id, opts.args)
    end
    focus_repl(id)
end, {
    count = true,
    nargs = '?',
    desc = [[Focus on the ith REPL. The first REPL is the default. If an
optional argument is provided, the function will attempt to focus on the
closest REPL with the specified name. For instance, `3REPLFocus ipython`
will focus on the closest ipython REPL relative to id 3.]],
})

api.nvim_create_user_command('REPLClose', function(opts)
    local id = opts.count == 0 and 1 or opts.count
    if opts.args ~= '' then
        id = find_closest_repl_from_id_with_name(id, opts.args)
    end
    if not repl_is_valid(id) then
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
        return
    end
    fn.chansend(M.repls[id].term, string.char(4))
    repl_cleanup()
end, {
    count = true,
    nargs = '?',
    desc = [[Close the ith REPL. The first REPL is the default. If an optional
argument is provided, the function will attempt to close the closest REPL
with the specified name. For instance, `3REPLClose ipython` will close the
closest ipython REPL relative to id 3.]],
})

api.nvim_create_user_command('REPLSendVisual', function(opts)
    -- we must use `<ESC>` to clear those marks to mark '> and '> to be able to
    -- access the updated visual range. Those magic letters 'nx' are coming
    -- from Vigemus/iron.nvim and I am not quiet understand the effect of those
    -- magic letters.
    api.nvim_feedkeys('\27', 'nx', false)

    local id = opts.count == 0 and 1 or opts.count
    if opts.args ~= '' then
        id = find_closest_repl_from_id_with_name(id, opts.args)
    end
    if not repl_is_valid(id) then
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
        return
    end
    local lines = get_lines 'visual'
    lines = M.config.metas[M.repls[id].name].formatter(lines)
    fn.chansend(M.repls[id].term, lines)
end, {
    count = true,
    nargs = '?',
    desc = [[Send the visual range to the ith REPL. For example, use
`REPLSendVisual` or `3REPLSendVisual` to specify the REPL number. If no
number is given, the first REPL is the default. If an optional argument is
provided, the function will attempt to send the visual range to the closest
REPL with the specified name. For instance, `3REPLSendVisual ipython` will
send the visual range to the closest ipython REPL relative to id 3.]],
})

api.nvim_create_user_command('REPLSendLine', function(opts)
    local id = opts.count == 0 and 1 or opts.count
    if opts.args ~= '' then
        id = find_closest_repl_from_id_with_name(id, opts.args)
    end
    if not repl_is_valid(id) then
        vim.notify(string.format("REPL %d doesn't exist", id or -1))
        return
    end
    local line = api.nvim_get_current_line()
    local lines = M.config.metas[M.repls[id].name].formatter { line }
    fn.chansend(M.repls[id].term, lines)
end, {
    count = true,
    nargs = '?',
    desc = [[Send current line to the ith REPL. For example, use `REPLSendLine`
or `3REPLSendLine` to specify the REPL number. If no number is given, the
first REPL is the default. If an optional argument is provided, the
function will attempt to send the current line to the closest REPL with the
specified name. For instance, `3REPLSendVisual ipython` will send the
visual range to the closest ipython REPL relative to id 3.]],
})

return M
