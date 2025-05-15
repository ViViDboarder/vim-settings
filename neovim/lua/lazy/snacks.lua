return {
    "https://github.com/folke/snacks.nvim",
    priority = 100,
    lazy = false,
    ---@type snacks.Config
    opts = {
        picker = {
            matcher = {
                fuzzy = true,
                smartcase = true,
                ignorecase = true,
                sort_empty = false,
                filename_bonus = true,
                file_pos = true,
                -- Slower bonuses
                cwd_bonus = false,
                frecency = true,
                history_bonus = false,
            },
            icons = {
                -- TODO: Use some graceful icon selections via `icons.lua`
                files = {
                    enabled = require("icons").nerd_font,
                },
            },
        },
    },
    keys = {
        {
            "<C-t>",
            function()
                Snacks.picker.files()
            end,
            desc = "Snacks: Files",
        },
        {
            "<leader>b",
            function()
                Snacks.picker.buffers()
            end,
            desc = "Snacks: Buffers",
        },
        {
            "<leader>g",
            function()
                Snacks.picker.grep()
            end,
            desc = "Snacks: Grep",
        },
        {
            "<leader>h",
            function()
                Snacks.picker.help_tags()
            end,
            desc = "Snacks: Help tags",
        },
        {
            "<leader>t",
            function()
                Snacks.picker.tags()
            end,
            desc = "Snacks: Tags",
        },
    },
}
