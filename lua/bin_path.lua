local conda = '/opt/homebrew/Caskroom/miniforge/base'
local radian = conda .. '/bin/radian'
local ipython = conda .. '/bin/ipython'
local python = conda .. '/bin/python'
local yapf = conda .. '/bin/yapf'
local flake8 = conda .. '/bin/flake8'
local pylint = conda .. '/bin/pylint'

local cargo = os.getenv 'HOME' .. '/.cargo'

local proselint = conda .. '/bin/proselint'
local codespell = conda .. '/bin/codespell'

local sqls = os.getenv 'HOME' .. '/go/bin/sqls'
local sqlfluff = conda .. '/bin/sqlfluff'

return {
    conda = conda,
    python = python,
    radian = radian,
    ipython = ipython,
    yapf = yapf,
    flake8 = flake8,
    pylint = pylint,
    cargo = cargo,
    proselint = proselint,
    codespell = codespell,
    sqls = sqls,
    sqlfluff = sqlfluff,
}
