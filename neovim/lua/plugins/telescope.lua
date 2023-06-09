local function load_extensions()
    local utils = require("utils")
    require("telescope").load_extension("file_browser")
    if utils.is_plugin_loaded("nvim-notify") then
        require("telescope").load_extension("notify")
    end
end

local function config_telescope()
    local actions = require("telescope.actions")
    require("telescope").setup({
        defaults = {
            mappings = {
                i = {
                    ["<esc>"] = actions.close,
                    -- Disable scroll-up to allow clearing prompt
                    ["<C-u>"] = false,
                },
            },
            layout_strategy = "flex",
        },
    })
    local utils = require("utils")
    utils.try_require("which-key", function(wk)
        wk.register({
            ["<C-t>"] = { "<cmd>lua require('telescope.builtin').find_files()<CR>", "Find files" },
        })
        wk.register({
            b = { "<cmd>lua require('telescope.builtin').buffers()<CR>", "Find buffers" },
            t = { "<cmd>lua require('telescope.builtin').current_buffer_tags()<CR>", "Find buffer tags" },
            ["*"] = { "<cmd>lua require('telescope.builtin').grep_string()<CR>", "Find buffers" },
            f = {
                b = { "<cmd>lua require('telescope.builtin').buffers()<CR>", "Find buffers" },
                f = { "<cmd>lua require('telescope.builtin').find_files()<CR>", "Find file" },
                g = { "<cmd>lua require('telescope.builtin').live_grep()<CR>", "Live grep" },
                h = { "<cmd>lua require('telescope.builtin').help_tags()<CR>", "Find help tags" },
                l = { "<cmd>lua require('telescope.builtin').resume()<CR>", "Resume finding" },
                t = { "<cmd>lua require('telescope.builtin').current_buffer_tags()<CR>", "Find buffer tags" },
                T = { "<cmd>lua require('telescope.builtin').tags()<CR>", "Find tags" },
            },
        }, {
            prefix = "<leader>",
        })
    end, function()
        local opts = { silent = true, noremap = true }
        vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>lua require('telescope.builtin').find_files()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>fl", "<cmd>lua require('telescope.builtin').resume()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>", opts)
        vim.api.nvim_set_keymap(
            "n",
            "<leader>t",
            "<cmd>lua require('telescope.builtin').current_buffer_tags()<CR>",
            opts
        )
        vim.api.nvim_set_keymap("n", "<leader>ft", "<cmd>lua require('telescope.builtin').tags()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", opts)
        vim.api.nvim_set_keymap("n", "<leader>*", "<cmd>lua require('telescope.builtin').grep_string()<CR>", opts)

        -- Better spelling replacement for word under cursor
        vim.api.nvim_set_keymap(
            "n",
            "<leader>s",
            "<cmd>lua require('telescope.builtin').spell_suggest(require('telescope.themes').get_cursor())<CR>",
            opts
        )
    end)

    load_extensions()
end

config_telescope()
