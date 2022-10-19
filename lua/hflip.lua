local function split_ext(path)
    return path:match('^(.+)(%..+)$')
end

local function file_exists(path)
    return vim.loop.fs_stat(path) ~= nil
end

local function hflip()
    local exts = {'.h', '.hpp', '.c', '.cpp', '.inl'}
    for i = 1, #exts do
        table.insert(exts, exts[i]:upper())
    end

    local path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local name, ext = split_ext(path)
    if not ext then
        return
    end

    local ext_index = nil
    for i, e in ipairs(exts) do
        if e == ext:lower() then
            ext_index = i
            break
        end
    end
    if not ext_index then
        return
    end

    for i = 1, #exts - 1 do
        local j = (i + ext_index - 1) % #exts + 1
        local next_path = name .. exts[j]
        if path ~= next_path and file_exists(next_path) then
            vim.cmd(string.format('e %s', next_path))
            break
        end
    end
end

return {
    hflip = hflip
}
