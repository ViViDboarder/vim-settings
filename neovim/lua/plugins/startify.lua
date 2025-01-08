vim.g.startify_list_order = {
    { "   My Bookmarks" },
    "bookmarks",
    { "   Most recently used files in the current directory" },
    "dir",
    { "   Most recently used files" },
    "files",
    { "   My Sessions" },
    "sessions",
}

local function get_bookmarks()
    local Path = require("plenary.path")

    local paths = {
        "~/Documents/Obsidian",
        "~/workspace/vim-settings",
        "~/workspace/shoestrap",
        "~/.config/fish",
        "~/Nextcloud/Notes",
    }

    local bookmarks = {}
    for _, p in ipairs(paths) do
        local path = Path:new(vim.fn.expand(p))
        if path:exists() then
            table.insert(bookmarks, p)
        end
    end

    return bookmarks
end

vim.g.startify_bookmarks = get_bookmarks()
