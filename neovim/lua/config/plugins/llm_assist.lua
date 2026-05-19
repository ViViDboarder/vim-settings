-- #selene: allow(mixed_table)
--
-- Supported llm_providers = copilot | ollama | open_webui | claude_code | anthropic

-- Relies on the following variable:
--      vim.g.llm_provider set to "github" for GitHub Copilot, "ollama" for local LLM (Ollama), or nil/undefined for none
--      vim.g.llm_completion_provider: provider name for llm completions only. Defaults to vim.g.llm_provider
--      vim.g.llm_ollama_url to change the URL for the local llm
--      vim.g.llm_open_webui_url change the url for an OpenAI compatible server
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

-- Helper function to create a local openai adapter
local function open_webui_chat_adapter(model)
    return function()
        return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
                url = vim.g.llm_open_webui_url or "https://chat.thefij.rocks/api",
                api_key = "OWUI_API_KEY",
            },
            schema = {
                model = {
                    default = model,
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

    return function()
        return require("codecompanion.adapters").extend("anthropic", {
            -- has_token_efficient_tools = false,
            env = {
                url = vim.g.llm_anthropic_url,
                api_key = "ANTHROPIC_API_KEY",
            },
            schema = {
                model = {
                    default = model,
                },
            },
        })
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
    elseif vim.g.llm_provider == "open_webui" then
        return "open_webui"
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
    elseif provider == "open_webui" then
        return "open_webui"
    end

    vim.notify("Unknown llm_provider: " .. tostring(provider), vim.log.levels.WARN)

    return "unknown"
end

local function minuet_config(config)
    local presets = {
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
        open_webui = {
            provider = "openai_fim_compatible",
            n_completions = 1,
            context_window = 4096,
            provider_options = {
                openai_fim_compatible = {
                    api_key = "OWUI_API_KEY",
                    name = "Open WebUI",
                    end_point = (vim.g.llm_open_webui_url or "https://chat.thefij.rocks") .. "/api/completions",
                    model = vim.g.llm_completion_model or vim.g.llm_chat_model or "qwen2.5-coder:7b",
                },
            },
        },
    }

    config = vim.tbl_extend("force", config, presets[minuet_preset()] or {})
    config.presets = presets

    return config
end

vim.list_extend(specs, {
    {
        -- Formatting chat buffers for CodeCompanion can be lazy loaded
        src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        version = vim.version.range("^8"),
        after = function()
            require("render-markdown").setup({
                render_modes = true, -- Render in ALL modes
                sign = {
                    enabled = false, -- Turn off in the status column
                },
                -- Only use this for codecompanion buffers
                file_types = { "codecompanion" },
            })
        end,
    },
    {
        src = "https://github.com/olimorris/codecompanion.nvim",
        version = vim.version.range("^19"),
        after = function()
            require("codecompanion").setup({
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
                        open_webui = open_webui_chat_adapter("unsloth/Qwen3.5-9B-GGUF:Q4_K_M"),
                        opts = {
                            show_presets = false,
                        },
                    },
                },
                strategies = {
                    chat = { adapter = codecompanion_adapter() },
                    inline = { adapter = codecompanion_adapter() },
                    cmd = { adapter = codecompanion_adapter() },
                },
            })
        end,
        dependencies = {
            "https://github.com/nvim-lua/plenary.nvim",
            "https://github.com/nvim-treesitter/nvim-treesitter",
        },
    },
})

-- For local llms, we use minuet-ai.nvim since it will talk to Ollama
if vim.g.llm_provider ~= "github" then
    table.insert(specs, {
        src = "https://github.com/milanglacier/minuet-ai.nvim",
        after = function()
            require("minuet").setup(minuet_config({
                before_cursor_filter_length = 10,
                virtualtext = {
                    keymap = {
                        accept = "<A-A>",
                        dismiss = "<C-C>",
                    },
                },
            }))

            -- Map accept line to <C-F> and <Right>
            -- Make sure vim-rsi is loaded so it doesn't overwrite this keymap
            if vim.fn.has("nvim-0.12.0") == 1 and vim.g.force_lazy ~= true then
                vim.cmd.packadd("vim-rsi")
            end
            local minuet_accept = function()
                local vt_action = require("minuet.virtualtext").action
                if vt_action.is_visible() then
                    vt_action.accept_line()
                    return
                else
                    return utils.t("<Right>")
                end
            end
            utils.keymap_set(
                "i",
                "<C-F>",
                minuet_accept,
                { desc = "minuet accept line", expr = true, replace_keycodes = false, noremap = true }
            )
            utils.keymap_set(
                "i",
                "<Right>",
                minuet_accept,
                { desc = "minuet accept line", expr = true, replace_keycodes = false, noremap = true }
            )

            -- Create autocmd to disable completion for certain filetypes that may contain sensitive information
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
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
    })
else
    table.insert(specs, {
        src = "https://github.com/github/copilot.vim",
        version = vim.version.range("1.43"),
        after = function()
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
end

return specs
