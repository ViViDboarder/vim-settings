-- luacheck: globals packer_plugins
local M = {}

-- Utils taken from https://github.com/zzzeyez/dots/blob/master/nvim/lua/utils.lua
-- Key mapping
function M.map(mode, key, result, opts)
    vim.fn.nvim_set_keymap(mode, key, result, {
        noremap = true,
        silent = opts.silent or false,
        expr = opts.expr or false,
        script = opts.script or false,
    })
end

function M.augroup(group, fn)
    vim.api.nvim_command("augroup " .. group)
    vim.api.nvim_command("autocmd!")
    fn()
    vim.api.nvim_command("augroup END")
end

function M.get_color(synID, what, mode)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(synID)), what, mode)
end

-- end zzzeyez utils

-- Create an autocmd
function M.autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then
        cmds = { cmds }
    end
    vim.cmd("augroup " .. group)
    if clear then
        vim.cmd([[au!]])
    end
    for _, cmd in ipairs(cmds) do
        vim.cmd("autocmd " .. cmd)
    end
    vim.cmd([[augroup END]])
end

-- Terminal escape a given string
function M.t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Get env value or use default, if not present
function M.env_default(name, def)
    local val = vim.env[name]
    return val == nil and def or val
end

-- Checks to see if a package can be required
function M.can_require(name)
    if package.loaded[name] then
        return false
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == "function" then
                package.preload[name] = loader
                return true
            end
        end

        return false
    end
end

-- Require a package if possible
function M.maybe_require(name)
    if M.can_require(name) then
        return require(name)
    end

    return nil
end

-- Require a package and a "_local" suffixed one
function M.require_with_local(name)
    -- Local should completely override the versioned module
    -- In that case, the local file would probably start with a `require` for the
    -- non-local version. This would allow more control but at the cost of a bit
    -- of boiler plate
    local rmod = require(name)

    local lmod = M.maybe_require(name .. "_local")
    if lmod ~= nil then
        return lmod
    end

    return rmod
end

-- Returns whether or not packer plugin is loaded
function M.is_plugin_loaded(name)
    return _G["packer_plugins"] and _G["packer_plugins"][name] and _G["packer_plugins"][name].loaded
end

-- Try to require something and perform some action if it was found
function M.try_require(name, on_found, on_notfound)
    local status, module = pcall(require, name)
    if status then
        if on_found ~= nil then
            on_found(module)
        end

        return module
    else
        if on_notfound ~= nil then
            on_notfound(name)
        end

        return nil
    end
end

-- Compare sequenced integers used to compare versions. Eg {0, 6, 0}
function M.cmp_versions(a, b)
    for i, part_a in pairs(a) do
        local part_b = b[i]
        if part_b == nil or part_a > part_b then
            return 1
        elseif part_a < part_b then
            return -1
        end
    end

    return 0
end

-- Checks if a list contains a value
function M.list_contains(list, value)
    for _, v in pairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

-- Materializes an iterator into a list
function M.materialize_list(list, iterator)
    if iterator == nil then
        iterator = list
        list = {}
    end
    for item in iterator do
        table.insert(list, item)
    end

    return list
end

M.nil_val = {}

-- Maps a set of version rules to a value eg. [">0.5.0"] = "has 0.5.0"
-- If more than one rule matches, the one with the greatest version number is used
function M.map_version_rule(rules)
    local v = vim.version()
    local current_version = { v and v.major, v and v.minor, v and v.patch }

    -- Parse a constraint and version of a string
    local parse_rule = function(rule_string)
        local cmp, major, minor, patch = string.gmatch(rule_string, "([=<>]+)(%d+).(%d+).(%d+)")()
        return cmp, tonumber(major), tonumber(minor), tonumber(patch)
    end

    -- Checks if a constraint matches the current nvim instance
    local matches = function(cmp, major, minor, patch)
        local c = M.cmp_versions(current_version, { major, minor, patch })
        if c == 1 then
            if M.list_contains({ ">", ">=" }, cmp) then
                return true
            end
        elseif c == 0 then
            if M.list_contains({ "==", ">=", "<=" }, cmp) then
                return true
            end
        elseif c == -1 then
            if M.list_contains({ "<", "<=" }, cmp) then
                return true
            end
        end
        return false
    end

    local latest_version, latest_value = nil, nil
    for rule, value in pairs(rules) do
        local cmp, major, minor, patch = parse_rule(rule)
        if matches(cmp, major, minor, patch) then
            -- If the rule matches and the version that it matches is greater than the previous matches, save it
            if latest_version == nil or M.cmp_versions({ major, minor, patch }, latest_version) == 1 then
                latest_version = { major, minor, patch }
                latest_value = value
            end
        end
    end

    -- Return highest versioned matched value
    if latest_value == M.nil_val then
        return nil
    end

    return latest_value
end

-- Basically the oposite of map
function M.swapped_map(v, func)
    func(v)
    return func
end

-- Returns a function used to create keymaps with consistent prefixes
function M.keymap_group(mode, prefix, opts, bufnr)
    local map_fn = vim.api.nvim_set_keymap
    if bufnr ~= nil then
        map_fn = function(...)
            return vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
    end

    return function(keys, rhs, new_opts)
        map_fn(mode, prefix .. keys, rhs, new_opts or opts)
    end
end

-- Diagnostics signs
M.diagnostic_signs = {
    Error = "🔥",
    Warn = "⚠️",
    Hint = "🤔",
    Info = "➞",
    Pencil = "✏️",
}

-- Don't use emoji for Kitty
if vim.env["TERM"] == "xterm-kitty" then
    M.diagnostic_signs = {
        Error = "🔥",
        Warn = "⚠",
        Hint = "🤔",
        Info = "i",
        Pencil = "✎",
    }
end

return M
