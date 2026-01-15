-- Adopted from the abandoned nvim-treesitter master branch.
-- Modified behavior:
-- Use get_node_range instead of get_node_text. Some languages place the
-- identifier of a function or class outside its body in the syntax tree,
-- making it impossible for Treesitter to capture the correct context using
-- get_node_text.
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/statusline.lua

local M = {}

local uv = vim.uv or vim.loop
local state = {
    cache = {},
    last_cleanup = 0,
}

-- Trim spaces and opening brackets from end
local transform_line = function(line)
    return vim.trim(line:gsub('%s*[%[%(%{]*%s*$', ''))
end

---@param node TSNode
---@param type_patterns string[]
---@param transform_fn fun(line: string): string
---@param bufnr integer
---@return string
local function get_line_for_node(node, type_patterns, transform_fn, bufnr)
    local node_type = node:type()
    local is_valid = false
    for _, rgx in ipairs(type_patterns) do
        if node_type:find(rgx) then
            is_valid = true
            break
        end
    end
    if not is_valid then
        return ''
    end

    local start_row = vim.treesitter.get_node_range(node)
    local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

    if not line or line == '' then
        return ''
    end

    line = transform_fn(line)
    -- Escape % to avoid statusline to evaluate content as expression
    ---@diagnostic disable-next-line: redundant-return-value
    return line:gsub('%%', '%%%%')
end

local function normalize_options(opts)
    local options = opts or {}
    if type(opts) == 'number' then
        options = { indicator_size = opts }
    end
    options.bufnr = options.bufnr or 0
    options.indicator_size = options.indicator_size or 100
    options.type_patterns = options.type_patterns
        or {
            'type_declaration',
            'class_declaration',
            'function_declaration',
            'method_declaration',
            'function_definition',
            'class_definition',
            'class_definition',
            -- for javascript
            'export_statement',
            -- for rust
            'impl_item',
            'struct_item',
            'function_item',
            -- for cpp
            'struct_specifier',
            'class_specifier',
        }
    options.transform_fn = options.transform_fn or transform_line
    options.separator = options.separator or ' -> '

    if options.debounce_ms == false then
        options.debounce_ms = 0
    elseif options.debounce_ms == nil then
        options.debounce_ms = 200
    end

    if not options.cache_cleanup_ms then
        options.cache_cleanup_ms = 10000
    end

    return options
end

local function cleanup_cache(options)
    local now = uv.now()
    if now - state.last_cleanup < options.cache_cleanup_ms then
        return
    end

    state.last_cleanup = now
    state.cache = {}
end

local function compute_statusline(options)
    if not vim.treesitter.get_parser(options.bufnr, nil, { error = false }) then
        return ''
    end

    local current_node = vim.treesitter.get_node()
    if not current_node then
        return ''
    end

    local lines = {}
    local expr = current_node

    while expr do
        local line = get_line_for_node(expr, options.type_patterns, options.transform_fn, options.bufnr)
        if line ~= '' then
            if not vim.tbl_contains(lines, line) then
                table.insert(lines, 1, line)
            end
        end
        ---@diagnostic disable-next-line: cast-local-type
        expr = expr:parent()
    end

    local text = table.concat(lines, options.separator)
    local text_len = #text
    if text_len > options.indicator_size then
        return '...' .. text:sub(text_len - options.indicator_size, text_len)
    end

    return text
end

function M.statusline(opts)
    local options = normalize_options(opts)

    cleanup_cache(options)

    local winid = vim.api.nvim_get_current_win()
    if options.bufnr == 0 then
        options.bufnr = vim.api.nvim_win_get_buf(winid)
    end

    local cache_key = options.cache_key or (winid .. ':' .. options.bufnr)
    local entry = state.cache[cache_key]
    if not entry then
        entry = { text = '', last_update = 0 }
        state.cache[cache_key] = entry
    end
    if options.debounce_ms <= 0 then
        entry.text = compute_statusline(options) or ''
        entry.last_update = uv.now()
        return entry.text
    end

    local now = uv.now()
    if now - entry.last_update >= options.debounce_ms then
        entry.text = compute_statusline(options) or ''
        entry.last_update = now
    end

    return entry.text
end

return M
