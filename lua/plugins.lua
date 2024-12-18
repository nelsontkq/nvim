-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      filters = { dotfiles = false },
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        width = 30,
        preserve_window_proportions = true,
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
      },
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup { default = true }
    end
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup {
        options = { theme = 'auto' }
      }
    end
  },
  -- Bufferline
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      sidebar_filetypes = {
        NvimTree = true,
      },
      auto_hide = false,
      insert_at_start = true,
      animation = true,
      hide = { extensions = true, inactive = false },
      icons = {

        separator = { left = '', right = '' },
        filetype = {
          enabled = true,
        },
      },
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  -- LSP configuration
  {
    "williamboman/mason.nvim",
    config = true
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({

        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {
                'vim',
                'require'
              },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Additional LSP configs if needed
    end
  },
  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", '.local', '.meteor', '*.js.map' },
          layout_config = {
            prompt_position = "top",
          },
        },
      }
    end
  },
  -- which key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
    },
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
  }
})
