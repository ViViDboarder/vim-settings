local utils = require("utils")
-- packle.debug = true

-- Some packages not installed yet
-- vim-android go.nvim navic todo-comments.nvim Trouble

-- Pack helpers
local function pack_clean()
    local inactive_packs = vim.iter(vim.pack.get())
        :filter(function(x)
            return not x.active
        end)
        :map(function(x)
            return x.spec.name
        end)
        :totable()
    vim.pack.del(inactive_packs)
end

vim.api.nvim_create_user_command("PackClean", function()
    pack_clean()
end, { desc = "Clean unused packs" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    local unlocked_packs = vim.iter(vim.pack.get())
        :filter(function(x)
            return opts.bang or x.spec.data == nil or x.spec.data.lock ~= true
        end)
        :map(function(x)
            return x.spec.name
        end)
        :totable()
    vim.pack.update(unlocked_packs)
end, { bang = true, desc = "Update packs" })

vim.api.nvim_create_user_command("PackRevert", function()
    vim.pack.update(nil, { target = "lockfile" })
    pack_clean()
end, { desc = "Revert packs to lockfile" })

vim.api.nvim_create_user_command("PackList", function()
    vim.pack.update(nil, { offline = true })
end, { desc = "List packs" })

local function link_lockfile()
    local actual_lockfile = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")
    local version_lockfile = vim.fs.joinpath(
        vim.fn.stdpath("config"),
        ("nvim-pack-lock-%s.%s.json"):format(vim.version().major, vim.version().minor)
    )

    -- Make sure a version_lockfile exists
    if not utils.fs.exists(version_lockfile) then
        if utils.fs.exists(actual_lockfile) then
            print("Warning: Version lockfile does not exist, but actual does. Renaming...")
            if not utils.fs.rename(actual_lockfile, version_lockfile) then
                return
            end
        else
            if not utils.fs.touch(version_lockfile) then
                return
            end
        end
    end

    -- Make sure the actual lockfile links to the version lockfile
    if utils.fs.exists(actual_lockfile) then
        local result = vim.system({ "readlink", actual_lockfile }):wait(100)
        if result.code ~= 0 or result.stdout == "" then
            print("Error: Lockfile was not a link. Check the " .. actual_lockfile)
            return
        end

        local link_target = utils.strip(result.stdout)
        if link_target == version_lockfile then
            -- Lockfile is already pointing to the appropriate place, we can exit
            return
        else
            print(
                ("Lockfiles do not point to the same target. Expected: `%s` Actual: `%s`. Removing so we can re-link."):format(
                    version_lockfile,
                    link_target
                )
            )
            vim.fs.rm(actual_lockfile)
        end
    end

    utils.fs.symblink(version_lockfile, actual_lockfile)
end

link_lockfile()

require("config.pack_plugins")
