local utils = require("utils")
local packle = require("packle")
packle.debug = true

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
packle.add({
    {
        src = "https://github.com/ViViDboarder/wombat.nvim",
        version = "pack-support",
        dependencies = { { src = "https://github.com/rktjmp/lush.nvim" } },
        after = function()
            vim.g.wombat_ansi_colors_name = get_wombat_ansi_colors_name()
            require("config.colors").init()
        end,
    },
})

-- Oldies but goodies
packle.add({
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
packle.add({
    "https://github.com/tomtom/tcomment_vim",
})
utils.keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
utils.keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })

-- argwrapping
packle.add({
    "https://git.sr.ht/~foosoft/argonaut.nvim",
})
utils.keymap_set("n", "<Leader>a", function()
    require("argonaut").reflow(true)
end, { desc = "Wrap or unwrap arguments" })

-- FZF lua
packle.add({
    src = "https://github.com/ibhagwan/fzf-lua",
    after = function()
        require("config.plugins.fzf-lua").setup()
    end,
})

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
packle.add({
    "https://github.com/sheerun/vim-polyglot",
})

-- Lualine
packle.add({
    src = "https://github.com/nvim-lualine/lualine.nvim",
    after = function()
        require("config.plugins.lualine").config_lualine()
    end,
})

-- A little less minimial

-- Fugitive
packle.add({
    {
        src = "https://github.com/tpope/vim-fugitive",
        version = utils.map_version_rule({
            [">=0.9.2"] = vim.version.range("^3"),
            -- Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
            -- when used in status line.
            ["<0.9.2"] = vim.version.range("3.6"),
        }),
        after = function()
            utils.keymap_set("n", "gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
            utils.keymap_set("n", "gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
            utils.keymap_set("n", "gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
            utils.keymap_set("n", "gs", "<cmd>Git<CR>", { desc = "Git status" })
            utils.keymap_set("n", "gw", "<cmd>Git write<CR>", { desc = "Git write" })
        end,
    },
})

-- Grepper
packle.add({ "https://github.com/mhinz/vim-grepper" })
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
packle.add({
    {
        src = "https://github.com/stevearc/quicker.nvim",
        version = vim.version.range("^1"),
        after = function()
            require("quicker").setup()
            utils.keymap_set("n", "<F6>", function()
                require("quicker").toggle()
            end, { desc = "Toggle quickfix" })
            utils.keymap_set("n", "<F7>", function()
                require("quicker").toggle({ loclist = true })
            end, { desc = "Toggle quickfix" })
        end,
    },
})

-- Using ui2 rather than this for now
--[[
-- nvim notify
packle.add({
    "https://github.com/rcarriga/nvim-notify",
})
require("config.plugins.notify")
--]]

-- HACK: Bandaid on some complicated plugin specs that I don't want to duplicate
local lazy2pack = require("lazy2pack")
-- lazy2pack.debug = true
--
-- TODO: When dropping less than 0.12 I can migrate these, or maybe migrate
-- them and build an adapter that works the other direction
packle.add(lazy2pack.convert(require("lazy_specs.obsidian")))
local ls_specs = lazy2pack.convert(require("lazy_specs.language_servers"))
print(vim.inspect(ls_specs))
packle.add(ls_specs)
-- lazy2pack.add(require("lazy_specs.llm_assist"))

packle.apply()
