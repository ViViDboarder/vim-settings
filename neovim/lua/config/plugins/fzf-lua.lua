local M = {}

function M.setup(_, opts)
    -- Override setup and add some keymaps
    if opts == nil then
        opts = {
            ui_select = true,
        }
    end

    local utils = require("utils")
    local fzf = require("fzf-lua")

    fzf.setup(opts)

    utils.keymap_set("n", "<C-t>", fzf.files, { desc = "Find files" })
    utils.keymap_set("n", "<leader>b", fzf.buffers, { desc = "Find buffers" })
    utils.keymap_set("n", "<leader>t", fzf.btags, { desc = "Find buffer tags" })
    utils.keymap_set("n", "<leader>*", fzf.grep_cword, { desc = "Find string under cursor" })
    utils.keymap_set("n", "<leader>s", fzf.spell_suggest, { desc = "Spell check" })

    -- Finder namspaced keymaps prefixed by <leader>f
    -- Some of these are overwritten by LSP specific keymaps when an LSP attaches
    local finder_keymap = utils.curry_keymap("n", "<leader>f", { group_desc = "Finder" })
    finder_keymap("a", fzf.builtin, { desc = "Find finders" })
    finder_keymap("b", fzf.buffers, { desc = "Find buffers" })
    finder_keymap("f", fzf.files, { desc = "Find file" })
    finder_keymap("g", fzf.live_grep, { desc = "Live grep" })
    finder_keymap("h", fzf.helptags, { desc = "Find help tags" })
    finder_keymap("l", fzf.resume, { desc = "Resume finding" })
    finder_keymap("t", fzf.btags, { desc = "Find buffer tags" })
    finder_keymap("T", fzf.tags, { desc = "Find tags" })

    -- Completions
    utils.keymap_set("i", "<C-x><C-f>", fzf.complete_path, { desc = "Completion: paths" })
end

return M
