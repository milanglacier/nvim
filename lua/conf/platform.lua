local keymap = vim.api.nvim_set_keymap

if vim.g.neovide then
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0

    vim.g.neovide_input_macos_option_key_is_meta = 'both'

    local neovide_is_fullscreen = false

    -- you need to allow neovide for `Accesssibility` in `System Preferences` -> `Private`
    -- to make the following command work
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

    local function launched_from_terminal()
        -- NOTE: I don't know why TERM=su if neovim is launched by clicking the
        -- icons directly
        return vim.env.TERM and vim.env.TERM ~= 'su'
    end

    -- HACK: As neovide started as a login shell, it's unable to inherit the
    -- environment variable like PATH from zshrc. Therefore, we need to obtain
    -- the PATH from the interactive shell instead.
    if vim.o.shell:find 'zsh' and vim.fn.has 'mac' == 1 and not launched_from_terminal() then
        vim.fn.jobstart([[[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" > /dev/null && echo "$PATH"]], {
            on_stdout = function(_, data, _)
                vim.notify 'source zshrc'
                vim.env.PATH = data[1]
            end,
            stdout_buffered = true,
        })
    end
end
