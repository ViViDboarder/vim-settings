-- Module to track and count occurrences of certain actions in Neovim
local M = {}

-- Path to the file where counts are stored
local counts_file = vim.fn.stdpath("config") .. "/data/counts.txt"

-- Function to read counts from the file
local function read_counts()
    local file = io.open(counts_file, "r")
    if not file then
        return {}
    end
    local contents = file:read("*a")
    file:close()

    local counts = {}
    for line in vim.fn.split(contents, "\n") do
        local key, value = string.match(line, "([^%s]+) (%d+)")
        if key and value then
            counts[key] = tonumber(value)
        end
    end

    return counts
end

-- Function to write counts to the file
local function write_counts(counts)
    local lines = {}
    for key, value in pairs(counts) do
        table.insert(lines, string.format("%s %d", key, value))
    end
    table.sort(lines) -- Sort keys alphabetically

    local contents = table.concat(lines, "\n")
    local file = io.open(counts_file, "w")
    if file then
        file:write(contents)
        file:close()
    end
end

-- Function to track a parameter and increment its count
function M.track(name, value)
    value = value or 1
    local counts = read_counts()
    counts[name] = (counts[name] or 0) + value
    write_counts(counts)
end

-- Function to display the counts in a new buffer
function M.display_counts()
    local file = io.open(counts_file, "r")
    if not file then
        return
    end
    local contents = file:read("*a")
    file:close()

    vim.api.nvim_command("enew") -- Open a new buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(contents, "\n"))
end

-- Return the module table so it can be required in other files
return M
