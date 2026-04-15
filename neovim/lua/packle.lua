---@class PackleSpecDetail
---@field src string
---@field name? string
---@field lock? boolean
---@field version? string|vim.VersionRange
---@field before? (fun())
---@field after? (fun())
---@field dependencies? PackleSpecDetail[]|string[]

---@alias PackleSpec string|PackleSpecDetail|PackleSpec[]|nil

local M = {}

M.debug = false
M.spec_order = {} ---@type string[]
M.specs = {} ---@type table<string, PackleSpecDetail>

function M.log(value)
    if M.debug then
        vim.print(value)
    end
end

function M.add(pack_spec)
    local log = function(value)
        M.log("packle.add: " .. value)
    end

    log("Initial spec: " .. vim.inspect(pack_spec))

    -- Ignore null specs
    if pack_spec == nil then
        return
    end

    -- Simple string spec
    if type(pack_spec) == "string" then
        pack_spec = { src = pack_spec }
    end

    -- Ignore empty specs
    if next(pack_spec) == nil then
        return
    end

    -- List of specs
    if type(pack_spec) == "table" and #pack_spec > 0 then
        log("Spec list: begin")
        for _, spec in ipairs(pack_spec) do
            M.add(spec)
        end
        log("Spec list: end")
        return
    end

    -- First add deps
    local lazy_deps = pack_spec["dependencies"]
    if lazy_deps ~= nil then
        log("Add deps")
        M.add(lazy_deps)
    end

    if pack_spec.src == nil then
        vim.notify("packle: spec is missing 'src' field: " .. vim.inspect(pack_spec), vim.log.levels.WARN)
        return
    end

    local spec_src = pack_spec.src
    local existing_spec = M.specs[spec_src]
    if existing_spec ~= nil then
        log("Updating existing spec: " .. spec_src)
        -- Copy incoming spec without 'src' to avoid key collision on merge.
        -- Error on other collisions since merges are destructive and not recursive.
        local incoming = vim.tbl_extend("force", {}, pack_spec)
        incoming.src = nil
        M.specs[spec_src] = vim.tbl_extend("error", existing_spec, incoming)
    else
        log("Adding new spec: " .. spec_src)
        M.specs[spec_src] = pack_spec
        table.insert(M.spec_order, spec_src)
    end
end

function M.apply()
    local log = function(value)
        M.log("packle.apply: " .. value)
    end

    for _, spec_src in ipairs(M.spec_order) do
        local pack_spec = M.specs[spec_src]
        if pack_spec ~= nil and pack_spec.before ~= nil then
            log("Run before func for " .. spec_src)
            pack_spec.before()
        end
    end

    log("Activating specs")
    local ordered_specs = vim.iter(M.spec_order)
        :map(function(spec_src)
            log("Activating spec " .. spec_src)
            local pack_spec = M.specs[spec_src] ---@type PackleSpecDetail
            if pack_spec == nil then
                return nil
            end
            local data = nil
            if pack_spec.lock then
                data = { lock = true }
            end
            return {
                src = spec_src,
                name = pack_spec.name,
                version = pack_spec.version,
                data = data,
            }
        end)
        :filter(function(spec)
            return spec ~= nil
        end)
        :totable()
    vim.pack.add(ordered_specs)

    for _, spec_src in ipairs(M.spec_order) do
        local pack_spec = M.specs[spec_src]
        if pack_spec ~= nil and pack_spec.after ~= nil then
            log("Run after func for " .. spec_src)
            pack_spec.after()
        end
    end
end

return M
