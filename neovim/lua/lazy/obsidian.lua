-- #selene: allow(mixed_table)

-- Obsidian notes
-- This loads an Obsidian plugin for better vault interraction as well as auto pulls
-- and commits to my vault git repo. On iOS devices, I use Working Copy to sync the
-- repo and use Shortcuts to automate pulling on open and auto committing and pushing
-- after closing Obsidian.
return {
    "https://github.com/epwalsh/obsidian.nvim",
    dependencies = {
        { "https://github.com/nvim-lua/plenary.nvim" },
    },
    version = "^3",
    opts = {
        workspaces = {
            { name = "personal", path = require("plugins.obsidian").vault_path },
        },
        ui = {
            checkboxes = {
                [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                ["x"] = { char = "✔", hl_group = "ObsidianDone" },
            },
            external_link_icon = { char = "🔗", hl_group = "ObsidianExtLinkIcon" },
        },
    },
    config = function(_, opts)
        require("plugins.obsidian").config(opts)
    end,
    event = {
        "BufRead " .. require("plugins.obsidian").vault_path .. "/**",
        "BufNewFile " .. require("plugins.obsidian").vault_path .. "/**",
    },
    cmd = {
        "ObsidianOpen",
        "ObsidianNew",
        "ObsidianSearch",
        "ObsidianNewFromTemplate",
        "ObsidianWorkspace",
    },
}
