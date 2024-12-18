local M = {}
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function close_buffer_with_prompt()
    local current_buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(current_buf)

    if vim.bo[current_buf].modified then
        if bufname == "" then
            -- Unnamed buffer with changes
            local choice = vim.fn.confirm("Save?",
                "&Save As\n&Discard\n&Cancel", 1)
            if choice == 1 then -- Save As
                vim.ui.input({ prompt = "Enter file name: " }, function(input)
                    if input then
                        vim.cmd('write ' .. input)
                        vim.cmd('BufferClose')
                    end
                end)
            elseif choice == 2 then -- Discard
                vim.cmd('BufferClose!')
            end
            -- If choice is 3 (Cancel), do nothing
        else
            -- Named buffer with changes
            local choice = vim.fn.confirm("Save changes to " .. vim.fn.fnamemodify(bufname, ":t") .. "?",
                "&Yes\n&No\n&Cancel", 1)
            if choice == 1 then -- Yes
                vim.cmd('write')
                vim.cmd('BufferClose')
            elseif choice == 2 then -- No
                vim.cmd('BufferClose!')
            end
            -- If choice is 3 (Cancel), do nothing
        end
    else
        -- No changes, just close the buffer
        vim.cmd('bdelete')
    end
end

function M.setup()
    -- Tab management (barbar)
    map('n', '<leader>p', '<Cmd>BufferPin<CR>', opts)
    map('n', '<tab>', '<Cmd>BufferNext<CR>', opts)
    map('n', '<S-tab>', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<leader>x', close_buffer_with_prompt, opts)
    map('n', '<S-x>', '<Cmd>BufferRestore<CR>', opts)
    map('n', '<leader>kw', '<Cmd>BufferCloseAllButPinned<CR>', opts)

    -- Telescope keybindings
    map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>', opts)
    map('n', '<leader>fw', '<Cmd>Telescope live_grep<CR>', opts)
    map("n", "<leader>fb", "<Cmd>Telescope buffers<CR>", opts)

    -- NvimTree keybinding
    map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>', opts)


    -- comment remaps
    map('n', '<leader>/', 'gcc', { desc = "toggle comment", remap = true })
    map('v', '<leader>/', 'gc', { desc = "toggle comment", remap = true })

    -- which key
    map('n', '<leader>km', function()
        vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
    end, opts)
end

return M
