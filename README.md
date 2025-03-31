# Revolver

Revolver is a Neovim extension for jumping between related files in a common directory. The primary use case is "header flipping" in C/C++, but this plugin can be useful whenever semantically related information is split between different files. Revolver rotates between files that share a common prefix after stripping one of the predetermined suffixes. This suffix is typically the file extension, but can include a part of the filename as well.

## Configuration

The plugin is configured via the `setup` function. Options may be provided to change the default settings shown below.

```lua
require('revolver').setup({
    '.c',
    '.cpp',
    '.h',
    '.hpp',
    '.inl'
})
```

## Commands

Commands have no keyboard bindings by default. Specify your own mappings as needed.

For the following examples, imagine that you have the files `foo.cpp`, `foo.h`, and `foo.inl` in a directory and are currently editing `foo.cpp`.

#### `Revolve`

Invoking the `Revolve` command will open `foo.h`. Subsequent invocation will cause `foo.h` and `foo.inl` to open before wrapping back around to `foo.cpp`. The order that files are opened in corresponds to the ordering of suffixes provided to the `setup` function.

#### `RevolveBack`

This command is similar to `Revolve` with the difference being that suffix rotation occurs backwards. The first file to be opened would be `foo.inl`, followed by `foo.h`, and finally `foo.cpp` again.
