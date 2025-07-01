-- #selene: allow(mixed_table)

-- Obsidian notes
-- This loads an Obsidian plugin for better vault interraction as well as auto pulls
-- and commits to my vault git repo. On iOS devices, I use Working Copy to sync the
-- repo and use Shortcuts to automate pulling on open and auto committing and pushing
-- after closing Obsidian.

local vault_path = vim.fn.expand("~/Documents/Obsidian")

--- project_note creates or opens a note for a project based on it's git repo
---
--- Using fugitive for identifying the remote, it will create or open a note
--- for the project in the vault.
local function project_note()
    local remote = vim.fn.FugitiveRemote()
    if remote == nil or remote["path"] == nil then
        vim.notify("Could not identify repo name")
        return
    end

    vim.cmd(":ObsidianNew " .. "Projects/" .. remote["path"] .. ".md")
end

local function auto_git()
    -- Set up auto pull and commit
    local group_id = vim.api.nvim_create_augroup("obsidian-git", { clear = true })

    -- Create auto pull on open
    local autopull = function()
        local Job = require("plenary.job")
        vim.notify("Pulling Obsidian notes", vim.log.levels.DEBUG, { title = "Obsidian" })
        ---@diagnostic disable-next-line: missing-fields
        Job:new({
            command = "git",
            args = { "pull" },
            on_exit = function(j, return_val)
                if return_val == 0 then
                    vim.notify("Pulled Obsidian notes", vim.log.levels.INFO, { title = "Obsidian" })
                else
                    vim.notify(
                        "Failed to pull Obsidian notes. " .. vim.inspect(j:result()),
                        vim.log.levels.ERROR,
                        { title = "Obsidian" }
                    )
                end
            end,
        }):start()
    end

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = vault_path .. "/**",
        callback = autopull,
        group = group_id,
    })

    local Job = require("plenary.job")

    -- Create autocommit on save
    local auto_add = function(next_func)
        return function(ev)
            ---@diagnostic disable-next-line: missing-fields
            Job:new({
                command = "git",
                args = { "add", ev.file },
                on_exit = function(add_j, add_return_val)
                    if add_return_val ~= 0 then
                        vim.notify(
                            "Failed to add file to git. " .. vim.inspect(add_j:result()),
                            vim.log.levels.ERROR,
                            { title = "Obsidian" }
                        )
                        return
                    end

                    if next_func then
                        next_func()
                    end
                end,
            }):start()
        end
    end

    local auto_commit = function(next_func)
        return function()
            local date_string = os.date("%Y-%m-%d %H:%M:%S")
            ---@diagnostic disable-next-line: missing-fields
            Job:new({
                command = "git",
                args = { "commit", "-m", "Auto commit: " .. date_string },
                on_exit = function(commit_j, commit_return_val)
                    if commit_return_val ~= 0 then
                        vim.notify(
                            "Failed to commit file to git. " .. vim.inspect(commit_j:result()),
                            vim.log.levels.ERROR,
                            { title = "Obsidian" }
                        )
                        return
                    end
                    if next_func then
                        next_func()
                    end
                end,
            }):start()
        end
    end

    local auto_push = function(next_func)
        return function()
            ---@diagnostic disable-next-line: missing-fields
            Job:new({
                command = "git",
                args = { "push" },
                on_exit = function(push_j, push_return_val)
                    if push_return_val ~= 0 then
                        vim.notify(
                            "Failed to push Obsidian notes. " .. vim.inspect(push_j:result()),
                            vim.log.levels.ERROR,
                            { title = "Obsidian" }
                        )
                    end

                    if next_func then
                        next_func()
                    end
                end,
            }):start()
        end
    end

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = vault_path .. "/**",
        callback = auto_add(auto_commit(auto_push())),
        group = group_id,
    })
end

-- Return plugin spec
return {
    "https://github.com/obsidian-nvim/obsidian.nvim",
    dependencies = {
        { "https://github.com/nvim-lua/plenary.nvim" },
        { "https://github.com/tpope/vim-fugitive" },
    },
    version = "^3",
    opts = {
        workspaces = {
            { name = "personal", path = vault_path },
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
        completion = {
            nvim_cmp = require("utils").is_plugin_loaded("cmp"),
            blink = require("utils").is_plugin_loaded("blink.cmp"),
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)

        auto_git()

        vim.api.nvim_create_user_command(
            "ProjectNote",
            project_note,
            { desc = "Open a note for this project in Obsidian" }
        )
    end,
    event = {
        "BufRead " .. vault_path .. "/**",
        "BufNewFile " .. vault_path .. "/**",
    },
    cmd = {
        "ObsidianOpen",
        "ObsidianNew",
        "ObsidianSearch",
        "ObsidianNewFromTemplate",
        "ObsidianWorkspace",
        "ProjectNote",
    },
}
