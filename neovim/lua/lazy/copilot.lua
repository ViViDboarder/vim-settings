-- #selene: allow(mixed_table)

return {
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
