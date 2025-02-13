-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set <leader> to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.clipboard:append('unnamedplus')

require('plugins')
require('term')
require('keymaps').setup()
vim.cmd('colorscheme cyberdream')
