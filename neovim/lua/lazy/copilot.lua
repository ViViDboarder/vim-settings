-- #selene: allow(mixed_table)

local specs = {}

-- We don't need any of these things if we're not using Copilot or LocalLM
if not vim.g.install_copilot and not vim.g.use_locallm then
    return specs
end

-- Helper function to create local model adapters for LM Studio
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
        opts = {
            adapters = {
                lm_qwen_coder = lm_studio("qwen2.5-coder-7b-instruct"),
                deepseek_coder = lm_studio("deepseek-coder-v2-lite-instruct"),
                lm_starcoder2 = lm_studio("starcoder2-7b"),
            },
            strategies = {
                chat = {
                    adapter = vim.g.use_locallm and "lm_qwen_coder" or "copilot",
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
                    adapter = vim.g.use_locallm and "lm_qwen_coder" or "copilot",
                },
                cmd = {
                    adapter = vim.g.use_locallm and "lm_qwen_coder" or "copilot",
                },
            },
            log_level = "DEBUG",
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

if vim.g.use_locallm then
    -- For local llms, we use llm.nvim sinc eit will talk to LM Studio
    table.insert(specs, {
        "https://github.com/huggingface/llm.nvim",
        opts = {
            backend = "openai",
            url = "http://localhost:1234",
            model = "starcoder2-7b",
            -- model = "qwen2.5-coder-7b-instruct",
            -- model = "deepseek-coder-v2-lite-instruct",
            debounce_ms = 500,
            accept_keymap = "<C-F>",
            dismiss_keymap = "<C-D>",
        },
    })
elseif vim.g.install_copilot then
    -- Otherwise we're using copilot.vim
    table.insert(specs, {
        "https://github.com/github/copilot.vim",
        enabled = vim.g.install_copilot,
        version = "1.43",
        config = function()
            -- Replace keymap for copilot to accept with <C-F> and <Right>, similar to fish shell
            local utils = require("utils")

            local function copilot_accept()
                local suggest = vim.fn["copilot#GetDisplayedSuggestion"]()
                if next(suggest.item) ~= nil then
                    return vim.fn["copilot#Accept"]("\\<CR>")
                else
                    return utils.t("<Right>")
                end
            end

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
