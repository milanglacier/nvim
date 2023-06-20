local keymap = vim.api.nvim_set_keymap

if vim.g.neovide then
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0

    vim.g.neovide_input_macos_alt_is_meta = 1

    local neovide_is_fullscreen = false

    local toggle_fullscreen_command_list = {
        [[osascript -e 'tell application "System Events" to tell process "Neovide"']],
        [[-e 'set value of attribute "AXFullScreen" of window 1 to %s']],
        [[-e 'end tell']],
    }

    local toggle_fullscreen_command = table.concat(toggle_fullscreen_command_list, ' ')

    local function neovide_toggle_fullscreen()
        vim.fn.system(string.format(toggle_fullscreen_command, tostring(not neovide_is_fullscreen)))
        neovide_is_fullscreen = not neovide_is_fullscreen
    end

    -- HACK: neovide doesn't respect some common native keymap in macos, we want to emulate them.
    keymap('', '<D-v>', '<CMD>normal! P<CR>', { desc = 'macos paste' })
    keymap('i', '<D-v>', '<CMD>normal! P<CR>', { desc = 'macos paste' })
    keymap('c', '<D-v>', '<C-R>"', { desc = 'macos paste' })
    keymap('!', '<C-D-f>', '', { callback = neovide_toggle_fullscreen, desc = 'macos toggle fullscreen' })
    keymap('', '<C-D-f>', '', { callback = neovide_toggle_fullscreen, desc = 'macos toggle fullscreen' })

    -- HACK: As neovide started as a login shell, it's unable to inherit
    -- the $PATH from zshrc. Therefore, we need to obtain the PATH from the
    -- interactive shell instead.
    if vim.o.shell:find 'zsh' then
        vim.fn.jobstart([[[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" && echo "$PATH"]], {
            on_stdout = function(_, data, _)
                vim.env.PATH = data[1]
            end,
            stdout_buffered = true,
        })
    end
end
