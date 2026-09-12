-- Run from the repository root:
-- ./test.sh
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.hidden = true
vim.opt.swapfile = false
vim.cmd('runtime plugin/revolver.lua')

local revolver = require('revolver')
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
local failures = {}
local count = 0

local function edit(path)
    vim.api.nvim_command('edit ' .. vim.fn.fnameescape(path))
end

local function current_is(path)
    assert(vim.api.nvim_buf_get_name(0) == path,
        'expected ' .. path .. ', got ' .. vim.api.nvim_buf_get_name(0))
end

local function test(name, run)
    count = count + 1
    vim.cmd('enew!')
    local dir = root .. '/' .. count
    vim.fn.mkdir(dir, 'p')
    revolver.setup({ '.c', '.cpp', '.h', '.hpp', '.inl' })
    local function file(name)
        local path = dir .. '/' .. name
        vim.fn.writefile({ 'test' }, path)
        return path
    end
    local ok, err = pcall(run, file, dir)
    if not ok then
        failures[#failures + 1] = name .. ': ' .. tostring(err)
    end
end

test('default configuration works without setup', function(file)
    package.loaded.revolver = nil
    revolver = require('revolver')
    local source, header = file('foo.cpp'), file('foo.h')
    edit(source)
    vim.cmd('Revolve')
    current_is(header)
end)

test('commands rotate both ways and wrap over missing files', function(file)
    local source, header, inline = file('foo.cpp'), file('foo.h'), file('foo.inl')
    edit(source)
    for _, path in ipairs({ header, inline, source }) do
        vim.cmd('Revolve')
        current_is(path)
    end
    for _, path in ipairs({ inline, header, source }) do
        vim.cmd('RevolveBack')
        current_is(path)
    end
end)

for _, stem in ipairs({ 'with spaces', 'percent%', 'hash#', 'pipe|name', 'quote"name',
    'bracket[name]', 'star*name', 'back\\slash', 'line\nbreak' }) do
    test('literal filename: ' .. stem, function(file)
        local source, header = file(stem .. '.cpp'), file(stem .. '.h')
        edit(source)
        revolver.revolve()
        current_is(header)
        revolver.revolve(true)
        current_is(source)
    end)
end

test('directories are skipped', function(file, dir)
    local source, inline = file('foo.cpp'), file('foo.inl')
    vim.fn.mkdir(dir .. '/foo.h')
    edit(source)
    revolver.revolve()
    current_is(inline)
    revolver.revolve(true)
    current_is(source)
end)

test('file symlinks are followed and dangling symlinks are skipped', function(file, dir)
    local source, target = file('foo.cpp'), file('target')
    local uv = vim.uv or vim.loop
    assert(uv.fs_symlink(dir .. '/missing', dir .. '/foo.h'))
    assert(uv.fs_symlink(target, dir .. '/foo.hpp'))
    edit(source)
    revolver.revolve()
    current_is(dir .. '/foo.hpp')
end)

test('unsaved changes are protected when hidden is disabled', function(file)
    local source = file('foo.cpp')
    file('foo.h')
    edit(source)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'unsaved' })
    vim.opt.hidden = false
    local ok, err = pcall(revolver.revolve)
    vim.opt.hidden = true
    assert(not ok and tostring(err):find('E37', 1, true), tostring(err))
    current_is(source)
    assert(vim.bo.modified)
    assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == 'unsaved')
end)

test('longest suffix identifies the related group', function(file)
    revolver.setup({ '.cpp', '_test.cpp', '.h' })
    local source, test_file, header = file('foo.cpp'), file('foo_test.cpp'), file('foo.h')
    file('foo_test.h')
    edit(source)
    revolver.revolve()
    current_is(test_file)
    revolver.revolve()
    current_is(header)
    revolver.revolve(true)
    current_is(test_file)
    revolver.revolve(true)
    current_is(source)
end)

test('suffixes containing Lua pattern characters are literal', function(file)
    revolver.setup({ '.c++', '[test].h' })
    local source, header = file('foo.c++'), file('foo[test].h')
    edit(source)
    revolver.revolve()
    current_is(header)
    revolver.revolve(true)
    current_is(source)
end)

test('no match or no alternative leaves the buffer unchanged', function(file)
    for _, name in ipairs({ 'foo.cpp', 'foo.txt' }) do
        local path = file(name)
        edit(path)
        revolver.revolve()
        revolver.revolve(true)
        current_is(path)
    end
end)

test('empty, single, and duplicate suffix lists', function(file)
    local source = file('foo.cpp')
    file('foo.h')
    edit(source)
    for _, suffixes in ipairs({ {}, { '.cpp' }, { '.cpp', '.cpp' } }) do
        revolver.setup(suffixes)
        revolver.revolve()
        revolver.revolve(true)
        current_is(source)
    end
end)

test('empty suffix supports extensionless files', function(file)
    revolver.setup({ '', '.h' })
    local source, header = file('foo'), file('foo.h')
    edit(source)
    revolver.revolve()
    current_is(header)
    revolver.revolve()
    current_is(source)
end)

test('unnamed buffers do not rotate', function(file, dir)
    file('.h')
    revolver.setup({ '', '.h' })
    local cwd = vim.fn.getcwd()
    vim.cmd('cd ' .. vim.fn.fnameescape(dir))
    local ok, err = pcall(function()
        revolver.revolve()
        current_is('')
    end)
    vim.cmd('cd ' .. vim.fn.fnameescape(cwd))
    assert(ok, err)
end)

vim.cmd('enew!')
vim.fn.delete(root, 'rf')
if #failures > 0 then
    error(table.concat(failures, '\n'))
end
print(('Passed %d tests'):format(count))
