-- Adopted from the abandoned nvim-treesitter master branch.
-- Modified behavior:
-- Use get_node_range instead of get_node_text. Some languages place the
-- identifier of a function or class outside its body in the syntax tree,
-- making it impossible for Treesitter to capture the correct context using
-- get_node_text.
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/statusline.lua

local M = {}

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

function M.statusline(opts)
    if not vim.treesitter.get_parser(nil, nil, { error = false }) then
        return
    end
    local options = opts or {}
    if type(opts) == 'number' then
        options = { indicator_size = opts }
    end
    local bufnr = options.bufnr or 0
    local indicator_size = options.indicator_size or 100
    local type_patterns = options.type_patterns
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
    local transform_fn = options.transform_fn or transform_line
    local separator = options.separator or ' -> '
    local allow_duplicates = options.allow_duplicates or false

    local current_node = vim.treesitter.get_node()
    if not current_node then
        return ''
    end

    local lines = {}
    local expr = current_node

    while expr do
        local line = get_line_for_node(expr, type_patterns, transform_fn, bufnr)
        if line ~= '' then
            if allow_duplicates or not vim.tbl_contains(lines, line) then
                table.insert(lines, 1, line)
            end
        end
        ---@diagnostic disable-next-line: cast-local-type
        expr = expr:parent()
    end

    local text = table.concat(lines, separator)
    local text_len = #text
    if text_len > indicator_size then
        return '...' .. text:sub(text_len - indicator_size, text_len)
    end

    return text
end

return M
