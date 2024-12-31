local M = {}
local term = require('term')

-- Terminal configurations
M.terms = {
    horizontal = {
        id = "term_horizontal",
        pos = "sp",
        size = 0.3,
    },
    float = {
        id = "term_float",
        pos = "float",
        float_opts = {
            width = 0.7,
            height = 0.8,
            row = 0.1,
            col = 0.15,
        }
    },
    lazygit = {
        id = "lazygit",
        pos = "float",
        cmd = "lazygit",
        float_opts = {
            width = 0.9,
            height = 0.9,
            row = 0.05,
            col = 0.05,
        }
    },
    bottom = {
        id = "term_bottom",
        pos = "bo sp",
        size = 0.3,
    },
}
-- Keymap helper function
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end
function M.setup()
    -- Tab management (barbar)
    map('n', '<leader>p', '<Cmd>BufferPin<CR>')
    map('n', '<tab>', '<Cmd>BufferNext<CR>')
    map('n', '<S-tab>', '<Cmd>BufferPrevious<CR>')
    map('n', '<leader>x', '<Cmd>BufferClose<CR>')
    map('n', '<S-x>', '<Cmd>BufferRestore<CR>')
    map('n', '<leader>kw', '<Cmd>BufferCloseAllButPinned<CR>')

    -- Navigation
    map('n', '<C-h>', '<C-w>h')
    map('n', '<C-j>', '<C-w>j')
    map('n', '<C-k>', "<C-w>k")
    map('n', '<C-l>', "<C-w>l")

    -- save
    map('n', "<C-s>", "<cmd> w <CR>")

    -- LSP keybindings
    map('n', '<leader>fm', function()
        vim.lsp.buf.format {
            async = true
        }
    end)
    map('n', '<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
    map('n', '<leader>gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>')
    map('n', '<leader>gr', '<Cmd>lua vim.lsp.buf.references()<CR>')
    map('n', '<leader>gh', '<Cmd>lua vim.lsp.buf.hover()<CR>')
    map('n', '<leader>rr', '<Cmd>lua vim.lsp.buf.rename()<CR>')
    map('n', '<leader>.', '<Cmd>lua vim.lsp.buf.code_action()<CR>')

    -- Telescope keybindings
    map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>')
    map('n', '<leader>fw', '<Cmd>Telescope live_grep<CR>')
    map("n", "<leader>fb", "<Cmd>Telescope buffers<CR>")


    -- NvimTree keybinding
    map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')

    -- comment
    map('n', '<leader>/', 'gcc', {
        desc = "toggle comment",
        remap = true
    })
    map('v', '<leader>/', 'gc', {
        desc = "toggle comment",
        remap = true
    })

    -- which key
    map('n', '<leader>km', function()
        vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
    end)

    -- term
    map("t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
    map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower window" })
    map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper window" })
    map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })

    -- Toggle bottom terminal
    map("n", "<C-`>", function()
        term.toggle(M.terms.bottom)
    end)
    map("t", "<C-`>", function()
        term.toggle(M.terms.bottom)
    end)

    -- Lazygit
    map("n", "<C-g>", function()
        term.toggle(M.terms.lazygit)
    end)
    map("t", "<C-g>", function()
        term.toggle(M.terms.lazygit)
    end)
end

return M
