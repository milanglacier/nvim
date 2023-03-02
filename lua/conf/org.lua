vim.cmd.packadd { 'orgmode', bang = true }

local M = {}

require('orgmode').setup_ts_grammar()

local org_dir = '~/Desktop/orgmode'

local bubble_tea_template = function(opts)
    local template = '** %U %?'
    if opts.level then
        local additional_heading_levels = string.rep('*', opts.level - 2)
        template = additional_heading_levels .. template
    end
    return {
        target = org_dir .. '/capture/bubble_tea_live.org',
        template = opts.template or template,
        description = opts.description,
        headline = opts.headline,
    }
end

require('orgmode').setup {
    org_agenda_files = {
        org_dir .. '/*.org',
        org_dir .. '/capture/*.org',
        org_dir .. '/misc/*.org',
        org_dir .. '/roam/*.org',
    },
    org_default_notes_file = org_dir .. '/capture/todo.org',
    org_highlight_latex_and_related = 'entities',
    org_todo_keywords = { 'TODO(t)', 'STRT', 'WAIT', 'HOLD', '|', 'DONE', 'KILL' },
    win_split_mode = 'tabnew',
    org_hide_leading_stars = true,
    org_hide_emphasis_markers = true,
    org_indent_mode = 'noindent',
    org_tags_column = 0,

    org_capture_templates = {
        t = { description = 'personal todo', template = '* TODO %? :\nSCHEDULED: %t' },
        n = {
            description = 'personal notes',
            template = '* %u %?\n%x\n%a',
            target = org_dir .. '/capture/notes.org',
        },
        j = {
            description = 'applied jobs',
            template = '- [ ] %? %u',
            headline = 'Applied jobs',
        },

        e = 'english',
        em = {
            description = 'manually fill',
            target = org_dir .. '/capture/english.org',
            template = '* %^{PROMPT}\n%x\n%a\n:explanation:\n%?\n:END:',
            -- the sentence is the content in register "+" (i.e %x)
        },
        er = {
            description = 'quick fill with selected region and sentence under point',
            target = org_dir .. '/capture/english.org',
            template = '* %(return vim.fn.getreg "r")\n%(return vim.fn.getreg "s")\n%a\n:explanation:\n%?\n:END:',
            -- make sure call GetVisualRegionAndSentenceUnderPoint before fill with this template
        },
        ew = {
            description = 'quick fill with word and sentence under point',
            target = org_dir .. '/capture/english.org',
            template = '* %(return vim.fn.getreg "w")\n%(return vim.fn.getreg "s")\n%a\n:explanation:\n%?\n:END:',
            -- make sure call GetWordAndSentenceUnderPoint before fill with this template
        },

        b = 'bubble tea',
        bf = bubble_tea_template {
            description = 'feed food',
            headline = 'feed food',
        },
        bw = bubble_tea_template {
            description = 'feed water',
            headline = 'feed water',
        },
        bp = bubble_tea_template {
            description = 'poop',
            headline = 'poop',
        },
        bP = bubble_tea_template {
            description = 'play',
            headline = 'play',
        },
        be = bubble_tea_template {
            description = 'eye mucus',
            headline = 'eye mucus',
            level = 3,
        },
        bE = bubble_tea_template {
            description = 'ear clean',
            headline = 'ear clean',
            level = 3,
        },
        bb = bubble_tea_template {
            description = 'bath',
            headline = 'bath',
            level = 3,
        },
        bt = bubble_tea_template {
            description = 'trim coat',
            headline = 'trim coat',
            level = 3,
        },
        bg = bubble_tea_template {
            description = 'grooming',
            headline = 'grooming',
            level = 3,
        },
        bn = bubble_tea_template {
            description = 'nailing',
            headline = 'nailing',
            level = 3,
        },
        bB = bubble_tea_template {
            description = 'brushing teeth',
            headline = 'brushing teeth',
            level = 3,
        },
        bs = bubble_tea_template {
            description = 'symptom',
            headline = 'symptom',
        },
    },

    mappings = {
        prefix = '<Leader>o',

        global = {
            org_agenda = '<prefix>a',
            org_capture = '<prefix>c',
        },

        capture = {
            org_capture_finalize = '<C-c><C-c>',
            org_capture_refile = '<C-c><C-r>',
            org_capture_kill = '<C-c><C-k>',
            org_capture_show_help = 'g?',
        },

        org = {
            org_todo = '<LocalLeader>t',
            org_toggle_checkbox = '<LocalLeader>x',
            org_cycle = '<Localleader><Tab>',
        },

        text_objects = {
            inner_heading = 'ih',
            around_heading = 'ah',
            inner_subtree = 'ir',
            around_subtree = 'ar',
            inner_heading_from_root = 'iH',
            around_heading_from_root = 'aH',
            inner_subtree_from_root = 'iR',
            around_subtree_from_root = 'aR',
        },
    },
}

local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

autocmd('FileType', {
    pattern = 'org',
    desc = 'set cursorline for org filetype',
    group = my_augroup,
    command = 'setlocal cursorline',
})

-- yank word under point into register "w".
-- yank sentence under point into register "s".
--
-- NOTE: macros store its key sequences into
-- registers [a-z],
-- so this function may overwrites those macros.
function M.get_word_and_sentence_under_point()
    vim.cmd [[normal! "wyiw]]
    vim.cmd [[normal! "syis]]
end

-- yank sentence under point into register "s".
-- and yank visually selected region into register "r".
--
-- NOTE: macros store its key sequences into
-- registers [a-z],
-- so this function may overwrites those macros.
function M.get_visual_region_and_sentenec_under_point()
    vim.cmd [[normal! "syis]]
    vim.cmd [[normal! gv"ry]]
end

command('GetWordAndSentenceUnderPoint', M.get_word_and_sentence_under_point, {})
command('GetVisualRegionAndSentenceUnderPoint', M.get_visual_region_and_sentenec_under_point, {})

-- Format the paragraph under the cursor as an org table
-- then transform it into a markdown table.
function M.format_paragraph_as_md_table_using_org()
    -- yank current paragraph
    vim.cmd 'normal yip'
    local current_buffer = vim.api.nvim_get_current_buf()
    local temp_buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_set_current_buf(temp_buffer)
    vim.bo.ft = 'org'
    -- paste the paragraph then format
    -- gqgq is the org keymap for formatting table
    vim.cmd [[normal pgqgq]]
    -- org use +|+ as column separator
    -- while markdown use -|- as column separator
    vim.cmd '%s/-+-/-|-/ge'
    vim.cmd 'normal yip'
    vim.api.nvim_set_current_buf(current_buffer)
    vim.cmd [[normal vipp]]
    vim.cmd 'nohlsearch'
    vim.api.nvim_buf_delete(temp_buffer, { force = true })
end

command('FormatParagraphAsMdTable', M.format_paragraph_as_md_table_using_org, {})

return M
