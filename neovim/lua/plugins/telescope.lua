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
    utils.keymap_set("n", "<C-t>", "<cmd>lua require('telescope.builtin').find_files()<CR>", { desc = "Find files" })
    utils.keymap_set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<CR>", { desc = "Find buffers" })
    utils.keymap_set(
        "n",
        "<leader>t",
        "<cmd>lua require('telescope.builtin').current_buffer_tags()<CR>",
        { desc = "Find buffer tags" }
    )
    utils.keymap_set(
        "n",
        "<leader>*",
        "<cmd>lua require('telescope.builtin').grep_string()<CR>",
        { desc = "Find string under cursor" }
    )
    -- Better spelling replacement for word under cursor
    utils.keymap_set(
        "n",
        "<leader>s",
        "<cmd>lua require('telescope.builtin').spell_suggest(require('telescope.themes').get_cursor())<CR>",
        { desc = "Spell check" }
    )

    local finder_keymap = utils.curry_keymap("n", "<leader>f")
    finder_keymap("b", "<cmd>lua require('telescope.builtin').buffers()<CR>", { desc = "Find buffers" })
    finder_keymap("f", "<cmd>lua require('telescope.builtin').find_files()<CR>", { desc = "Find file" })
    finder_keymap("g", "<cmd>lua require('telescope.builtin').live_grep()<CR>", { desc = "Live grep" })
    finder_keymap("h", "<cmd>lua require('telescope.builtin').help_tags()<CR>", { desc = "Find help tags" })
    finder_keymap("l", "<cmd>lua require('telescope.builtin').resume()<CR>", { desc = "Resume finding" })
    finder_keymap("t", "<cmd>lua require('telescope.builtin').current_buffer_tags()<CR>", { desc = "Find buffer tags" })
    finder_keymap("T", "<cmd>lua require('telescope.builtin').tags()<CR>", { desc = "Find tags" })

    if utils.can_require("sg.telescope") then
        finder_keymap(
            "G",
            "<cmd>lua require('sg.telescope').fuzzy_search_results()<CR>",
            { desc = "Search Sourcegraph" }
        )
    end

    load_extensions()
end

config_telescope()
