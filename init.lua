if vim.fn.has 'gui_running' == 0 then
    require('impatient').enable_profile()
end

require 'basic_settings'
require 'load_plugins'
require 'load_configs'
