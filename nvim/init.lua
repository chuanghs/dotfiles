-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true



require('options')
require('keymaps')
require('plugin-manager')
require("lsp")
