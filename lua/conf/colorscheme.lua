local F = {}

local function colorscheme_cmd(bg, theme)
    vim.o.background = bg
    vim.cmd.colorscheme(theme)
end

local scheme_options = {
    night = {
        { 'nightfox' },
        {
            'rose-pine',
            function()
                require('rose-pine').setup {
                    dark_variant = 'moon',
                    disable_italics = true,
                }
            end,
        },
        {
            'tokyonight',
            function()
                require('tokyonight').setup {
                    styles = {
                        comments = { italic = false },
                        keywords = { italic = false },
                    },
                }
            end,
        },
        {
            'everforest',
            function()
                vim.g.everforest_background = 'soft'
                vim.g.everforest_diagnostic_virtual_text = 'colored'
                vim.g.everforest_better_performance = 1
            end,
        },
        { 'gruvbox' },
        {
            'kanagawa',
            function()
                require('kanagawa').setup {
                    globalStatus = vim.o.laststatus == 3,
                    commentStyle = { italic = false },
                    keywordStyle = { italic = false },
                    variablebuiltinStyle = { italic = false },
                    statementStyle = { bold = false },
                }
            end,
        },
        {
            'catppuccin',
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
                        dap = true,
                        dap_ui = true,
                    },
                }
            end,
        },
    },
    day = {
        { 'dawnfox' },
        {
            'rose-pine',
            function()
                require('rose-pine').setup {
                    disable_italics = true,
                }
            end,
        },
        {
            'tokyonight',
            function()
                require('tokyonight').setup {
                    styles = {
                        comments = { italic = false },
                        keywords = { italic = false },
                    },
                }
            end,
        },
        {
            'everforest',
            function()
                vim.g.everforest_background = 'soft'
                vim.g.everforest_diagnostic_virtual_text = 'colored'
                vim.g.everforest_better_performance = 1
            end,
        },
        { 'gruvbox' },
        {
            'edge',
            function()
                vim.g.edge_diagnostic_virtual_text = 'colored'
                vim.g.edge_better_performance = 1
            end,
        },
        {
            'catppuccin',
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
                        dap = true,
                        dap_ui = true,
                    },
                }
            end,
        },
    },
}

local function pick_colorscheme(bg, id)
    if bg == 1 then -- background = dark
        if scheme_options.night[id][2] then
            scheme_options.night[id][2]()
        end
        colorscheme_cmd('dark', scheme_options.night[id][1])
    else -- background = light
        if scheme_options.day[id][2] then
            scheme_options.day[id][2]()
        end
        colorscheme_cmd('light', scheme_options.day[id][1])
    end
end

local day_to_night = 23
local night_to_day = 7

function F.pick_randomly()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    local time = os.date '*t'
    local bg
    local scheme_id
    local current_background

    if vim.env.CURRENT_BACKGROUND == 'night' or vim.env.CURRENT_BACKGROUND == 'day' then
        current_background = vim.env.CURRENT_BACKGROUND
    else
        if (time.hour <= night_to_day) or (time.hour >= day_to_night) then
            current_background = 'night'
        else
            current_background = 'day'
        end
    end

    scheme_id = math.random(1, #scheme_options[current_background])

    bg = current_background == 'night' and 1 or 2

    pick_colorscheme(bg, scheme_id)
end

local function switch_colorscheme_with_day_night()
    -- vim.notify('load colorscheme at ' .. os.date '%c', vim.log.levels.INFO)
    F.pick_randomly()

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

    vim.defer_fn(switch_colorscheme_with_day_night, total_ms_to_switch)
end

local function select_colorscheme_based_on_bg(bg)
    local theme_options_at_time

    if bg == 1 then
        theme_options_at_time = scheme_options.night
    else
        theme_options_at_time = scheme_options.day
    end

    local items_to_be_selected = {}

    for i = 1, #theme_options_at_time do
        table.insert(items_to_be_selected, i)
    end

    vim.ui.select(items_to_be_selected, {
        prompt = 'select one colorscheme',
        format_item = function(item)
            return theme_options_at_time[item][1]
        end,
    }, function(theme_id)
        -- when no value is selected, it will be nil. This is a breaking change
        -- behavior as previously `vim.ui.select` will be silently aborted
        -- rather than passing `nil` as an argument
        if theme_id then
            pick_colorscheme(bg, theme_id)
        end
    end)
end

function F.pick_quickly()
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
        if bg then
            select_colorscheme_based_on_bg(bg)
        end
    end)
end

switch_colorscheme_with_day_night()

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

local keymap = vim.api.nvim_set_keymap

keymap('n', '<Leader>mc', '', { noremap = true, desc = 'misc: pick color scheme', callback = F.pick_quickly })

return F
