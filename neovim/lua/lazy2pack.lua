local M = {}

M.debug = false
M.specs = {}
M.before = {}
M.after = {}

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

function M.add(lazy_spec)
    -- Simple string spec
    if type(lazy_spec) == "string" then
        M.log("Spec str " .. lazy_spec)
        vim.list_extend(M.specs, { lazy_spec })
        return
    end

    -- List of specs
    if type(lazy_spec) == "table" and #lazy_spec > 1 then
        M.log("Spec list " .. vim.inspect(lazy_spec))
        for _, spec in ipairs(lazy_spec) do
            M.add(spec)
        end
        return
    end

    -- Ignore disabled
    if lazy_spec.cond == false or lazy_spec.enabled == false then
        return
    end

    -- First add deps
    local lazy_deps = lazy_spec["dependencies"]
    if lazy_deps ~= nil then
        for _, dep in ipairs(lazy_deps) do
            M.add(dep)
        end
    end

    -- Convert spec
    local pack_spec = {}
    pack_spec.src = lazy_spec[1]

    local lazy_version = lazy_spec["version"]
    if lazy_version ~= nil then
        pack_spec.version = vim.version.range(lazy_version)
    end

    M.log("Adding pack spec")
    M.log(vim.inspect(pack_spec))

    -- Add new pack spec to spec list
    vim.list_extend(M.specs, { pack_spec })

    local lazy_config = lazy_spec["config"]
    local lazy_opts = lazy_spec["opts"]
    -- If we have opts, we need to setup plugin
    if lazy_opts ~= nil then
        -- If we have a config func, then we use that
        if lazy_config ~= nil and type(lazy_config) ~= "bool" then
            vim.list_extend(M.after, {
                function()
                    M.log("Running after for: " .. pack_spec.src)
                    lazy_config(nil, lazy_opts)
                end,
            })
        else
            local module_name = lazy_spec["main"] or get_module_name(pack_spec.src)
            vim.list_extend(M.after, {
                function()
                    M.log("Running after for: " .. pack_spec.src)
                    local status, module = pcall(require, module_name)
                    if not status then
                        vim.notify(
                            "Could not import " .. module_name .. " from " .. pack_spec.src,
                            vim.log.levels.ERROR
                        )
                        return
                    end

                    local setup = module["setup"] or module["init"]
                    if setup == nil then
                        vim.notify("Could not find setup function for " .. module_name, vim.log.levels.ERROR)
                        return
                    end

                    setup(lazy_opts)
                end,
            })
        end
    end
end

function M.run()
    for _, before in ipairs(M.before) do
        before()
    end

    M.log("Loading specs")
    M.log(vim.inspect(M.specs))
    vim.pack.add(M.specs)

    for _, after in ipairs(M.after) do
        after()
    end
end

return M
