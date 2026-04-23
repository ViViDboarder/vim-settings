local M = {}

M.debug = false

--- Log a value to the console when debug mode is enabled.
--- @param value any The value to print
function M.log(value)
    if M.debug then
        vim.print(value)
    end
end

--- Convert a vim.VersionRange to a semver constraint string.
--- @param range vim.VersionRange The version range to convert
--- @return string|nil # A semver constraint string, or nil if the range has no `from`
local function version_range_to_string(range)
    -- vim.VersionRange has .from (vim.Version) and .to (vim.Version?)
    local from = range.from
    if from == nil then
        return nil
    end

    local to = range.to
    if to == nil then
        return string.format(">=%d.%d.%d", from.major, from.minor, from.patch)
    end

    return string.format(">=%d.%d.%d <%d.%d.%d", from.major, from.minor, from.patch, to.major, to.minor, to.patch)
end

--- Convert a pack version specifier into separate version, commit, and branch components.
--- @param version string|vim.VersionRange|nil A version string (commit hash or branch name) or a VersionRange object
--- @return string|nil version A semver constraint string
--- @return string|nil commit A commit hash (7+ hex characters)
--- @return string|nil branch A branch name
local function convert_version(version)
    if version == nil then
        return nil, nil, nil
    end

    if type(version) == "string" then
        -- 7+ hex chars = commit hash; otherwise = branch name
        if version:match("^[0-9a-fA-F]+$") and #version >= 7 then
            return nil, version, nil -- commit
        else
            return nil, nil, version -- branch
        end
    end

    -- vim.VersionRange object
    return version_range_to_string(version), nil, nil
end

--- Convert a Packle spec (or list of specs) into a lazy.nvim-compatible spec.
--- Handles string specs, list specs, and detailed table specs recursively.
--- @param pack_spec string|table|nil A Packle plugin specification
--- @return string|table|nil # A lazy.nvim-compatible plugin specification, or nil if the input is empty/nil
function M.convert(pack_spec)
    if pack_spec == nil then
        return nil
    end

    -- Simple string spec (git URL)
    if type(pack_spec) == "string" then
        M.log("Converting string pack spec " .. pack_spec)
        return pack_spec
    end

    -- Ignore empty specs
    if next(pack_spec) == nil then
        return nil
    end

    -- List of specs (has numeric indices, no 'src' key)
    if pack_spec[1] ~= nil and pack_spec.src == nil then
        M.log("Converting pack spec list")
        local spec_list = {}
        for _, spec in ipairs(pack_spec) do
            local lazy_spec = M.convert(spec)
            if lazy_spec ~= nil then
                spec_list = vim.list_extend(spec_list, { lazy_spec })
            end
        end

        if #spec_list == 0 then
            return nil
        end

        return spec_list
    end

    -- Convert PackleSpecDetail to LazySpec
    M.log("Converting pack spec " .. vim.inspect(pack_spec))
    local lazy_spec = {}
    lazy_spec[1] = pack_spec.src

    -- Dependencies
    if pack_spec.dependencies ~= nil then
        lazy_spec.dependencies = M.convert(pack_spec.dependencies)
    end

    -- Version
    local ver, commit, branch = convert_version(pack_spec.version)
    lazy_spec.version = ver
    lazy_spec.commit = commit
    lazy_spec.branch = branch

    -- Lifecycle hooks
    lazy_spec.init = pack_spec.before
    lazy_spec.config = pack_spec.after

    M.log("Converted pack spec to " .. vim.inspect(lazy_spec))

    return lazy_spec
end

return M
