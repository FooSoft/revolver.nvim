local function split_ext(path)
    return path:match('^(.+)(%..+)$')
end

local function file_exists(path)
    return vim.loop.fs_stat(path) ~= nil
end

local function locate_flip_path(name, exts)
    for key, _ in pairs(exts) do
        local path = name .. key
        if file_exists(path) then
            return path
        end

        local path_upper = name .. key:upper()
        if file_exists(path_upper) then
            return path_upper
        end
    end
end

local function hflip()
    local header_exts = {
        ['.h'] = true,
        ['.hpp'] = true,
        ['.lua'] = true,
    }

    local source_exts = {
        ['.c'] = true,
        ['.cpp'] = true
    }

    local index = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(index)
    local name, ext = split_ext(path)

    ext = ext:lower()

    local flip_path
    if header_exts[ext] then
        flip_path = locate_flip_path(name, source_exts)
    elseif source_exts[ext] then
        flip_path = locate_flip_path(name, header_exts)
    end

    if flip_path then
        vim.cmd(string.format('e %s', flip_path))
    end
end

return {
    hflip = hflip
}
