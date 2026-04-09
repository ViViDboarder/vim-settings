---@class PackleSpecDetail
---@field before? (fun())
---@field after? (fun())
---@field dependencies PackleSpecDetail[]|string[]

---@alias PackleSpec string|PackleSpecDetail|PackleSpec[]

local M = {}

M.debug = false
M.spec_order = {} ---@type table<string>
M.specs = {} ---@type table<string, PacSpec>

function M.log(value)
    if M.debug then
        vim.print(value)
    end
end

---@overload fun(pack_spec: PackleSpec)
function M.add(pack_spec)
    M.log("Adding pack spec " .. vim.inspect(pack_spec))
    if pack_spec == nil then
        return
    end

    -- Simple string spec
    if type(pack_spec) == "string" then
        pack_spec = { src = pack_spec }
    end

    -- List of specs
    if type(pack_spec) == "table" and #pack_spec > 0 then
        for _, spec in ipairs(pack_spec) do
            M.add(spec)
        end
        return
    end

    -- First add deps
    local lazy_deps = pack_spec["dependencies"]
    if lazy_deps ~= nil then
        for _, dep in ipairs(lazy_deps) do
            M.add(dep)
        end
    end

    local existing_spec = M.specs[pack_spec.src]
    if existing_spec ~= nil then
        M.log("Updating existing spec " .. pack_spec.src)
        pack_spec["src"] = nil
        -- Error if there is a key collision since merges are destructive and not recursive
        M.specs[pack_spec.src] = vim.tbl_extend("error", existing_spec, pack_spec)
    else
        M.log("Adding new spec " .. pack_spec.src)
        M.specs[pack_spec.src] = pack_spec
        M.spec_order = vim.list_extend(M.spec_order, { pack_spec.src })
    end
end

function M.apply()
    for _, spec_src in ipairs(M.spec_order) do
        local pack_spec = M.specs[spec_src]
        if pack_spec.before ~= nil then
            M.log("Run before func for " .. spec_src)
            pack_spec.before()
        end
    end

    M.log("Adding specs")
    local ordered_specs = vim.iter(M.spec_order)
        :map(function(spec_src)
            M.log("Adding spec " .. spec_src)
            local pack_spec = M.specs[spec_src]
            return { src = pack_spec.src, version = pack_spec.version }
        end)
        :totable()
    vim.pack.add(ordered_specs)

    for _, spec_src in ipairs(M.spec_order) do
        local pack_spec = M.specs[spec_src]
        if pack_spec.after ~= nil then
            M.log("Run after func for " .. spec_src)
            pack_spec.after()
        end
    end
end

return M
