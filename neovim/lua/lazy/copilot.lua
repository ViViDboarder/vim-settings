-- #selene: allow(mixed_table)

local function lm_studio(model)
    return function()
        return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
                url = "http://localhost:1234",
            },
            schema = {
                model = {
                    default = model,
                },
            },
        })
    end
end

return {
    {
        -- CodeCompanion tool will be lazy loaded
        "https://github.com/Davidyz/VectorCode",
        version = "*",
        dependencies = { "https://github.com/nvim-lua/plenary.nvim" },
        lazy = true,
    },
    {
        -- Formatting chat buffers for CodeCompanion can be lazy loaded
        "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        version = "*",
        ft = { "codecompanion" },
        opts = {
            render_modes = true, -- Render in ALL modes
            sign = {
                enabled = false, -- Turn off in the status column
            },
        },
    },
    {
        "https://github.com/huggingface/llm.nvim",
        opts = {
            backend = "openai",
            url = "http://localhost:1234",
            model = "starcoder2-7b",
            -- model = "qwen2.5-coder-7b-instruct",
            -- model = "deepseek-coder-v2-lite-instruct",
        },
    },
    {
        "olimorris/codecompanion.nvim",
        opts = {
            adapters = {
                lm_qwen_coder = lm_studio("qwen2.5-coder-7b-instruct"),
                deepseek_coder = lm_studio("deepseek-coder-v2-lite-instruct"),
                lm_starcoder2 = lm_studio("starcoder2-7b"),
            },
            strategies = {
                chat = {
                    adapter = "lm_qwen_coder",
                    tools = {
                        vectorcode = {
                            description = "Run VectorCode to retrieve the project context.",
                            callback = function()
                                return require("vectorcode.integrations").codecompanion.chat.make_tool()
                            end,
                        },
                    },
                },
                inline = {
                    adapter = "lm_qwen_coder",
                },
                cmd = {
                    adapter = "lm_qwen_coder",
                },
            },
            log_level = "DEBUG",
        },
        dependencies = {
            "https://github.com/nvim-lua/plenary.nvim",
            "https://github.com/nvim-treesitter/nvim-treesitter",
            {
                "https://github.com/saghen/blink.cmp",
                opts = {
                    sources = {
                        default = { "codecompanion" },
                    },
                },
            },
        },
    },
    {
        "https://github.com/github/copilot.vim",
        enabled = vim.g.install_copilot,
        version = "1.43",
        config = function()
            require("plugins.copilot")
        end,
        dependencies = {
            -- To avoid keymapping conflicts with Ctrl+F, load vim-rsi first
            { "https://github.com/tpope/vim-rsi" },
        },
    },

    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        enabled = vim.g.install_copilot,
        version = "^3",
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
