local RevolverSuffixes = {
    '.c',
    '.cpp',
    '.h',
    '.hpp',
    '.inl',
}

local function setup(config)
    if config then
        RevolverSuffixes = config
    end
end

local function escape(s)
    return s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
end

local function file_exists(path)
    return vim.loop.fs_stat(path) ~= nil
end

local function path_pivot(path, suffix)
    local start, stop = path:find(escape(suffix) .. '$')
    if start and stop == #path then
        return path:sub(0, start - 1)
    end
end

local function revolve(back)
    local path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local suffix_index = nil
    local prefix = nil
    for i, s in ipairs(RevolverSuffixes) do
        prefix = path_pivot(path, s)
        if prefix then
            suffix_index = i
            break
        end
    end

    if prefix then
        local start = 1
        local stop = #RevolverSuffixes - 1
        local step = 1
        if back then
            start, stop = stop, start
            step = -1
        end

        for i = start, stop, step do
            local j = (i + suffix_index - 1) % #RevolverSuffixes + 1
            local next_path = prefix .. RevolverSuffixes[j]
            if path ~= next_path and file_exists(next_path) then
                vim.cmd(string.format('e %s', next_path))
                break
            end
        end
    end
end

return {
    revolve = revolve,
    setup = setup,
}
