local conda = '/opt/homebrew/Caskroom/miniforge/base'

local conda_env = function(env, bin)
    return conda .. '/envs/' .. env .. '/bin/' .. bin
end

local proselint = conda_env('proselint', 'proselint')
local ipython = conda .. '/bin/ipython'
local python = conda .. '/bin/python'
local yapf = conda .. '/bin/yapf'
local flake8 = conda .. '/bin/flake8'
local pylint = conda .. '/bin/pylint'

local local_bin = os.getenv 'HOME' .. '/.local'
local radian = local_bin .. '/bin/radian'

local node = os.getenv 'HOME' .. '/.local/share/node/'
local node_env = function(path, bin)
    return node .. path .. '/node_modules/.bin/' .. bin
end

local vim_language_server = node_env('vimls', 'vim-language-server')
local prettierd = node_env('prettierd', 'prettierd')

local cargo = os.getenv 'HOME' .. '/.cargo'

local sqls = os.getenv 'HOME' .. '/go/bin/sqls'

local M = {
    conda = conda,
    python = python,
    radian = radian,
    ipython = ipython,
    yapf = yapf,
    flake8 = flake8,
    pylint = pylint,
    cargo = cargo,
    sqls = sqls,
    node = node,
    ['vim-language-server'] = vim_language_server,
    prettierd = prettierd,
    proselint = proselint,
}

return setmetatable(M, {
    __index = function(_, key)
        local which = vim.fn.system('which ' .. key)
        local path = string.sub(which, 1, -2) -- the last character is \n, remove it
        return path
    end,
})
