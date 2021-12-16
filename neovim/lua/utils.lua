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
    -- TODO: Decide if local should completely override the versioned module
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
    return _G["packer_plugins"] and packer_plugins[name] and packer_plugins[name].loaded
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

return M
