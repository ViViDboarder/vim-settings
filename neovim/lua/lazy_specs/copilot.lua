-- #selene: allow(mixed_table)

-- Relies on the following variable:
--      vim.g.llm_provider: "github" for GitHub Copilot, "ollama" for local LLM (Ollama), or nil/undefined for none
--      vim.g.local_llm_url to change the URL for the local llm
--      vim.g.local_llm_chat_model to change the chat model used by the local llm
--      vim.g.local_llm_completion_model to change the completion model used by the local llm

local utils = require("utils")
local specs = {}

-- Only proceed if a provider is set
if not vim.g.llm_provider or vim.g.llm_provider == "none" then
    return specs
end

-- Helper function to create local model adapters for Ollama
local function ollama(model, num_ctx)
    if num_ctx == nil then
        num_ctx = 8192
    end

    return function()
        return require("codecompanion.adapters").extend("ollama", {
            env = {
                url = vim.g.local_llm_url or "http://localhost:11434",
            },
            schema = {
                model = {
                    default = model,
                    num_ctx = { default = num_ctx },
                },
            },
        })
    end
end

--- Helper that returns the adapter for CodeCompanion to use
---@return string the name of the LLM adapter to use
local function codecompanion_adapter()
    if vim.g.llm_provider == "github" then
        return "copilot"
    elseif vim.g.llm_provider == "ollama" then
        if vim.g.local_llm_chat_model ~= nil then
            return "dynamic"
        end
        return "qwen3_coder"
    end

    vim.notify("Unknown llm_provider: " .. tostring(vim.g.llm_provider), vim.log.levels.WARN)

    return "unknown"
end

vim.list_extend(specs, {
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
        "olimorris/codecompanion.nvim",
        version = utils.map_version_rule({
            [">=0.11.0"] = "^17",
            ["<0.11.0"] = "^16",
        }),
        opts = {
            -- TODO: Refactor to a function and dynamically set more values based on copilot or not
            -- so I can use non-default copilot models as well in the strategy config.
            adapters = {
                qwen_coder = ollama("qwen2.5-coder:7b", 16384),
                starcoder2 = ollama("starcoder2:7b"),
                devstral = ollama("devstral:24b", 16384),
                qwen3 = ollama("qwen3:8b", 100000),
                qwen3_coder = ollama("qwen3-coder:30b", 100000),
                dynamic = ollama(vim.g.local_llm_chat_model),
            },
            strategies = {
                chat = {
                    adapter = codecompanion_adapter(),
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
                    adapter = codecompanion_adapter(),
                },
                cmd = {
                    adapter = codecompanion_adapter(),
                },
            },
        },
        dependencies = {
            "https://github.com/nvim-lua/plenary.nvim",
            "https://github.com/nvim-treesitter/nvim-treesitter",
        },
        cmd = {
            "CodeCompanion",
            "CodeCompanionActions",
            "CodeCompanionChat",
            "CodeCompanionCmd",
        },
    },
})

-- For local llms, we use llm.nvim sinc eit will talk to LM Studio
table.insert(specs, {
    -- TODO: Maybe get rid of this and use a local copilot proxy
    "https://github.com/ViViDboarder/llm.nvim",
    opts = {
        backend = "ollama",
        url = vim.g.local_llm_url or "http://localhost:11434",
        model = "starcoder2:7b",
        debounce_ms = 500,
        keymap = {
            modes = { "i" },
            accept = "<C-F>",
            dismiss = "<C-U>",
        },
    },
    dependencies = {
        -- To avoid keymapping conflicts with Ctrl+F, load vim-rsi first
        { "https://github.com/tpope/vim-rsi" },
    },
    cond = vim.g.llm_provider == "ollama",
})
table.insert(specs, {
    "https://github.com/github/copilot.vim",
    cond = vim.g.llm_provider == "github",
    version = "1.43",
    config = function()
        -- Replace keymap for copilot to accept with <C-F> and <Right>, similar to fish shell
        local function copilot_accept()
            local suggest = vim.fn["copilot#GetDisplayedSuggestion"]()
            if next(suggest.item) ~= nil then
                return vim.fn["copilot#Accept"]("\\<CR>")
            else
                return utils.t("<Right>")
            end
        end

        --[[
        -- Point to local copilot proxy if using ollama
        vim.g.copilot_proxy = "http://localhost:11435"
        vim.g.copilot_proxy_strict_ssl = false
        --]]

        vim.g.copilot_no_tab_map = false
        utils.keymap_set("i", "<C-F>", copilot_accept, { expr = true, replace_keycodes = false, noremap = true })
        utils.keymap_set("i", "<Right>", copilot_accept, { expr = true, replace_keycodes = false, noremap = true })

        -- Create autocmd to disable copilot for certain filetypes that may contain sensitive information
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = { ".env*", "*secret*", "*API_KEY*", "*TOKEN*" },
            command = "let b:copilot_enabled = 0",
            group = vim.api.nvim_create_augroup("CopilotDisable", {
                clear = true,
            }),
        })
    end,
    dependencies = {
        -- To avoid keymapping conflicts with Ctrl+F, load vim-rsi first
        { "https://github.com/tpope/vim-rsi" },
    },
})

return specs
