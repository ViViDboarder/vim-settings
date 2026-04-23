local M = {}

M.debug = false

local function get_module_name(repo)
    -- normalize (remove protocol if present)
    repo = repo:gsub("^https?://", "")
    repo = repo:gsub("^git@", "")
    repo = repo:gsub(":", "/")

    -- get last path segment
    local name = repo:match("([^/]+)$") or repo

    -- strip .git
    name = name:gsub("%.git$", "")

    -- strip common nvim plugin suffixes
    name = name:gsub("%.nvim$", "")
    name = name:gsub("%-nvim$", "")
    name = name:gsub("_nvim$", "")

    return name
end

function M.log(value)
    if M.debug then
        vim.print(value)
    end
end

function M.convert(lazy_spec)
    if lazy_spec == nil then
        return nil
    end

    -- Simple string spec
    if type(lazy_spec) == "string" then
        M.log("Converting string lazy spec " .. lazy_spec)
        return { src = lazy_spec }
    end

    -- List of specs: multiple entries, or [1] is a sub-spec table rather than a URL string
    if type(lazy_spec) == "table" and (type(lazy_spec[1]) == "table" or #lazy_spec > 1) then
        local spec_list = {}
        for _, spec in ipairs(lazy_spec) do
            local pack_spec = M.convert(spec)
            if pack_spec ~= nil then
                table.insert(spec_list, pack_spec)
            end
        end

        if #spec_list == 0 then
            return nil
        end

        return spec_list
    end

    -- Ignore disabled. Note: cond/enabled as functions are not evaluated;
    -- only the literal boolean false is checked.
    if lazy_spec.cond == false or lazy_spec.enabled == false then
        M.log("Spec " .. lazy_spec[1] .. " is disabled")
        return nil
    end

    -- Convert spec
    local pack_spec = {}
    pack_spec.src = lazy_spec[1]
    if lazy_spec.dependencies ~= nil then
        pack_spec.dependencies = M.convert(lazy_spec.dependencies)
    end

    local lazy_version = lazy_spec["version"]
    if lazy_version ~= nil then
        pack_spec.version = vim.version.range(lazy_version)
    else
        pack_spec.version = lazy_spec["commit"] or lazy_spec["branch"]
    end

    local lazy_config = lazy_spec["config"]
    local lazy_opts = lazy_spec["opts"]
    if lazy_opts ~= nil and lazy_config == nil then
        lazy_config = true
    end

    -- If we have opts, we need to setup plugin
    if lazy_config ~= nil then
        -- If we have a config func, then we use that
        if type(lazy_config) ~= "boolean" then
            M.log("Creating custom config after for: " .. pack_spec.src)
            pack_spec.after = function()
                M.log("Running after for: " .. pack_spec.src)
                lazy_config(nil, lazy_opts)
            end
        else
            local module_name = lazy_spec["main"] or get_module_name(pack_spec.src)
            M.log("Creating default config after for: " .. pack_spec.src)
            pack_spec.after = function()
                M.log("Running after for: " .. pack_spec.src)
                local status, module = pcall(require, module_name)
                if not status then
                    vim.notify("Could not import " .. module_name .. " from " .. pack_spec.src, vim.log.levels.ERROR)
                    return
                end

                local setup = module["setup"] or module["init"]
                if setup == nil then
                    vim.notify("Could not find setup function for " .. module_name, vim.log.levels.ERROR)
                    return
                end

                setup(lazy_opts)
            end
        end
    end

    M.log("Converted lazy spec to " .. vim.inspect(pack_spec))

    return pack_spec
end

return M
