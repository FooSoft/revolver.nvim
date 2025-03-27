if vim.g.revolver_loaded then
    return
else
    vim.g.revolver_loaded = true
end

local function revolve()
    require('revolver').revolve(false)
end

local function revolve_back()
    require('revolver').revolve(true)
end

vim.api.nvim_create_user_command('Revolve', revolve, {})
vim.api.nvim_create_user_command('RevolveBack', revolve_back, {})
