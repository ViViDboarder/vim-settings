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
    local telescope_builtin = require("telescope.builtin")

    utils.keymap_set("n", "<C-t>", telescope_builtin.find_files, { desc = "Find files" })
    utils.keymap_set("n", "<leader>b", telescope_builtin.buffers, { desc = "Find buffers" })
    utils.keymap_set("n", "<leader>t", telescope_builtin.current_buffer_tags, { desc = "Find buffer tags" })
    utils.keymap_set("n", "<leader>*", telescope_builtin.grep_string, { desc = "Find string under cursor" })
    utils.keymap_set("n", "<leader>s", function()
        require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor())
    end, { desc = "Spell check" })

    local finder_keymap = utils.curry_keymap("n", "<leader>f", { group_desc = "Finder" })
    finder_keymap("b", telescope_builtin.buffers, { desc = "Find buffers" })
    finder_keymap("f", telescope_builtin.find_files, { desc = "Find file" })
    finder_keymap("g", telescope_builtin.live_grep, { desc = "Live grep" })
    finder_keymap("h", telescope_builtin.help_tags, { desc = "Find help tags" })
    finder_keymap("l", telescope_builtin.resume, { desc = "Resume finding" })
    finder_keymap("t", telescope_builtin.current_buffer_tags, { desc = "Find buffer tags" })
    finder_keymap("T", telescope_builtin.tags, { desc = "Find tags" })

    if utils.can_require("sg.telescope") then
        finder_keymap("G", require("sg.telescope").fuzzy_search_results, { desc = "Search Sourcegraph" })
    end

    load_extensions()
end

config_telescope()
