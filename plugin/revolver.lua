if not vim.g.revolver then
    local revolver = require('revolver')

    local function reload()
        package.loaded.revolver = nil
        revolver = require('revolver')
    end

    local function revolve()
        revolver.revolve(false)
    end

    local function revolve_back()
        revolver.revolve(true)
    end

    vim.api.nvim_create_user_command('Revolve', revolve, {})
    vim.api.nvim_create_user_command('RevolveBack', revolve_back, {})
    vim.api.nvim_create_user_command('RevolverReload', reload, {})

    vim.g.revolver = true
end
