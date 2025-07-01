local M = {}

--- Get the attribute of a syntax ID
---@param synID string The syntax ID
---@param what string The attribute to get
---@param mode string? The mode (optional)
---@return string The attribute value
function M.get_color(synID, what, mode)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(synID)), what, mode)
end

--- Terminal escape a given string
---@param str string The string to escape
---@return string The escaped string
function M.t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--- Get env value or use default, if not present
---@param name string The environment variable name
---@param def any The default value
---@return any The environment variable value or the default
function M.env_default(name, def)
    local val = vim.env[name]
    return val == nil and def or val
end

--- Require a package and a "_local" suffixed one
---@param name string The module name
---@return table The module
function M.require_with_local(name)
    --- Local should completely override the versioned module
    -- In that case, the local file would probably start with a `require` for the
    -- non-local version. This would allow more control but at the cost of a bit
    -- of boiler plate
    local rmod = require(name)

    local lmod = M.try_require(name .. "_local")
    if lmod ~= nil then
        return lmod
    end

    return rmod
end

--- Returns whether or not lazy plugin is installed
---@param name string The plugin name
---@return boolean Whether the plugin is installed
function M.is_plugin_installed(name)
    local is_installed = false
    M.try_require("lazy.core.config", function(config)
        local plugin = config.plugins[name]
        if plugin ~= nil then
            is_installed = plugin._.installed
        end
    end)

    return is_installed
end

--- Returns whether or not lazy plugin is loaded
---@param name string The plugin name
---@return boolean Whether the plugin is loaded
function M.is_plugin_loaded(name)
    local is_loaded = false
    M.try_require("lazy.core.config", function(config)
        local plugin = config.plugins[name]
        if plugin ~= nil then
            is_loaded = plugin._.loaded ~= nil
        end
    end)

    return is_loaded
end

--- Try to require something and perform some action if it was found
---@param name string The module name
---@param on_found fun(module: table)? Optional callback if the module is found
---@param on_notfound fun(name: string)? Optional callback if the module is not found
---@return table|nil The module or nil if not found
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

--- Compare sequenced integers used to compare versions. Eg {0, 6, 0}
---@param a table The first version
---@param b table The second version
---@return number -1 if a < b, 0 if a == b, 1 if a > b
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

--- Materializes an iterator into a list
---@param list table The initial list
---@param iterator any The iterator
---@return table The materialized list
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

--- Special not actually nil, but to be treated as nil value in some cases
M.nil_val = {}

--- Maps a set of version rules to a value eg. [">=0.5.0"] = "has 0.5.0"
---@param rules table The version rules
---@return any The mapped value or nil if no rule matches
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
            if vim.tbl_contains({ ">", ">=" }, cmp) then
                return true
            end
        elseif c == 0 then
            if vim.tbl_contains({ "==", ">=", "<=" }, cmp) then
                return true
            end
        elseif c == -1 then
            if vim.tbl_contains({ "<", "<=" }, cmp) then
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

--- Basically the oposite of map
---@param v any The value to pass to the function
---@param func fun(v: any):any The function to call
---@return fun(v: any):any The same function
function M.swapped_map(v, func)
    func(v)
    return func
end

--- Pop from table
---@param t table The table
---@param key string The key to pop
---@return any The popped value
function M.tbl_pop(t, key)
    local v = t[key]
    t[key] = nil
    return v
end

--- Calls keymap_set with preferred defaults
---@param mode string|string[] The mode
---@param lhs string The left-hand side of the mapping
---@param rhs string|function The right-hand side of the mapping
---@param opts table? The options (optional)
function M.keymap_set(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("keep", opts, { noremap = true, silent = true })
    vim.keymap.set(mode, lhs, rhs, opts)
end

--- Returns a curried function for passing data into vim.keymap.set
---@param mode string The mode
---@param prefix string The prefix for the mapping
---@param default_opts table? The default options (optional)
---@return fun(lhs: string, rhs: string|function, opts?: table) A curried keymap set function
function M.curry_keymap(mode, prefix, default_opts)
    default_opts = vim.tbl_extend("keep", default_opts or {}, { noremap = true, silent = true })
    local group_desc = M.tbl_pop(default_opts, "group_desc")
    if group_desc ~= nil then
        M.try_require("which-key", function(wk)
            wk.register({
                [prefix] = "+" .. group_desc,
            }, default_opts)
        end)
    end

    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("keep", opts or {}, default_opts)
        local opt_mode = M.tbl_pop(opts, "mode")
        vim.keymap.set(opt_mode or mode, prefix .. lhs, rhs, opts)
    end
end

return M
