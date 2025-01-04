-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

local ok, local_settings = pcall(require, "config.local_settings")
if not ok then
    local_settings = {}
end

local file_ignore_globs = local_settings.file_ignore_globs or { "**/node_modules", "./.git" }

local default_plugins = { {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = { "lua", "vim", "vimdoc" },
        highlight = {
            enable = true
        },
        indent = {
            enable = true
        }
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end
}, { -- File explorer
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        filters = {
            dotfiles = false,
            custom = { "node_modules", "target", ".git", ".local", ".meteor" }
        },
        update_focused_file = {
            enable = true,
        }
    },
    config = function(_, opts)
        require('config.tree').setup(opts)
    end
}, {
    "nvim-tree/nvim-web-devicons",
    opts = {
        default = true
    }
}, { -- Statusline
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            theme = 'auto',
            globalstatus = true
        }
    }
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
    opts = {
        max_concurrent_installers = 12
    }
}, {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function(_, opts)
        require('mason-lspconfig').setup(opts)
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
            end,
        }
    end
}, { -- Fuzzy Finder
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    opts = {
        defaults = {
            file_ignore_patterns = file_ignore_globs,
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--trim",
                "--sortr=modified"
            },
            layout_config = {
                prompt_position = "top"
            }
        },
        pickers = {
            find_files = {
                find_command = { "fd", "--type", "f", "--strip-cwd-prefix", }
            },

        }
    }
}, { -- which key
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" }
}, {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent = true
    }
} }

if type(local_settings.plugins) == "table" then
    for _, plugin in ipairs(local_settings.plugins) do
        if type(plugin) == 'string' then
            if not vim.tbl_contains(default_plugins, plugin) then
                table.insert(default_plugins, { plugin })
            end
        elseif type(plugin) == 'table' then
            local name = plugin[1]
            for _, p in ipairs(default_plugins) do
                if p[1] == name then
                    p = vim.tbl_deep_extend("force", p, plugin)
                    break
                end
            end
        end
    end
end

require("lazy").setup(default_plugins)
