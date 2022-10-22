vim.cmd.packadd { 'orgmode', bang = true }

require('orgmode').setup_ts_grammar()

local org_dir = '~/Desktop/orgmode'

local bubble_tea_template = function(opts)
    return {
        target = org_dir .. '/capture/bubble_tea_live.org',
        template = opts.template or '* %U %?',
        description = opts.description,
    }
end

require('orgmode').setup {
    org_agenda_files = { org_dir .. '/*' },
    org_default_notes_file = org_dir .. '/capture/todo.org',
    org_highlight_latex_and_related = 'native',
    org_todo_keywords = { 'TODO(t)', 'STRT', 'WAIT', 'HOLD', '|', 'DONE', 'KILL' },
    win_split_mode = 'auto',
    org_hide_leading_stars = true,
    org_hide_emphasis_markers = true,

    org_capture_templates = {
        J = {
            description = 'Journal',
            template = '\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?',
            target = org_dir .. '/capture/notes.org',
        },
        t = { description = 'personal todo', template = '* TODO %? :\nSCHEDULED: %t' },
        n = {
            description = 'personal notes',
            template = '* %u %?\n%x\n%a',
            target = org_dir .. '/capture/notes.org',
        },
        j = {
            description = 'applied jobs',
            template = '- [ ] %? %u',
            headline = 'Misc',
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
            headline = 'clean/eye mucus',
        },
        bE = bubble_tea_template {
            description = 'ear clean',
            headline = 'clean/ear clean',
        },
        bb = bubble_tea_template {
            description = 'bath',
            headline = 'clean/bath',
        },
        bt = bubble_tea_template {
            description = 'trim coat',
            headline = 'clean/trim coat',
        },
        bg = bubble_tea_template {
            description = 'grooming',
            headline = 'clean/grooming',
        },
        bn = bubble_tea_template {
            description = 'nailing',
            headline = 'clean/nailing',
        },
        bB = bubble_tea_template {
            description = 'brushing teeth',
            headline = 'clean/brushing teeth',
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
