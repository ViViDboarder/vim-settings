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
        templates = {
            folder = "Templates",
            substitutions = {
                next_monday = function()
                    local current_time = os.time()
                    -- 1 = Sunday, 2 = Monday, ..., 7 = Saturday
                    local current_weekday = os.date("*t", current_time).wday

                    -- Calculate the number of days to add to reach next Monday
                    local days_to_add = (9 - current_weekday) % 7
                    if days_to_add == 0 then
                        days_to_add = 7 -- If today is Monday, get the next Monday
                    end

                    -- Get the timestamp for the next Monday
                    local next_monday_time = current_time + (days_to_add * 24 * 60 * 60)

                    -- Return the formatted date
                    return os.date("%Y-%m-%d", next_monday_time)
                end,
            },
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
