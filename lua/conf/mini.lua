vim.cmd [[packadd! mini.nvim]]

require('mini.cursorword').setup {}
require('mini.misc').setup {}

local M = {}

local header_verse = {

    [[
Bright star, would I were steadfast as thee art!
- John Keats]],
    [[
For clattering parrots to launch their fleet at sunrise
For April to ignite the African violet
- Derek Walcott]],
    [[
In these poinsettia meadows of her tides,—
Adagios of islands, O my Prodigal,
Complete the dark confessions her veins spell.
- Hart Crane]],
    [[
帝子降兮北渚，目眇眇兮愁予，
袅袅兮秋风，洞庭波兮木叶下。
- 《湘夫人》]],
    [[
美人迈兮音尘阙，隔千里兮共明月。
临风叹兮将焉歇，川路长兮不可越！
- 《月赋》]],
    [[
浴兰汤兮沐芳，华采衣兮若英。
灵连蜷兮既留，烂昭昭兮未央。
蹇将憺兮寿宫，与日月兮齐光。
- 《云中君》]],
    length = 6,
}

local foot_verse = {
    [[
Whispers antiphonal in the azure swing...
- Hart Crane]],
    [[
In the drumming world that dampens your tired eyes
Behind two clouding lenses, sunrise, sunset,
The quiet ravage of diabetes.
- Derek Walcott]],
    [[
What words   
Can strangle this deaf moonlight? For we
Are overtaken.
- Hart Crane]],
    [[
搴汀洲兮杜若，将以遗兮远者。
时不可兮骤得，聊逍遥兮容与！
- 《湘夫人》]],
    [[
月既没兮露欲晞，岁方晏兮无与归。
佳期可以还，微霜沾人衣。
- 《月赋》]],
    [[
雷填填兮雨冥冥，猨啾啾兮狖夜鸣。
风飒飒兮木萧萧，思公子兮徒离忧。
- 《山鬼》]],
    length = 6,
}

if vim.fn.has 'nvim-0.7' == 1 then
    local starter = require 'mini.starter'

    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    starter.setup {
        header = header_verse[math.random(1, header_verse.length)],
        items = {
            {
                {
                    action = [[lua require("conf.colorscheme").pick_randomly()]],
                    name = 'pick new theme!',
                    section = 'Appearance',
                },
                {
                    action = [[lua require("conf.mini").change_verses()]],
                    name = 'show new verses!',
                    section = 'Appearance',
                },
                { action = 'Telescope projects', name = 'recent projects', section = 'Telescope' },
                { action = 'Telescope oldfiles', name = 'old files', section = 'Telescope' },
                { action = 'Telescope find_files', name = 'find files', section = 'Telescope' },
                { action = 'Telescope command_history', name = 'command history', section = 'Telescope' },
                { action = 'Telescope jumplist', name = 'jumplist', section = 'Telescope' },
                { name = 'edit new buffer', action = 'enew', section = 'Builtin actions' },
                { name = 'quit Neovim', action = 'qall!', section = 'Builtin actions' },
            },
        },
        content_hooks = {
            starter.gen_hook.adding_bullet(),
            starter.gen_hook.aligning('center', 'center'),
        },
        starter.gen_hook.padding(5, 2),
        footer = foot_verse[math.random(1, foot_verse.length)],
        query_updaters = [[abcdefhijklmnopqrsuvwxyz]],
    }
end

M.change_verses = function()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    _G.MiniStarter.config.header = header_verse[math.random(1, header_verse.length)]
    _G.MiniStarter.config.footer = foot_verse[math.random(1, foot_verse.length)]

    _G.MiniStarter.refresh()
end

require('mini.indentscope').setup {
    mappings = {
        object_scope = '',
        object_scope_with_border = '',
    },
}

vim.cmd [[
    hi MiniCursorword None
    hi MiniCursorwordCurrent None
    hi! link MiniCursorword CursorLine
    hi! link MiniCursorwordCurrent CursorLine
]]

local keymap = vim.api.nvim_set_keymap

keymap('n', '<Leader>bd', "<cmd>lua require('mini.bufremove').delete()<CR>", { noremap = true, silent = true })
keymap('n', '<Leader>bw', "<cmd>lua require('mini.bufremove').wipeout()<CR>", { noremap = true, silent = true })

return M
