if vim.g.revolver_loaded then
    return
else
    vim.g.revolver_loaded = true
end

vim.api.nvim_create_user_command(
    'Revolve',
    function()
        require('revolver').revolve(false)
    end,
    {}
)

vim.api.nvim_create_user_command(
    'RevolveBack',
    function()
        require('revolver').revolve(true)
    end,
    {}
)
