if not vim.g.hflip then
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

    reload()

    vim.api.nvim_create_user_command('Revolver', revolve, {})
    vim.api.nvim_create_user_command('RevolverBack', revolve_back, {})
    vim.api.nvim_create_user_command('RevolverReload', reload, {})

    vim.g.revolver = true
end
