local M = {}

function M.get_color(synID, what, mode)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(synID)), what, mode)
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

-- Require a package and a "_local" suffixed one
function M.require_with_local(name)
    -- Local should completely override the versioned module
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

-- Returns whether or not lazy plugin is loaded
function M.is_plugin_loaded(name)
    local result = false
    M.try_require("lazy.core.config", function(config)
        result = config.plugins[name] ~= nil
    end)

    return result
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

-- Special not actually nil, but to be treated as nil value in some cases
M.nil_val = {}

-- Maps a set of version rules to a value eg. [">=0.5.0"] = "has 0.5.0"
-- If more than one rule matches, the one with the greatest version number is used
function M.map_version_rule(rules)
    local v = vim.version()
    local latest_version, latest_value = nil, nil
    for rule, value in pairs(rules) do
        local range = vim.version.range(rule)
        if not range then
            vim.notify("Could not parse version range: " .. rule, vim.log.levels.WARN)
        else
            local newer_from = latest_version == nil or range.from > latest_version
            if newer_from and range:has(v) then
                latest_value = value
                latest_version = range.from
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

-- Pop from table
function M.tbl_pop(t, key)
    local v = t[key]
    t[key] = nil
    return v
end

-- Calls keymap_set with preferred defaults
function M.keymap_set(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("keep", opts, { noremap = true, silent = true })
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Returns a curried function for passing data into vim.keymap.set
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
