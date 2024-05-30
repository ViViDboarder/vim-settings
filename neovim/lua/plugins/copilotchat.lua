local M = {}

function M.setup()
    require("CopilotChat").setup({
        mappings = {
            complete = {
                insert = "",
            },
        },
        prompts = {
            Explain = {
                prompt = "/COPILOT_EXPLAIN Write a concise explanation for the active selection as paragraphs of text.",
            },
        },
    })

    local utils = require("utils")
    if utils.try_require("telescope") ~= nil then
        local cc_keymap = utils.curry_keymap("n", "<leader>cc", { group_desc = "CopilotChat" })

        cc_keymap("h", function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end, { desc = "CopilotChat - Help" })

        cc_keymap("p", function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end, { desc = "CopilotChat - Prompt" })

        cc_keymap("c", function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= nil and input ~= "" then
                require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
        end, { desc = "CopilotChat - Quick Chat" })
    end
end

return M
