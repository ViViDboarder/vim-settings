local function config_telescope()
    local actions = require("telescope.actions")
    require("telescope").setup{
        defaults = {
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
            },
            mappings = {
                i = {
                    ["<esc>"] = actions.close,
                    -- Disable scroll-up to allow clearing prompt
                    ["<C-u>"] = false,
                }
            },
            layout_strategy = "flex",
        }
    }
    local opts = {silent=true, noremap=true}
    vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>Telescope find_files<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>Telescope buffers<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>Telescope current_buffer_tags<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>ft", "<cmd>Telescope tags<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
end

config_telescope()
