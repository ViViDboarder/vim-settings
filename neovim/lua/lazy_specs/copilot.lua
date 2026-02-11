-- #selene: allow(mixed_table)
--
-- Supported llm_providers = copilot | ollama | claude_code | anthropic

-- Relies on the following variable:
--      vim.g.llm_provider set to "github" for GitHub Copilot, "ollama" for local LLM (Ollama), or nil/undefined for none
--      vim.g.llm_completion_provider: provider name for llm completions only. Defaults to vim.g.llm_provider
--      vim.g.llm_ollama_url to change the URL for the local llm
--      vim.g.llm_anthropic_url: url to use for anthropic API
--      vim.g.llm_chat_model to change the chat model used by the local llm
--      vim.g.llm_completion_model to change the completion model used by the local llm, defaults to llm_chat_model

local utils = require("utils")
local specs = {}

-- Only proceed if a provider is set
if not vim.g.llm_provider or vim.g.llm_provider == "none" then
    return specs
end

-- Helper function to create local model adapters for Ollama
local function ollama_chat_adapter(model, num_ctx)
    if model == nil then
        model = "qwen3-coder:30b"
    end
    if num_ctx == nil then
        num_ctx = 8192
    end

    return function()
        return require("codecompanion.adapters").extend("ollama", {
            env = {
                url = vim.g.llm_ollama_url or "http://localhost:11434",
            },
            opts = {
                stream = true,
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

--- Helper function to return an anthropic adapter for CodeCompanion
local function anthropic_chat_adapter(model)
    if model == nil then
        model = vim.g.llm_chat_model or "opus"
    end

    local opts = {
        -- has_token_efficient_tools = false,
        env = {
            api_key = "ANTHROPIC_API_KEY",
        },
        schema = {
            model = {
                default = model,
            },
        },
    }
    if vim.g.llm_anthropic_url ~= nil then
        opts.url = vim.g.llm_anthropic_url
    end

    return function()
        return require("codecompanion.adapters").extend("anthropic", opts)
    end
end

-- Helper function to return a claude code adapter with a provided model
local function claude_code_adapter(model)
    if model == nil then
        model = vim.g.llm_chat_model or "opus"
    end

    return function()
        return require("codecompanion.adapters").extend("claude_code", {
            defaults = {
                model = model,
            },
        })
    end
end

--- Helper that returns the adapter for CodeCompanion to use
---@return string|table the name of the LLM adapter to use
local function codecompanion_adapter()
    if vim.g.llm_provider == "github" then
        return "copilot"
    elseif vim.g.llm_provider == "claude_code" then
        return "claude_code"
    elseif vim.g.llm_provider == "anthropic" or vim.g.llm_provider == "claude" then
        return "anthropic"
    elseif vim.g.llm_provider == "ollama" then
        return "ollama"
    end

    vim.notify("Unknown llm_provider: " .. tostring(vim.g.llm_provider), vim.log.levels.WARN)

    return "unknown"
end

--- Helper that returns provider name for Minuet
---@return string the name of the preset
local function minuet_preset()
    local provider = vim.g.llm_completion_provider or vim.g.llm_provider

    if provider == "github" then
        -- This should not actually be used since we don't load minute for github
        return "unknown"
    elseif provider == "claude_code" then
        -- Might not be strictly compatible, but worth a shot
        return "claude"
    elseif provider == "anthropic" or provider == "claude" then
        return "claude"
    elseif provider == "ollama" then
        return "ollama"
    end

    vim.notify("Unknown llm_provider: " .. tostring(provider), vim.log.levels.WARN)

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
        "https://github.com/olimorris/codecompanion.nvim",
        version = utils.map_version_rule({
            [">=0.11.0"] = "^18",
            ["<0.11.0"] = "^16",
        }),
        opts = {
            -- TODO: Refactor to a function and dynamically set more values based on copilot or not
            -- so I can use non-default copilot models as well in the strategy config.
            adapters = {
                acp = {
                    claude_code = claude_code_adapter(vim.g.llm_chat_model),
                    claude_code_opus = claude_code_adapter("opus-latest"),
                    claude_code_sonnet = claude_code_adapter("sonnet-latest"),
                    claude_code_haiku = claude_code_adapter("haiku-latest"),
                    opts = {
                        show_presets = false,
                    },
                },
                http = {
                    ollama = ollama_chat_adapter(vim.g.llm_chat_model),
                    ollama_qwen2_5_coder = ollama_chat_adapter("qwen2.5-coder:7b", 16384),
                    ollama_qwen3_coder = ollama_chat_adapter("qwen3-coder:30b", 100000),
                    ollama_gptoss = ollama_chat_adapter("gpt-oss:20b", 100000),
                    anthropic = anthropic_chat_adapter(vim.g.llm_chat_model),
                    opts = {
                        show_presets = false,
                    },
                },
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

-- For local llms, we use minuet-ai.nvim since it will talk to Ollama
table.insert(specs, {
    -- "https://github.com/milanglacier/minuet-ai.nvim",
    "https://github.com/ViViDboarder/minuet-ai.nvim",
    branch = "initial-preset",
    opts = {
        virtualtext = {
            keymap = {
                accept = "<A-A>",
                accept_line = "<C-F>",
                dismiss = "<C-C>",
            },
        },
        initial_preset = minuet_preset(),
        presets = {
            claude = {
                provider = "claude",
                n_completions = 1,
                context_window = 20000,
                provider_options = {
                    claude = {
                        model = vim.g.llm_completion_model or vim.g.llm_chat_model,
                        end_point = vim.g.llm_anthropic_url,
                    },
                },
            },
            ollama = {
                provider = "openai_fim_compatible",
                n_completions = 1,
                context_window = 4096,
                provider_options = {
                    openai_fim_compatible = {
                        api_key = "TERM",
                        name = "Ollama",
                        end_point = (vim.g.llm_ollama_url or "http://localhost:11434") .. "/v1/completions",
                        model = vim.g.llm_completion_model or vim.g.llm_chat_model or "qwen2.5-coder:7b",
                    },
                },
            },
        },
    },
    config = function(_, opts)
        require("minuet").setup(opts)

        -- Create autocmd to disable completion for certain filetypes that may contain sensitive information
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            -- pattern = { ".env*", "*secret*", "*API_KEY*", "*TOKEN*" },
            callback = function(args)
                if
                    args.file:match("%.env")
                    or args.file:match("secret")
                    or args.file:match("API_KEY")
                    or args.file:match("TOKEN")
                then
                    vim.b.minuet_virtual_text_auto_trigger = false
                else
                    vim.b.minuet_virtual_text_auto_trigger = true
                end
            end,
            group = vim.api.nvim_create_augroup("MinuetDisable", {
                clear = true,
            }),
        })
    end,
    dependencies = {
        -- To avoid keymapping conflicts with Ctrl+F, load vim-rsi first
        "https://github.com/tpope/vim-rsi",
        "https://github.com/nvim-lua/plenary.nvim",
    },
    cond = vim.g.llm_provider ~= "github",
    -- TODO: remove condition when nvim min is 0.10
    enabled = vim.fn.has("nvim-0.10") == 1,
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
