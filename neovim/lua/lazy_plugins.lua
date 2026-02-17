-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        -- Make it easier to discover some of my keymaps
        "https://github.com/folke/which-key.nvim",
        opts = {
            -- Ignore warnings about config. Turn these on when switching major versions
            notify = false,
            icons = {
                mappings = require("icons").nerd_font,
            },
        },
        version = utils.map_version_rule({
            [">=0.9.4"] = "^3",
            [">=0.9.0"] = "<3.4.0",
            ["<0.9.0"] = "1.x.x",
        }),
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
        event = "VeryLazy",
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
            },
            exclude = {
                filetypes = {
                    "help",
                    "markdown",
                    "text",
                    "gitcommit",
                    "gitrebase",
                    "diff",
                    "fugitive",
                    "fugitiveblame",
                    "startify",
                },
            },
        },
    },
    {
        -- Adds git operations to vim
        "https://github.com/tpope/vim-fugitive",
        version = utils.map_version_rule({
            [">=0.9.2"] = "^3",
            -- Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
            -- when used in status line.
            ["<0.9.2"] = "3.6",
        }),
        keys = {
            { "gb", "<cmd>Git blame<CR>", desc = "Git blame" },
            { "gc", "<cmd>Git commit<CR>", desc = "Git commit" },
            { "gd", "<cmd>Git diff<CR>", desc = "Git diff" },
            { "gs", "<cmd>Git<CR>", desc = "Git status" },
            { "gw", "<cmd>Git write<CR>", desc = "Git write" },
        },
        cmd = {
            "Git",
            "Gedit",
            "Gdiffsplit",
            "Gread",
            "Gwrite",
            "Ggrep",
            "GMove",
            "GDelete",
        },
    },
    {
        -- Find text everywhere!
        "https://github.com/mhinz/vim-grepper",
        config = function()
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
            vim.api.nvim_create_user_command(
                "Todo",
                ":Grepper -noprompt -query TODO",
                { desc = "Search for TODO tags" }
            )

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
        cmd = {
            "Todo",
            "Rg",
            "Ag",
            "Ack",
        },
    },
    {
        -- TODO: Remove when min version is 0.10
        -- Quick toggling of Location and Quickfix lists
        "https://github.com/milkypostman/vim-togglelist",
        -- Stable plugin, pinning to avoid any issues stemming from possible takeover
        commit = "48f0d30292efdf20edc883e61b121e6123e03df7",
        keys = {
            { "<F6>", ":call ToggleQuickfixList()<CR>", desc = "Toggle quickfix" },
            { "<F7>", ":call ToggleLocationList()<CR>", desc = "Toggle location list" },
        },
        enabled = vim.fn.has("nvim-0.10") ~= 1,
    },
    {
        "https://github.com/stevearc/quicker.nvim",
        event = "FileType qf",
        version = "^1",
        keys = {
            {
                "<F6>",
                function()
                    require("quicker").toggle()
                end,
                desc = "Toggle quickfix",
            },
            {
                "<F7>",
                function()
                    require("quicker").toggle({ loclist = true })
                end,
                desc = "Toggle quickfix",
            },
        },
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {
            keys = {
                {
                    ">",
                    function()
                        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                    end,
                    desc = "Expand quickfix context",
                },
                {
                    "<",
                    function()
                        require("quicker").collapse()
                    end,
                    desc = "Collapse quickfix context",
                },
                {
                    "<C-r>",
                    function()
                        require("quicker").refresh()
                    end,
                    desc = "Refresh quickfix context",
                },
            },
        },
        enabled = vim.fn.has("nvim-0.10") == 1,
    },
    {
        -- Highlight inline colors
        "https://github.com/norcalli/nvim-colorizer.lua",
        config = true,
        cmd = { "ColorizerToggle" },
    },
    {
        -- On Mac, update colors when dark mode changes
        "https://github.com/cormacrelf/dark-notify",
        -- Pinned to latest commit that builds since old release won't anymore
        commit = "0d8501ca027b4355ed958b937ed51b37632c60cf",
        enabled = vim.g.is_mac == 1,
        -- Download latest release on install
        build = "cargo install --git https://github.com/cormacrelf/dark-notify --rev 0d8501ca027b4355ed958b937ed51b37632c60cf",
        config = function()
            require("plugins.darknotify").run()
        end,
        dependencies = { { "https://github.com/nvim-lualine/lualine.nvim" } },
        event = "VeryLazy",
    },
    {
        -- Custom start screen
        "https://github.com/mhinz/vim-startify",
        config = function()
            require("utils").require_with_local("plugins.startify")
        end,
        dependencies = {
            -- Plenary isn't used by startify, but it is used in my config
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
    },

    -- LSP

    -- Debug adapter protocol
    { import = "lazy_specs.dap" },
    { import = "lazy_specs.language_servers" },

    {
        -- Better display of lsp diagnostics
        "https://github.com/folke/trouble.nvim",
        config = true,
        version = utils.map_version_rule({
            [">=0.9.2"] = "^3",
            [">=0.7.2"] = "^2",
            ["<0.7.2"] = "^1",
        }),
        cmd = {
            "Trouble",
        },
    },
    {
        -- LSP locations in status line
        "https://github.com/SmiteshP/nvim-navic",
        dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
        lazy = true,
    },

    -- Incremental lsp rename view
    {
        "https://github.com/smjonas/inc-rename.nvim",
        opts = {
            input_buffer_type = "dressing",
        },
        lazy = true,
        cmd = {
            "IncRename",
        },
    },

    -- Writing
    -- abolish/pencil
    {
        "https://github.com/preservim/vim-pencil",
        version = "^1",
        dependencies = {
            {
                "https://github.com/preservim/vim-textobj-sentence",
                dependencies = {
                    { "https://github.com/kana/vim-textobj-user" },
                },
                config = function()
                    vim.fn["textobj#sentence#init"]()
                end,
            },
        },
        cmd = { "Pencil" },
    },
    {
        "https://github.com/junegunn/goyo.vim",
        cmd = { "Goyo", "Zen" },
        config = function()
            require("plugins.goyo-limelight")
        end,
        dependencies = {
            { "https://github.com/junegunn/limelight.vim", cmd = "Limelight" },
        },
    },

    -- Treesitter
    {
        "https://github.com/nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        version = utils.map_version_rule({
            [">=0.10.0"] = utils.nil_val,
            [">=0.9.2"] = "0.9.3",
            ["==0.9.2"] = "0.9.2",
            ["==0.9.1"] = "0.9.1",
            ["==0.9.0"] = "0.9.0",
        }),
        config = function()
            require("utils").require_with_local("plugins.treesitter").setup()
        end,
        dependencies = {
            { "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
        },
    },

    -- Filetypes
    { "https://github.com/ViViDboarder/vim-forcedotcom" },
    { "https://github.com/hsanson/vim-android" },
    {
        "https://github.com/ray-x/go.nvim",
        dependencies = { -- optional packages
            -- "https://github.com/ray-x/guihua.lua",
            "https://github.com/neovim/nvim-lspconfig",
            "https://github.com/nvim-treesitter/nvim-treesitter",
            "https://github.com/rcarriga/nvim-dap-ui",
        },
        config = function()
            require("go").setup({
                icons = require("icons").nerd_font,
                -- I don't like the normal mode keymap because it overrides `w`
                dap_debug_keymap = false,
                -- Disable gui setup becuase this is set up with dap-ui
                dap_debug_gui = false,
            })

            -- Override some keymaps because this plugin needs to start with debug run
            local godap = require("go.dap")
            utils.keymap_set("n", "<leader>dc", function()
                if require("dap").session() == nil then
                    godap.run()
                else
                    godap.continue()
                end
            end, { desc = "Continue" })
            utils.keymap_set("n", "<leader>dR", godap.run, { desc = "Debug" })
            utils.keymap_set("n", "<leader>ds", godap.stop, { desc = "Stop" })
        end,
        ft = { "go", "gomod" },
        version = utils.map_version_rule({
            [">=0.10.0"] = utils.nil_val,
            ["<0.10.0"] = "v0.9.0",
        }),
    },
    -- Fancy todo highlighting
    {
        "https://github.com/folke/todo-comments.nvim",
        dependencies = {
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
        opts = {
            signs = false,
            keywords = {
                FIX = {
                    icon = "🩹",
                },
                TODO = {
                    icon = require("icons").diagnostic_signs.Pencil,
                },
                HACK = {
                    icon = "🙈",
                },
                PERF = {
                    icon = "🚀",
                },
                NOTE = {
                    icon = "📓",
                },
                WARNING = {
                    icon = require("icons").diagnostic_signs.Warn,
                },
            },
        },
        version = "1.x.x",
    },

    -- Fancy notifications
    {
        "https://github.com/rcarriga/nvim-notify",
        version = utils.map_version_rule({
            [">=0.10.0"] = "3.x.x",
            ["<0.10.0"] = "3.13.5",
        }),
        config = function()
            require("plugins.notify")
        end,
    },

    {
        "https://github.com/stevearc/dressing.nvim",
        branch = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            ["<0.8.0"] = "nvim-0.7",
        }),
        config = {
            select = {
                -- backend = { "builtin" },
                fzf_lua = {
                    winopts = {
                        height = 0.5,
                        width = 0.5,
                    },
                },
            },
        },
    },

    { import = "lazy_specs.obsidian" },

    -- Work things
    -- Sourcegraph
    {
        "https://github.com/sourcegraph/sg.nvim",
        build = "nvim -l build/init.lua",
        dependencies = {
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
        opts = {
            enable_cody = false,
            -- Empty attach because I dont want to use default keymaps. Maybe I'll remap something later.
            on_attach = function() end,
        },
        cmd = {
            "SourcegraphBuild",
            "SourcegraphDownloadBinaries",
            "SourcegraphInfo",
            "SourcegraphLink",
            "SourcegraphLogin",
            "SourcegraphSearch",
        },
        enabled = vim.g.install_sourcegraph,
    },

    { import = "lazy_specs.llm_assist" },
}
