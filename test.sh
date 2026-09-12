#!/bin/sh
set -eu

cd -- "$(dirname -- "$0")"
exec nvim -n --headless -u NONE -i NONE -l tests/revolver.lua
