local conda = '/opt/homebrew/Caskroom/miniforge/base'
local radian = conda .. '/bin/radian'
local ipython = conda .. '/bin/ipython'
local pylsp = conda .. '/bin/pylsp'
local python = conda .. '/bin/python'

local cargo = os.getenv 'HOME' .. '/.cargo'
local stylua = cargo .. '/bin/stylua'
local selene = cargo .. '/bin/selene'

local proselint = conda .. '/bin/proselint'
local codespell = conda .. '/bin/codespell'

return {
    conda = conda,
    python = python,
    radian = radian,
    ipython = ipython,
    pylsp = pylsp,
    cargo = cargo,
    stylua = stylua,
    selene = selene,
    proselint = proselint,
    codespell = codespell,
}
