-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        -- Colorschemes
        {
            "https://github.com/vim-scripts/wombat256.vim",
        },
        {
            "https://github.com/ViViDboarder/wombat.nvim",
            dependencies = {
                {
                    "https://github.com/rktjmp/lush.nvim",
                    tag = utils.map_version_rule({
                        [">=0.7.0"] = utils.nil_val,
                        [">=0.5.0"] = "v1.0.1",
                    }),
                },
            },
            lazy = false,
        },
        {
            "https://github.com/ViViDboarder/wombuddy.nvim",
            dependencies = { { "https://github.com/tjdevries/colorbuddy.vim" } },
        },
        {
            "https://github.com/ishan9299/nvim-solarized-lua",
            commit = utils.map_version_rule({
                [">=0.7.0"] = utils.nil_val,
                ["<0.7.0"] = "faba49b",
            }),
        },
        {
            "https://github.com/folke/tokyonight.nvim",
            build = 'fish -c \'echo "set --path --prepend fish_themes_path "(pwd)"/extras" > ~/.config/fish/conf.d/tokyonight.fish\' || true', -- luacheck: no max line length
        },
        priority = 1000,
    },
    -- Some helpers
    -- Auto and ends to some ifs and dos
    { "https://github.com/tpope/vim-endwise" },

    -- Unix commands from vim? Yup!
    { "https://github.com/tpope/vim-eunuch" },

    -- Adds repeats for custom motions
    { "https://github.com/tpope/vim-repeat" },

    -- Readline shortcuts
    { "https://github.com/tpope/vim-rsi" },

    -- Surround motions
    { "https://github.com/tpope/vim-surround" },

    -- Better netrw
    { "https://github.com/tpope/vim-vinegar" },

    -- Easier jumping to lines
    { "https://github.com/vim-scripts/file-line" },

    -- Auto ctags generation
    { "https://github.com/ludovicchabant/vim-gutentags" },
    -- Make it easier to discover some of my keymaps
    {
        "https://github.com/folke/which-key.nvim",
        opts = {
            -- Ignore warnings about config. Turn these on when switching major versions
            notify = false,
            icons = {
                mappings = require("icons").nerd_font,
            },
        },
        version = utils.map_version_rule({
            [">=0.9.4"] = "3.x.x",
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
    -- Better commenting
    {
        "https://github.com/tomtom/tcomment_vim",
        keys = {
            { "//", ":TComment<CR>", desc = "Toggle comment" },
            { "//", ":TCommentBlock<CR>", mode = "v", desc = "Toggle comment" },
        },
    },
    -- Allow wrapping and joining of arguments across multiple lines
    {
        "https://github.com/FooSoft/vim-argwrap",
        keys = {
            { "<Leader>a", "<cmd>ArgWrap<CR>", desc = "Wrap or unwrap arguments" },
        },
    },
    -- Adds git operations to vim
    {
        "https://github.com/tpope/vim-fugitive",
        tag = utils.map_version_rule({
            [">=0.9.2"] = utils.nil_val,
            -- HACK: Pinning to avoid neovim bug https://github.com/neovim/neovim/issues/10121
            -- when used in status line.
            ["<0.9.2"] = "v3.6",
        }),
        keys = {
            { "gb", "<cmd>Git blame<CR>", desc = "Git blame" },
            { "gc", "<cmd>Git commit<CR>", desc = "Git commit" },
            { "gd", "<cmd>Git diff<CR>", desc = "Git diff" },
            { "gs", "<cmd>Git<CR>", desc = "Git status" },
            { "gw", "<cmd>Git write<CR>", desc = "Git write" },
        },
        cmd = { "Git" },
    },
    -- Quick toggling of Location and Quickfix lists
    {
        "https://github.com/milkypostman/vim-togglelist",
        keys = {
            { "<F6>", ":call ToggleQuickfixList()<CR>", desc = "Toggle quickfix" },
            { "<F7>", ":call ToggleLocationList()<CR>", desc = "Toggle location list" },
        },
    },

    -- Find text everywhere!
    {
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

            require("utils").keymap_set({ "n", "x" }, "gs", "<plug>(GrepperOperator)", {
                silent = true,
                noremap = false,
                desc = "Grepper",
            })

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
    },

    -- Highlight inline colors
    {
        "https://github.com/norcalli/nvim-colorizer.lua",
        config = true,
        cmd = { "ColorizerToggle" },
    },

    -- Custom status line
    {
        "https://github.com/nvim-lualine/lualine.nvim",
        config = function()
            require("plugins.lualine").config_lualine()
        end,
        dependencies = {
            {
                "https://github.com/SmiteshP/nvim-navic",
                dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
            },
        },
        event = "VeryLazy",
    },

    -- On Mac, update colors when dark mode changes
    {
        "https://github.com/cormacrelf/dark-notify",
        enabled = vim.g.is_mac,
        -- Download latest release on install
        build = "curl -s https://api.github.com/repos/cormacrelf/dark-notify/releases/latest | jq '.assets[].browser_download_url' | xargs curl -Ls | tar xz -C ~/.local/bin/", -- luacheck: no max line length
        config = function()
            require("plugins.darknotify")
        end,
        dependencies = { { "https://github.com/nvim-lualine/lualine.nvim" } },
        event = "VeryLazy",
    },

    -- Custom start screen
    {
        "https://github.com/mhinz/vim-startify",
        config = function()
            require("utils").require_with_local("plugins.startify")
        end,
    },

    -- LSP

    -- Configure language servers
    {
        "https://github.com/neovim/nvim-lspconfig",
        version = utils.map_version_rule({
            [">=0.8.0"] = "v0.1.*",
            [">=0.7.0"] = "v0.1.7",
            [">=0.6.1"] = "v0.1.2",
            [">=0.6.0"] = "v0.1.0",
        }),
    },

    -- Debug adapter protocol
    {
        "https://github.com/mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            local dap_mapping = utils.curry_keymap("n", "<leader>d", {
                group_desc = "Debugging",
                silent = true,
                noremap = true,
            })
            dap_mapping("d", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            dap_mapping("b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            dap_mapping("p", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

            dap_mapping("c", dap.continue, { desc = "Continue" })
            dap_mapping("C", dap.run_to_cursor, { desc = "Run to cursor" })
            dap_mapping("s", dap.stop, { desc = "Stop" })
            dap_mapping("n", dap.step_over, { desc = "Step over" })
            dap_mapping("i", dap.step_into, { desc = "Step into" })
            dap_mapping("O", dap.step_out, { desc = "Step out" })

            -- dap_mapping("h", dap.toggle_hover, { desc = "Toggle hover" })
            dap_mapping("D", dap.disconnect, { desc = "Disconnect" })
            -- dap_mapping("r", dap.repl.open, { desc = "Open REPL" })
            -- dap_mapping("R", dap.repl.run_last, { desc = "Run last" })

            local icons = require("icons")

            -- Set dap signs
            vim.fn.sign_define(
                "DapBreakpoint",
                { text = icons.debug_icons.breakpoint, texthl = "", linehl = "", numhl = "" }
            )

            vim.fn.sign_define(
                "DapLogPoint",
                { text = icons.debug_icons.log_point, texthl = "", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = icons.debug_icons.conditional_breakpoint, texthl = "", linehl = "", numhl = "" }
            )
            vim.fn.sign_define("DapStopped", { text = icons.debug_icons.current, texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointRejected",
                { text = icons.debug_icons.breakpoint_rejected, texthl = "", linehl = "", numhl = "" }
            )
        end,
        lazy = true,
    },
    {
        "https://github.com/rcarriga/nvim-dap-ui",
        dependencies = {
            { "https://github.com/mfussenegger/nvim-dap" },
            { "nvim-neotest/nvim-nio" },
        },
        lazy = true,
        config = function()
            require("dapui").setup({
                icons = {
                    expanded = "-",
                    collapsed = "+",
                    current_frame = ">",
                },
                controls = {
                    icons = require("icons").debug_control_icons,
                },
            })
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },

    {
        "https://github.com/mfussenegger/nvim-dap-python",
        dependencies = {
            { "https://github.com/rcarriga/nvim-dap-ui" },
            { "https://github.com/mfussenegger/nvim-dap" },
        },
        config = function()
            -- This is where pipx is installing debugpy via ./install-helpers.py
            -- Could maybe detect by doing a which debugpy and then reading the interpreter
            -- from the shebang line.
            require("dap-python").setup("~/.local/pipx/venvs/debugpy/bin/python3")
        end,
        ft = { "python" },
    },

    -- Install language servers
    {
        "https://github.com/williamboman/mason.nvim",
        dependencies = {
            { "https://github.com/neovim/nvim-lspconfig" },
            { "https://github.com/williamboman/mason-lspconfig.nvim" },
        },
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonLog",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonUpdate",
        },
    },

    -- Lua dev for vim
    {
        "https://github.com/folke/neodev.nvim",
        dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
        ft = { "lua" },
        -- Disable for nvim 0.10 because there is lazydev
        enabled = vim.fn.has("nvim-0.10") ~= 1,
    },
    {
        "https://github.com/folke/lazydev.nvim",
        dependencies = { { "https://github.com/neovim/nvim-lspconfig" } },
        ft = "lua",
        opts = {},
        enabled = vim.fn.has("nvim-0.10") == 1,
    },

    -- Rust analyzer
    {
        "https://github.com/mrcjkb/rustaceanvim",
        version = "^5",
        -- Already loads on ft
        lazy = false,
        ft = { "rust" },
        init = function()
            local lsp = require("plugins.lsp")
            vim.g.rustaceanvim = {
                server = {
                    capabilities = lsp.merged_capabilities(),
                    on_attach = lsp.get_default_attach(),
                },
            }
        end,
        enabled = vim.fn.has("nvim-0.10") == 1,
    },

    -- Better display of lsp diagnostics
    {
        "https://github.com/folke/trouble.nvim",
        version = utils.map_version_rule({
            [">=0.7.2"] = "2.x.x",
            ["<0.7.2"] = "1.x.x",
        }),
    },

    -- Incremental lsp rename view
    {
        "https://github.com/smjonas/inc-rename.nvim",
        opts = {
            input_buffer_type = "dressing",
        },
        lazy = true,
    },

    -- Generic linter/formatters in diagnostics API
    {
        "https://github.com/nvimtools/none-ls.nvim",
        -- This is lazy and configured after lsps loaded in plugins/lsp.lua
        lazy = true,
        branch = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = "0.7-compat",
            ["<0.7.0"] = utils.nil_val, -- use pinned commit
        }),
        commit = utils.map_version_rule({
            [">=0.8.0"] = utils.nil_val,
            [">=0.7.0"] = utils.nil_val, -- Use pinned branch
            [">=0.6.0"] = "4b403d2d724f48150ded41189ae4866492a8158b",
        }),
        dependencies = {
            { "https://github.com/nvimtools/none-ls-extras.nvim" },
            { "https://github.com/nvim-lua/plenary.nvim" },
            { "https://github.com/neovim/nvim-lspconfig" },
        },
    },

    -- Writing
    -- abolish/pencil
    {
        "https://github.com/preservim/vim-pencil",
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
            [">=0.9.2"] = utils.nil_val,
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

    {
        -- Completion
        {
            "https://github.com/L3MON4D3/LuaSnip",
            version = "2.x.x",
            event = "InsertEnter *",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
            dependencies = {
                { "https://github.com/rafamadriz/friendly-snippets" },
            },
        },
        {
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            commit = utils.map_version_rule({
                [">=0.7.0"] = utils.nil_val,
                ["<0.7.0"] = "3cf38d9c957e95c397b66f91967758b31be4abe6",
            }),
            dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
            event = "InsertEnter *",
        },
        {
            "https://github.com/hrsh7th/cmp-buffer",
            dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
            event = "InsertEnter *",
        },
        {
            "https://github.com/f3fora/cmp-spell",
            dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
            event = "InsertEnter *",
        },
        {
            "https://github.com/saadparwaiz1/cmp_luasnip",
            commit = utils.map_version_rule({
                [">0.7.0"] = utils.nil_val,
                [">=0.5.0"] = "b10829736542e7cc9291e60bab134df1273165c9",
            }),
            dependencies = {
                { "https://github.com/hrsh7th/nvim-cmp" },
                { "https://github.com/L3MON4D3/LuaSnip" },
            },
            event = "InsertEnter *",
        },

        {
            "https://github.com/hrsh7th/nvim-cmp",
            config = function()
                require("plugins.completion").config_cmp()
            end,
            commit = utils.map_version_rule({
                [">=0.7.0"] = utils.nil_val,
                [">=0.5.0"] = "bba6fb67fdafc0af7c5454058dfbabc2182741f4",
            }),
            event = "InsertEnter *",
        },

        -- Add snippets
        event = "InsertEnter *",
    },

    {
        "https://github.com/ray-x/lsp_signature.nvim",
        lazy = true,
        event = "VeryLazy",
        opts = {
            extra_trigger_chars = { "(", "," },
            auto_close_after = nil,
            -- Toggle these to use hint only
            floating_window = true,
            hint_enable = false,
        },
    },

    -- Fuzzy Finder
    {
        "https://github.com/nvim-telescope/telescope.nvim",
        dependencies = {
            { "https://github.com/nvim-lua/plenary.nvim" },
            { "https://github.com/nvim-telescope/telescope-file-browser.nvim" },
        },
        version = "0.1.x",
        config = function()
            require("plugins.telescope")
        end,
        lazy = true,
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
                icons = false,
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
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        version = utils.map_version_rule({
            [">=0.10.0"] = utils.nil_val,
            ["<0.10.0"] = "v0.9.0",
        }),
        enabled = vim.fn.has("nvim-0.9") == 1,
    },
    {
        "https://github.com/sheerun/vim-polyglot",
        config = function()
            local gid = vim.api.nvim_create_augroup("polyglot_fts", { clear = true })
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = { "*/playbooks/*.yml", "*/playbooks/*.yaml" },
                command = "set filetype=yaml.ansible",
                group = gid,
            })
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = { "go.mod", "go.sum" },
                command = "set filetype=gomod",
                group = gid,
            })
        end,
    },

    -- Debuging nvim config
    {
        "https://github.com/tweekmonster/startuptime.vim",
        cmd = { "StartupTime" },
    },

    -- Fancy todo highlighting
    {
        "https://github.com/folke/todo-comments.nvim",
        dependencies = {
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
        config = function()
            require("plugins.todo")
        end,
        version = "1.x.x",
    },

    -- Fancy notifications
    {
        "https://github.com/rcarriga/nvim-notify",
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
        config = true,
    },

    -- Obsidian notes
    -- This loads an Obsidian plugin for better vault interraction as well as auto pulls
    -- and commits to my vault git repo. On iOS devices, I use Working Copy to sync the
    -- repo and use Shortcuts to automate pulling on open and auto committing and pushing
    -- after closing Obsidian.
    {
        "https://github.com/epwalsh/obsidian.nvim",
        dependencies = {
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
        version = "3.x.x",
        opts = {
            workspaces = {
                { name = "personal", path = "~/Documents/Obsidian" },
            },
            ui = {
                checkboxes = {
                    [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                    ["x"] = { char = "✔", hl_group = "ObsidianDone" },
                },
                external_link_icon = { char = "🔗", hl_group = "ObsidianExtLinkIcon" },
            },
        },
        config = function(opts)
            -- Setup obsidian
            require("obsidian").setup(opts)

            -- Set up auto pull and commit
            local group_id = vim.api.nvim_create_augroup("obsidian-git", { clear = true })

            -- Create auto pull on open
            local autopull = function()
                local Job = require("plenary.job")
                vim.notify("Pulling Obsidian notes", vim.log.levels.INFO, { title = "Obsidian" })
                Job:new({
                    command = "git",
                    args = { "pull" },
                    on_exit = function(j, return_val)
                        if return_val == 0 then
                            vim.notify("Pulled Obsidian notes", vim.log.levels.INFO, { title = "Obsidian" })
                        else
                            vim.notify(
                                "Failed to pull Obsidian notes. " .. vim.inspect(j:result()),
                                vim.log.levels.ERROR,
                                { title = "Obsidian" }
                            )
                        end
                    end,
                }):start()
            end

            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = vim.fn.expand("~") .. "/Documents/Obsidian/**",
                callback = autopull,
                group = group_id,
            })

            local Job = require("plenary.job")

            -- Create autocommit on save
            local auto_add = function(next_func)
                return function(ev)
                    Job:new({
                        command = "git",
                        args = { "add", ev.file },
                        on_exit = function(add_j, add_return_val)
                            if add_return_val ~= 0 then
                                vim.notify(
                                    "Failed to add file to git. " .. vim.inspect(add_j:result()),
                                    vim.log.levels.ERROR,
                                    { title = "Obsidian" }
                                )
                                return
                            end

                            if next_func then
                                next_func()
                            end
                        end,
                    }):start()
                end
            end

            local auto_commit = function(next_func)
                return function()
                    local date_string = os.date("%Y-%m-%d %H:%M:%S")
                    Job
                        :new({
                            command = "git",
                            args = { "commit", "-m", "Auto commit: " .. date_string },
                            on_exit = function(commit_j, commit_return_val)
                                if commit_return_val ~= 0 then
                                    vim.notify(
                                        "Failed to commit file to git. " .. vim.inspect(commit_j:result()),
                                        vim.log.levels.ERROR,
                                        { title = "Obsidian" }
                                    )
                                    return
                                end
                                if next_func then
                                    next_func()
                                end
                            end,
                        })
                        :start()
                end
            end

            local auto_push = function(next_func)
                return function()
                    Job
                        :new({
                            command = "git",
                            args = { "push" },
                            on_exit = function(push_j, push_return_val)
                                if push_return_val ~= 0 then
                                    vim.notify(
                                        "Failed to push Obsidian notes. " .. vim.inspect(push_j:result()),
                                        vim.log.levels.ERROR,
                                        { title = "Obsidian" }
                                    )
                                end

                                if next_func then
                                    next_func()
                                end
                            end,
                        })
                        :start()
                end
            end

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                pattern = vim.fn.expand("~") .. "/Documents/Obsidian/**",
                callback = auto_add(auto_commit(auto_push())),
                group = group_id,
            })
        end,
        event = {
            "BufRead " .. vim.fn.expand("~") .. "/Documents/Obsidian/**",
            "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Obsidian/**",
        },
    },

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

    {
        "https://github.com/github/copilot.vim",
        enabled = vim.g.install_copilot,
        version = "1.x.x",
        config = function()
            require("plugins.copilot")
        end,
        dependencies = {
            { "https://github.com/tpope/vim-rsi" },
        },
    },

    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        enabled = vim.g.install_copilot,
        version = "3.x.x",
        build = "make tiktoken",
        dependencies = {
            { "https://github.com/github/copilot.vim" },
            { "https://github.com/nvim-lua/plenary.nvim" },
        },
        config = function()
            require("plugins.copilotchat").setup()
        end,
        keys = {
            { "<leader>cc", ":echo 'Lazy load copilot chat'<cr>", desc = "Load copilot chat" },
        },
        cmd = {
            "CopilotChat",
            "CopilotChatOpen",
            "CopilotChatToggle",
            "CopilotChatModels",
            "CopilotChatExplain",
            "CopilotChatReview",
            "CopilotChatOptimize",
            "CopilotChatDocs",
            "CopilotChatTests",
            "CopilotChatFixDiagnostic",
            "CopilotChatCommit",
            "CopilotChatCommitStaged",
        },
        lazy = true,
    },
}
