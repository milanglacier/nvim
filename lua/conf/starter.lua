local autocmd = vim.api.nvim_create_autocmd
local set_hl = vim.api.nvim_set_hl
local api = vim.api
local starter_group = api.nvim_create_augroup('Starter', {})

set_hl(0, 'StarterVerse', { link = 'Title' })
set_hl(0, 'StarterQuote', { link = 'SpecialChar' })
set_hl(0, 'StarterItem', { link = 'String' })
set_hl(0, 'StarterKey', { link = 'Delimiter' })

autocmd('ColorScheme', {
    group = starter_group,
    callback = function()
        -- when colorscheme is changed, the highlight will be cleared. We want
        -- to reattach those linked highlight.
        set_hl(0, 'StarterVerse', { link = 'Title' })
        set_hl(0, 'StarterQuote', { link = 'SpecialChar' })
        set_hl(0, 'StarterItem', { link = 'String' })
        set_hl(0, 'StarterKey', { link = 'Delimiter' })
    end,
    desc = 'set highlight for starter',
})

local H = {}

H.header_verse = {
    {
        [[Bright star, would I were steadfast as thee art!]],
        [[ John Keats]],
    },
    {
        [[For Clattering Parrots to launch their fleet at sunrise]],
        [[For April to ignite the African violet]],
        [[ Derek Walcott]],
    },
    {
        [[In these poinsettia meadows of her tides,—]],
        [[Adagios of islands, O my Prodigal]],
        [[Complete the dark confessions her veins spell.]],
        [[ Hart Crane]],
    },
    {
        [[帝子降兮北渚，目眇眇兮愁予，]],
        [[袅袅兮秋风，洞庭波兮木叶下。]],
        [[ 《湘夫人》]],
    },
    {
        [[美人迈兮音尘阙，隔千里兮共明月。]],
        [[临风叹兮将焉歇，川路长兮不可越！]],
        [[ 《月赋》]],
    },
    {
        [[浴兰汤兮沐芳，华采衣兮若英。]],
        [[灵连蜷兮既留，烂昭昭兮未央。]],
        [[蹇将憺兮寿宫，与日月兮齐光。]],
        [[ 《云中君》]],
    },
}

H.foot_verse = {
    {
        [[Whispers antiphonal in the azure swing...]],
        [[ Hart Crane]],
    },
    {
        [[In the drumming world that dampens your tired eyes]],
        [[Behind two clouding lenses, sunrise, sunset,]],
        [[The quiet ravage of diabetes.]],
        [[ Derek Walcott]],
    },
    {
        [[What words]],
        [[Can strangle this deaf moonlight? For we]],
        [[Are overtaken.]],
        [[ Hart Crane]],
    },
    {
        [[搴汀洲兮杜若，将以遗兮远者。]],
        [[时不可兮骤得，聊逍遥兮容与！]],
        [[ 《湘夫人》]],
    },
    {
        [[月既没兮露欲晞，岁方晏兮无与归。]],
        [[佳期可以还，微霜沾人衣。]],
        [[ 《月赋》]],
    },
    {
        [[雷填填兮雨冥冥，猨啾啾兮狖夜鸣。]],
        [[风飒飒兮木萧萧，思公子兮徒离忧。]],
        [[ 《山鬼》]],
    },
}

local function get_key(str)
    return string.match(str, '.*%[(.)%].')
end

local function refresh()
    local buf_id = api.nvim_get_current_buf()

    local content = H.starter_content()

    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, content)
end

local item_sign = ' '
local lines_between_sections = 8
local top_lines_padding = 3
-- The absolute symmetry is in fact less aesthetically pleasing than a slight
-- leftward skew.
local left_skewed_columns = 15

H.items = {
    {
        action = require('conf.colorscheme').pick_randomly,
        name = 'New [T]heme    ',
    },
    { action = refresh, name = 'New [V]erses   ' },
    { action = 'Lazy profile', name = 'Neovim [I]nfo  ' },
    { action = 'Telescope projects', name = 'Open [P]rojects' },
    { action = 'Telescope oldfiles', name = '[R]ecent File  ' },
    { action = 'Telescope find_files', name = 'Open [F]ile    ' },
    { action = 'enew', name = 'New [B]uffer   ' },
    { action = 'qall!', name = '[Q]uit Neovim  ' },
}

local function center_a_line(str)
    -- The absolute symmetry is in fact less aesthetically pleasing than a
    -- slight leftward skew.
    local width = api.nvim_win_get_width(0) - left_skewed_columns
    local spaces = math.floor((width - vim.fn.strdisplaywidth(str)) / 2)
    local padding = string.rep(' ', spaces)
    return padding .. str
end

local function warmup()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up
end

function H.starter_content()
    warmup()
    local header = H.header_verse[math.random(1, #H.header_verse)]
    local footer = H.foot_verse[math.random(1, #H.foot_verse)]

    local content = {}

    for _ = 1, top_lines_padding do
        table.insert(content, '')
    end

    for _, line in ipairs(header) do
        table.insert(content, center_a_line(line))
    end

    for _ = 1, lines_between_sections do
        table.insert(content, '')
    end

    for _, item in ipairs(H.items) do
        table.insert(content, center_a_line(item_sign .. item.name))
    end

    for _ = 1, lines_between_sections do
        table.insert(content, '')
    end

    for _, line in ipairs(footer) do
        table.insert(content, center_a_line(line))
    end

    return content
end

SETUP_STARTER = function()
    -- copied from mini.starter
    local buf_id = api.nvim_get_current_buf()

    if buf_id == nil or not api.nvim_buf_is_valid(buf_id) then
        buf_id = api.nvim_create_buf(false, true)
    end

    vim.api.nvim_set_current_buf(buf_id)

    -- Copied from mini.starter
    -- Having `noautocmd` is crucial for performance
    vim.cmd 'noautocmd silent! set filetype=starter'

    local options = {
        -- Taken from 'vim-startify'
        'bufhidden=wipe',
        'colorcolumn=',
        'foldcolumn=0',
        'matchpairs=',
        'nobuflisted',
        'nocursorcolumn',
        'nocursorline',
        'nolist',
        'nonumber',
        'noreadonly',
        'norelativenumber',
        'nospell',
        'noswapfile',
        'signcolumn=no',
        'synmaxcol&',
        -- Differ from 'vim-startify'
        'buftype=nofile',
        'nomodeline',
        'foldlevel=999',
        'nowrap',
    }
    vim.cmd(string.format('silent! noautocmd setlocal %s', table.concat(options, ' ')))

    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, H.starter_content())

    vim.fn.matchadd('StarterVerse', '^ \\+\\([^"]\\+\\)$')
    vim.fn.matchadd('StarterQuote', '^ \\+\\(.\\+\\)$')
    vim.fn.matchadd('StarterItem', '^ \\+\\(.\\+\\)$')
    vim.fn.matchadd('StarterKey', '\\[.\\]', 20)

    autocmd('BufWinLeave', {
        group = starter_group,
        buffer = buf_id,
        callback = function()
            vim.fn.clearmatches()
        end,
        desc = 'clear all highlight',
    })

    for _, item in ipairs(H.items) do
        if type(item.action) == 'string' then
            vim.keymap.set('n', get_key(item.name):lower(), '<CMD>' .. item.action .. '<CR>', { buffer = buf_id })
        else
            vim.keymap.set('n', get_key(item.name):lower(), item.action, { buffer = buf_id })
        end
    end
end

-- copied from mini.starter
H.is_something_shown = function()
    -- Don't open Starter buffer if Neovim is opened to show something. That is
    -- when at least one of the following is true:
    -- - There are files in arguments (like `nvim foo.txt` with new file).
    if vim.fn.argc() > 0 then
        return true
    end

    -- - Several buffers are listed (like session with placeholder buffers). That
    --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
    local listed_buffers = vim.tbl_filter(function(buf_id)
        return vim.fn.buflisted(buf_id) == 1
    end, vim.api.nvim_list_bufs())
    if #listed_buffers > 1 then
        return true
    end

    -- - Current buffer is meant to show something else
    if vim.bo.filetype ~= '' then
        return true
    end

    -- - Current buffer has any lines (something opened explicitly).
    -- NOTE: Usage of `line2byte(line('$') + 1) < 0` seemed to be fine, but it
    -- doesn't work if some automated changed was made to buffer while leaving it
    -- empty (returns 2 instead of -1). This was also the reason of not being
    -- able to test with child Neovim process from 'tests/helpers'.
    local n_lines = vim.api.nvim_buf_line_count(0)
    if n_lines > 1 then
        return true
    end
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
    if string.len(first_line) > 0 then
        return true
    end

    return false
end

autocmd('VimEnter', {
    group = starter_group,
    desc = 'open starter buffer on startup',
    callback = function()
        if H.is_something_shown() then
            return
        end
        vim.cmd 'noautocmd lua SETUP_STARTER()'
    end,
})

return H
