local utils = require("utils")

-- Pack helpers
local function pack_clean()
    local inactive_packs = vim.iter(vim.pack.get())
        :filter(function(x)
            return not x.active
        end)
        :map(function(x)
            return x.spec.name
        end)
        :totable()
    vim.pack.del(inactive_packs)
end

vim.api.nvim_create_user_command("PackClean", function()
    pack_clean()
end, { desc = "Clean unused packs" })

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update packs" })

vim.api.nvim_create_user_command("PackRevert", function()
    vim.pack.update(nil, { target = "lockfile" })
    pack_clean()
end, { desc = "Revert packs to lockfile" })

vim.api.nvim_create_user_command("PackList", function()
    vim.pack.update(nil, { offline = true })
end, { desc = "List packs" })

-- Installed packs below

-- Wombat colorscheme
local function get_wombat_ansi_colors_name()
    -- Set ansi base colors for wombat theme based on terminal program
    local term_program = vim.env.TERM_PROGRAM
    local term_profile = vim.env.TERM_PROFILE

    if term_program == "iTerm.app" or term_profile == "Wombat-iTerm" then
        return "iterm2"
    elseif term_program == "ghostty" then
        return "ghostty"
    end
end
vim.pack.add({
    {
        src = "https://github.com/ViViDboarder/wombat.nvim",
        version = "pack-support",
    },
    { src = "https://github.com/rktjmp/lush.nvim" },
})
vim.g.wombat_ansi_colors_name = get_wombat_ansi_colors_name()
require("config.colors").init()

-- Oldies but goodies
vim.pack.add({
    "https://github.com/tpope/vim-endwise",
    -- Unix commands from vim? Yup!
    "https://github.com/tpope/vim-eunuch",
    -- Adds repeats for custom motions
    "https://github.com/tpope/vim-repeat",
    -- Readline shortcuts
    "https://github.com/tpope/vim-rsi",
    -- Surround motions
    "https://github.com/tpope/vim-surround",
    -- Better netrw
    "https://github.com/tpope/vim-vinegar",
    -- Easier jumping to lines
    "https://github.com/vim-scripts/file-line",
    -- Auto ctags generation
    "https://github.com/ludovicchabant/vim-gutentags",
    -- Debug startup time
    "https://github.com/tweekmonster/startuptime.vim",
})

-- tcomment and keys
vim.pack.add({
    "https://github.com/tomtom/tcomment_vim",
})
utils.keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
utils.keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })

-- argwrapping
vim.pack.add({
    "https://git.sr.ht/~foosoft/argonaut.nvim",
})
utils.keymap_set("n", "<Leader>a", function()
    require("argonaut").reflow(true)
end, { desc = "Wrap or unwrap arguments" })

-- FZF lua
vim.pack.add({
    "https://github.com/ibhagwan/fzf-lua",
})
require("plugins.fzf-lua").setup()

-- Polyglot
if not vim.g.minimal then
    vim.g.polyglot_disabled = { "go", "rust" }
end
local polyglot_fts_gid = vim.api.nvim_create_augroup("polyglot_fts", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*/playbooks/*.yml", "*/playbooks/*.yaml" },
    command = "set filetype=yaml.ansible",
    group = polyglot_fts_gid,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "go.mod", "go.sum" },
    command = "set filetype=gomod",
    group = polyglot_fts_gid,
})
vim.pack.add({
    "https://github.com/sheerun/vim-polyglot",
})

-- Lualine
vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })
require("plugins.lualine").config_lualine()

-- A little less minimial

-- Fugitive
vim.pack.add({
    {
        src = "https://github.com/tpope/vim-fugitive",
        version = utils.map_version_rule({
            [">=0.9.2"] = vim.version.range("^3"),
            -- Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
            -- when used in status line.
            ["<0.9.2"] = vim.version.range("3.6"),
        }),
    },
})
utils.keymap_set("n", "gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
utils.keymap_set("n", "gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
utils.keymap_set("n", "gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
utils.keymap_set("n", "gs", "<cmd>Git<CR>", { desc = "Git status" })
utils.keymap_set("n", "gw", "<cmd>Git write<CR>", { desc = "Git write" })

-- Grepper
vim.pack.add({ "https://github.com/mhinz/vim-grepper" })
-- Grepper settings and shortcuts
vim.g.grepper = {
    quickfix = 1,
    open = 1,
    switch = 0,
    jump = 0,
    tools = { "git", "rg", "ag", "ack", "pt", "grep" },
    dir = "repo,cwd",
}

-- Override Todo command to use Grepper
vim.api.nvim_create_user_command("Todo", ":Grepper -noprompt -query TODO", { desc = "Search for TODO tags" })

-- Make some shortands for various grep programs
if vim.fn.executable("rg") == 1 then
    vim.api.nvim_create_user_command("Rg", ":GrepperRg <args>", { nargs = "+", desc = "Ripgrep" })
end
if vim.fn.executable("ag") == 1 then
    vim.api.nvim_create_user_command("Ag", ":GrepperAg <args>", { nargs = "+", desc = "Silversearcher" })
end
if vim.fn.executable("ack") == 1 then
    vim.api.nvim_create_user_command("Ack", ":GrepperAck <args>", { nargs = "+", desc = "Ack search" })
end

-- quicklist customization
vim.pack.add({
    {
        src = "https://github.com/stevearc/quicker.nvim",
        -- event = "FileType qf",
        version = vim.version.range("^1"),
    },
})
require("quicker").setup()
utils.keymap_set("n", "<F6>", function()
    require("quicker").toggle()
end, { desc = "Toggle quickfix" })
utils.keymap_set("n", "<F7>", function()
    require("quicker").toggle({ loclist = true })
end, { desc = "Toggle quickfix" })

-- nvim notify
vim.pack.add({
    "https://github.com/rcarriga/nvim-notify",
})
require("plugins.notify")

-- HACK: Bandaid on some complicated plugin specs that I don't want to duplicate
local lazy2pack = require("lazy2pack")
-- lazy2pack.debug = true
--
-- TODO: When dropping less than 0.12 I can migrate these, or maybe migrate
-- them and build an adapter that works the other direction
lazy2pack.add(require("lazy_specs.obsidian"))
lazy2pack.add(require("lazy_specs.llm_assist"))
lazy2pack.run()
