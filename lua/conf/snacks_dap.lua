local snacks = {}

local function snacks_notify(message, level)
    local ok, snacks_mod = pcall(require, 'snacks')
    if ok and snacks_mod.notify then
        snacks_mod.notify(message, level or vim.log.levels.INFO)
    else
        vim.notify(message, level or vim.log.levels.INFO)
    end
end

local function require_dap()
    local ok, dap = pcall(require, 'dap')
    if not ok then
        snacks_notify('nvim-dap is not available.', vim.log.levels.WARN)
        return nil
    end
    return dap
end

local function require_dap_session()
    local dap = require_dap()
    if not dap then
        return nil, nil
    end
    local session = dap.session()
    if not session then
        snacks_notify('No active DAP session.', vim.log.levels.INFO)
        return nil, nil
    end
    return dap, session
end

local function relative_path(path)
    if not path or path == '' then
        return '[No Name]'
    end
    return vim.fn.fnamemodify(path, ':.')
end

-- DAP
-- NOTE: Snacks does not provide pickers for dap.nvim. Therefore, we implement
-- some minimal pickers to handle basic DAP-related functionality, without
-- attempting to replicate the full capabilities of comprehensive picker
-- plugins such as Telescope or fzf.
snacks.dap_commands = function()
    local dap = require_dap()
    if not dap then
        return
    end

    local items = {}
    for name, fn in pairs(dap) do
        if type(fn) == 'function' then
            items[#items + 1] = {
                text = name,
                callback = fn,
                preview = {
                    text = ('Execute `%s`'):format(name),
                    ft = 'markdown',
                    loc = false,
                },
            }
        end
    end

    table.sort(items, function(a, b)
        return a.text < b.text
    end)

    require('snacks').picker {
        items = items,
        format = 'text',
        win = { preview = { minimal = true } },
        confirm = function(picker, item)
            picker:close()
            if not item or not item.callback then
                return
            end
            local ok, err = pcall(item.callback)
            if not ok then
                snacks_notify(('Failed to execute `%s`: %s'):format(item.text, err), vim.log.levels.ERROR)
            end
        end,
    }
end

snacks.dap_configurations = function()
    local dap = require_dap()
    if not dap then
        return
    end

    if dap.session() then
        snacks_notify('DAP session already active. Stop it before selecting a configuration.', vim.log.levels.WARN)
        return
    end

    local items = {}
    for filetype, configs in pairs(dap.configurations) do
        for _, config in ipairs(configs) do
            local name = config.name or 'Unnamed configuration'
            items[#items + 1] = {
                text = ('[%s] %s'):format(filetype, name),
                config = vim.deepcopy(config),
                preview = {
                    text = vim.inspect(config),
                    ft = 'lua',
                    loc = false,
                },
            }
        end
    end

    if #items == 0 then
        snacks_notify('No DAP configurations available.', vim.log.levels.INFO)
        return
    end

    require('snacks').picker {
        items = items,
        format = 'text',
        win = { preview = { minimal = false } },
        confirm = function(picker, item)
            picker:close()
            if not item or not item.config then
                return
            end
            dap.run(item.config)
        end,
    }
end

snacks.dap_breakpoints = function()
    local dap = require_dap()
    if not dap then
        return
    end

    local ok, dap_breakpoints = pcall(require, 'dap.breakpoints')
    if not ok then
        snacks_notify('Unable to load `dap.breakpoints`.', vim.log.levels.ERROR)
        return
    end

    local breakpoints = dap_breakpoints.get()
    if vim.tbl_isempty(breakpoints) then
        snacks_notify('Breakpoint list is empty.', vim.log.levels.INFO)
        return
    end

    local items = {}
    for bufnr, buf_breakpoints in pairs(breakpoints) do
        local path = vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or ''
        local display = relative_path(path)

        for _, bp in ipairs(buf_breakpoints) do
            local details = {}
            if bp.condition and bp.condition ~= '' then
                details[#details + 1] = ('if %s'):format(bp.condition)
            end
            if bp.logMessage and bp.logMessage ~= '' then
                details[#details + 1] = ('log "%s"'):format(bp.logMessage)
            end
            if bp.hitCondition and bp.hitCondition ~= '' then
                details[#details + 1] = ('hit %s'):format(bp.hitCondition)
            end

            local suffix = ''
            if #details > 0 then
                suffix = (' — %s'):format(table.concat(details, '; '))
            end

            items[#items + 1] = {
                text = ('%s:%d%s'):format(display, bp.line or 0, suffix),
                buf = bufnr,
                pos = { bp.line or 1, 0 },
                file = path ~= '' and path or nil,
            }
        end
    end

    table.sort(items, function(a, b)
        if a.file == b.file then
            return (a.pos[1] or 0) < (b.pos[1] or 0)
        end
        return (a.file or '') < (b.file or '')
    end)

    require('snacks').picker {
        items = items,
        format = 'file',
        show_empty = false,
    }
end

snacks.dap_variables = function()
    local _, session = require_dap_session()
    if not session then
        return
    end

    local frame = session.current_frame
    if not frame then
        snacks_notify('No active frame.', vim.log.levels.INFO)
        return
    end

    local scopes = frame.scopes or {}
    if vim.tbl_isempty(scopes) then
        snacks_notify('No variables available. Step the debugger to refresh scopes.', vim.log.levels.INFO)
        return
    end

    local items = {}
    for _, scope in ipairs(scopes) do
        for _, variable in ipairs(scope.variables or {}) do
            local type_name = variable.type or ''
            local label = type_name ~= '' and ('[%s] '):format(type_name) or ''
            items[#items + 1] = {
                text = ('%s%s = %s'):format(label, variable.name, variable.value),
                scope = scope.name,
                variable = variable,
                preview = {
                    text = table.concat({
                        ('Scope: %s'):format(scope.name),
                        ('Type: %s'):format(type_name ~= '' and type_name or 'unknown'),
                        ('Name: %s'):format(variable.name),
                        ('Value: %s'):format(variable.value),
                    }, '\n'),
                    ft = 'markdown',
                    loc = false,
                },
            }
        end
    end

    if #items == 0 then
        snacks_notify('No variables available for the current frame.', vim.log.levels.INFO)
        return
    end

    require('snacks').picker {
        items = items,
        format = 'text',
        win = { preview = { minimal = true } },
        confirm = function(picker)
            picker:close()
        end,
    }
end

snacks.dap_frames = function()
    local dap, session = require_dap_session()
    if not session then
        return
    end

    if not session.stopped_thread_id then
        snacks_notify('Unable to switch frames unless the debugger is stopped.', vim.log.levels.INFO)
        return
    end

    local thread = session.threads and session.threads[session.stopped_thread_id]
    local frames = thread and thread.frames or {}
    if vim.tbl_isempty(frames) then
        snacks_notify('No frames available.', vim.log.levels.INFO)
        return
    end

    local items = {}
    for index, frame in ipairs(frames) do
        local source = frame.source or {}
        local path = source.path or ''
        local relpath = relative_path(path ~= '' and path or source.name)
        local column = math.max((frame.column or 1) - 1, 0)

        items[#items + 1] = {
            text = ('%d. [%s] %s:%d'):format(index, frame.name or 'frame', relpath, frame.line or 0),
            frame = frame,
            file = path ~= '' and path or nil,
            pos = { frame.line or 1, column },
        }
    end

    require('snacks').picker {
        items = items,
        format = 'text',
        confirm = function(picker, item)
            picker:close()
            if not item or not item.frame then
                return
            end
            local session_ok, current_session = pcall(dap.session)
            if not session_ok or not current_session or not current_session.stopped_thread_id then
                snacks_notify('DAP session no longer active.', vim.log.levels.WARN)
                return
            end
            current_session:_frame_set(item.frame)
        end,
    }
end

return snacks
