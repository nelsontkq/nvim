-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = { "lua", "vim", "vimdoc" },
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            }
        })
    end
}, { -- File explorer
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(opts)
        require('config.tree').setup({
            filters = {
                dotfiles = false,
                custom = {
                    "node_modules", "target", ".git", ".local", ".meteor"
                }
            }
        })
    end
}, {
    "nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup({
            default = true
        })
    end
}, { -- Statusline
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("lualine").setup {
            options = {
                theme = 'auto',
                globalstatus = true
            }
        }
    end
}, { -- Bufferline
    'romgrk/barbar.nvim',
    dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons' },
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    opts = {
        sidebar_filetypes = {
            NvimTree = true
        },
        auto_hide = false,
        insert_at_start = true,
        animation = true,
        hide = {
            extensions = true,
            inactive = false
        },
        icons = {

            separator = {
                left = '',
                right = ''
            },
            filetype = {
                enabled = true
            }
        }
    },
    version = '^1.0.0'
}, { -- LSP configuration
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    config = function()
        require("mason").setup({
            max_concurrent_installers = 12
        })
    end
}, {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require('mason-lspconfig').setup()
        require('mason-lspconfig').setup_handlers {
            ['lua_ls'] = function()
                require('lspconfig').lua_ls.setup {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' }
                            }
                        }
                    }
                }
            end,
            function(server_name)
                if server_name == "tsserver" then
                    server_name = "ts_ls"
                end
                require("lspconfig")[server_name].setup {}
            end
        }
    end
}, { -- Fuzzy Finder
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
        require('telescope').setup {
            defaults = {
                file_ignore_patterns = { "node_modules", ".git", '.local', '.meteor', '*.js.map' },
                layout_config = {
                    prompt_position = "top"
                }
            }
        }
    end
}, { -- which key
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" }
}, {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("cyberdream").setup({
            transparent = true
        })
    end
}, { -- session
    'rmagatti/auto-session',
    lazy = false,
    config = function()
        require('auto-session').setup {
            auto_restore_enabled = true,
            auto_save_enabled = true,
            auto_session_enable_last_session = true,
            auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
            auto_session_enabled = true,
            auto_save_interval = 30000,
            pre_save_cmds = {
                'NvimTreeClose',
                'tabdo BarbarDisable',
                function()
                    -- toggle term if it is open
                    if vim.fn.bufwinnr('term://') ~= -1 then
                        vim.cmd('TermClose')
                    end
                end
            }
        }
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end
} })
