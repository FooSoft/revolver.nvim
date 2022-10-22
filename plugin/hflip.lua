if not vim.g.hflip then
    local hflip = require('hflip')
    vim.api.nvim_create_user_command('HFlip', hflip.hflip, {})
    vim.g.hflip = true
end
