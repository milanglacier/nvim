local M = {}

local function colorscheme_cmd(bg, theme)
    vim.o.background = bg
    vim.cmd.colorscheme(theme)
end

local night_scheme_options = {
    name = {
        'nightfox',
        'rose-pine',
        'tokyonight',
        'everforest',
        'gruvbox',
        'kanagawa',
        'catppuccin',
    },
    cmd = {
        function() end,
        function()
            require('rose-pine').setup {
                dark_variant = 'moon',
                disable_italics = true,
            }
        end,
        function()
            vim.g.tokyonight_style = 'night'
            vim.g.tokyonight_italic_keywords = false
            vim.g.tokyonight_italic_comments = false
        end,
        function()
            vim.g.everforest_background = 'soft'
            vim.g.everforest_diagnostic_virtual_text = 'colored'
            vim.g.everforest_better_performance = 1
            require('lazy').load { plugins = { 'everforest' } }
        end,
        function() end,
        function()
            require('kanagawa').setup {
                globalStatus = vim.o.laststatus == 3,
                commentStyle = { italic = false },
                keywordStyle = { italic = false },
                variablebuiltinStyle = { italic = false },
                statementStyle = { bold = false },
            }
        end,
        function()
            vim.g.catppuccin_flavour = 'mocha'
            require('catppuccin').setup {
                term_colors = true,
                styles = {
                    comments = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                },
                integrations = {
                    lsp_trouble = true,
                    neogit = true,
                    ts_rainbow = true,
                    which_key = true,
                    lsp_saga = true,
                    notify = true,
                    mini = true,
                    vim_sneak = true,
                    dap = {
                        enabled = true,
                        enable_ui = true,
                    },
                },
            }
        end,
    },
}

local day_scheme_options = {
    name = {
        'dawnfox',
        'rose-pine',
        'tokyonight',
        'everforest',
        'gruvbox',
        'edge',
        'catppuccin',
    },
    cmd = {
        function() end,
        function()
            require('rose-pine').setup {
                disable_italics = true,
            }
        end,
        function()
            vim.g.tokyonight_style = 'day'
            vim.g.tokyonight_italic_keywords = false
            vim.g.tokyonight_italic_comments = false
        end,
        function()
            vim.g.everforest_background = 'soft'
            vim.g.everforest_diagnostic_virtual_text = 'colored'
            vim.g.everforest_better_performance = 1
        end,
        function() end,
        function()
            vim.g.edge_diagnostic_virtual_text = 'colored'
            vim.g.edge_better_performance = 1
            require('lazy').load { plugins = { 'edge' } }
        end,
        function()
            vim.g.catppuccin_flavour = 'latte'
            require('catppuccin').setup {
                term_colors = true,
                styles = {
                    comments = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                },
                integrations = {
                    lsp_trouble = true,
                    neogit = true,
                    ts_rainbow = true,
                    which_key = true,
                    lsp_saga = true,
                    notify = true,
                    mini = true,
                    vim_sneak = true,
                    dap = {
                        enabled = true,
                        enable_ui = true,
                    },
                },
            }
        end,
    },
}

local pick_colorscheme = function(bg, theme_id)
    if bg == 1 then -- background = dark
        night_scheme_options.cmd[theme_id]()
        colorscheme_cmd('dark', night_scheme_options.name[theme_id])
    else -- background = light
        day_scheme_options.cmd[theme_id]()
        colorscheme_cmd('light', day_scheme_options.name[theme_id])
    end
end

local day_to_night = 23
local night_to_day = 7

function M.pick_randomly()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    local time = os.date '*t'
    local bg = 1
    local rd = 0

    if (time.hour <= night_to_day) or (time.hour >= day_to_night) then
        bg = 1
        rd = math.random(1, #night_scheme_options.name)
    else
        bg = 2
        rd = math.random(1, #day_scheme_options.name)
    end

    pick_colorscheme(bg, rd)
end

function M.switch_colorscheme_with_day_night()
    -- vim.notify('load colorscheme at ' .. os.date '%c', vim.log.levels.INFO)
    M.pick_randomly()

    local time = os.date '*t'
    local hour_point_to_switch
    if time.hour >= day_to_night then
        hour_point_to_switch = 24 + night_to_day
    elseif time.hour < night_to_day then
        hour_point_to_switch = night_to_day
    else
        hour_point_to_switch = day_to_night
    end

    local mins_to_next_hour = 60 - time.min
    local hours_to_switch = hour_point_to_switch - (time.hour + 1)
    local total_ms_to_switch = (hours_to_switch * 60 + mins_to_next_hour) * 60 * 1000

    vim.defer_fn(M.switch_colorscheme_with_day_night, total_ms_to_switch)
end

local function select_colorscheme_based_on_bg(bg)
    local theme_options

    if bg == 1 then
        theme_options = night_scheme_options
    else
        theme_options = day_scheme_options
    end

    local items_to_be_selected = {}

    for i = 1, #theme_options.name do
        table.insert(items_to_be_selected, i)
    end

    vim.ui.select(items_to_be_selected, {
        prompt = 'select one colorscheme',
        format_item = function(item)
            return theme_options.name[item]
        end,
    }, function(theme_id)
        pick_colorscheme(bg, theme_id)
    end)
end

function M.pick_quickly()
    vim.ui.select({ 1, 2 }, {
        prompt = 'select the background of the colorscheme',
        format_item = function(item)
            if item == 1 then
                return 'dark'
            else
                return 'light'
            end
        end,
    }, function(bg)
        select_colorscheme_based_on_bg(bg)
    end)
end

local set_hl = vim.api.nvim_set_hl
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

autocmd('ColorScheme', {
    group = my_augroup,
    callback = function()
        set_hl(0, 'Cursor', { reverse = true })
    end,
    desc = 'set cursor highlight to reverse',
})

M.switch_colorscheme_with_day_night()

-- the color scheme at start up is loaded, next will
-- change the state to indicate when loading a new theme
-- at run time, /plugin/* should be sourced

local keymap = vim.api.nvim_set_keymap

keymap(
    'n',
    '<Leader>mc',
    "<CMD>lua require('conf.colorscheme').pick_quickly()<CR>",
    { noremap = true, desc = 'misc: pick color scheme' }
)

return M
