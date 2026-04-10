local utils = require("utils")
local packle = require("packle")
-- packle.debug = true

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
packle.add({
    {
        src = "https://github.com/ViViDboarder/wombat.nvim",
        after = function()
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
    src = "https://github.com/tomtom/tcomment_vim",
    after = function()
        utils.keymap_set("n", "//", ":TComment<CR>", { desc = "Toggle comment" })
        utils.keymap_set("v", "//", ":TCommentBlock<CR>", { desc = "Toggle comment" })
    end,
})

-- argwrapping
packle.add({
    src = "https://git.sr.ht/~foosoft/argonaut.nvim",
    after = function()
        utils.keymap_set("n", "<Leader>a", function()
            require("argonaut").reflow(true)
        end, { desc = "Wrap or unwrap arguments" })
    end,
})

-- FZF lua
packle.add({
    src = "https://github.com/ibhagwan/fzf-lua",
    after = function()
        require("config.plugins.fzf-lua").setup()
    end,
})

-- Polyglot
packle.add({
    src = "https://github.com/sheerun/vim-polyglot",
    after = function()
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
    end,
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
packle.add({
    src = "https://github.com/mhinz/vim-grepper",
    after = function()
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
    end,
})

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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "qf",
                callback = function()
                    utils.try_require("quicker", function(quicker)
                        utils.keymap_set("n", ">", function()
                            quicker.expand({ before = 2, after = 2, add_to_existing = true })
                        end, { desc = "Expand quickfix context", buffer = true })
                        utils.keymap_set("n", "<", function()
                            quicker.collapse()
                        end, { desc = "Collapse quickfix context", buffer = true })
                        utils.keymap_set("n", "<C-r>", function()
                            quicker.refresh()
                        end, { desc = "Refresh quickfix context", buffer = true })
                    end)
                end,
            })
        end,
    },
})

packle.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        -- Consider https://github.com/arborist-ts/arborist.nvim in the future
        -- I don't like that the plugin enables executing code downloaded from
        -- other sources, but I guess I could pin the commit too.

        -- Plugin is archived, pinning until it breaks
        version = "4916d6592ede8c07973490d9322f187e07dfefac",
        dependencies = {
            "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
        },
        after = function()
            -- NOTE: This could possibly move into ftplugin files
            local enable_fts = utils.require_with_local("config.plugins.treesitter").ensure_installed
            local ts_gid = vim.api.nvim_create_augroup("treesitter_fts", { clear = true })
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 2
            vim.api.nvim_create_autocmd("FileType", {
                pattern = enable_fts,
                callback = function()
                    local nvim_ts = require("nvim-treesitter")
                    local installed_parsers = nvim_ts.get_installed()
                    if not vim.list_contains(installed_parsers, vim.bo.filetype) then
                        nvim_ts.install(vim.bo.filetype):wait(10000)
                    end

                    -- Enable highlighting
                    vim.treesitter.start()
                    -- Enable folding
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                end,
                group = ts_gid,
            })
        end,
    },
})

packle.add({
    {
        -- Make it easier to discover some of my keymaps
        src = "https://github.com/folke/which-key.nvim",
        version = vim.version.range("^3"),
        after = function()
            -- Ignore warnings about config. Turn these on when switching major versions
            require("which-key").setup({
                notify = false,
                icons = {
                    mappings = require("config.icons").nerd_font,
                },
            })
            utils.keymap_set("n", "<leader>?", function()
                require("which-key").show({ global = false })
            end, { desc = "Buffer Local Keymaps (which-key)" })
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
packle.add(lazy2pack.convert(require("lazy_specs.language_servers")))
packle.add(lazy2pack.convert(require("lazy_specs.dap")))
packle.add(lazy2pack.convert(require("lazy_specs.llm_assist")))

packle.apply()

-- This should run after all the LSP plugins are installed
require("config.plugins.lsp").setup()
