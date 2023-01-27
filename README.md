# revolver.nvim

This Neovim plugin makes it easy to rotate between related files in a common directory. This enables "header flipping"
in C/C++ and other languages where semantically related information is split between different files. revolver.nvim
alternates between files that share a common prefix after stripping away one of the predetermined suffixes. This suffix
is typically the file extension, but can include a part of the filename as well. Classic Vim is not supported.

## Configuration

This plugin can be configured by calling the `setup` function. A set of file suffixes is provided to override the
defaults shown below.

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

For the following examples, imagine that you have the files `foo.cpp`, `foo.h`, and `foo.inl` in a directory and are
currently editing `foo.cpp`.

*   `Revolver` \
    Invoking the `Revolver` command will open `foo.h`. Subsequent invocation will cause `foo.h` and `foo.inl` to open
    before wrapping back around to `foo.cpp`. The order that files are opened in corresponds to the ordering of suffixes
    provided to the `setup` function.

*   `RevolverBack` \
    This command is similar to `Revolver` with the difference being that suffix rotation occurs backwards. The first
    file to be opened would be `foo.inl`, followed by `foo.h`, and finally `foo.cpp` again.
