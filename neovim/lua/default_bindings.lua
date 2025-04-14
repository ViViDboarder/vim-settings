local utils = require("utils")

utils.keymap_set("n", "<C-L><C-L>", ":set wrap!<CR>", { desc = "Toggle line wrapping" })
utils.keymap_set("n", "<leader>lw", ":set wrap!<CR>", { desc = "Toggle line wrapping" })
utils.keymap_set("n", "<C-N><C-N>", ":set invnumber<CR>", { desc = "Toggle line numbers" })
utils.keymap_set("n", "<leader>ln", ":set invnumber<CR>", { desc = "Toggle line numbers" })
utils.keymap_set("n", "<leader>/", ":set hlsearch! hlsearch?<CR>", { desc = "Toggle search highlighting" })
utils.keymap_set("n", "<leader>cs", ":nohlsearch<CR>", { desc = "Clear search highlighting" })
utils.keymap_set("n", "<leader>ws", ":set list!<CR>", { desc = "Toggle whitespace characters" })

-- Save and quit typos
utils.keymap_set("c", "WQ<CR>", "wq<CR>", { desc = "Write and quit" })
utils.keymap_set("c", "Wq<CR>", "wq<CR>", { desc = "Write and quit" })
utils.keymap_set("c", "W<CR>", "w<CR>", { desc = "Write" })
utils.keymap_set("c", "Q<CR>", "q<CR>", { desc = "Quit" })
utils.keymap_set("c", "Q!<CR>", "q!<CR>", { desc = "Force quit" })
utils.keymap_set("c", "Qa<CR>", "qa<CR>", { desc = "Quit all" })
utils.keymap_set("c", "Qa!<CR>", "qa!<CR>", { desc = "Force quit all" })
utils.keymap_set("c", "QA<CR>", "qa<CR>", { desc = "Quit all" })
utils.keymap_set("c", "QA!<CR>", "qa!<CR>", { desc = "Force quit all" })
utils.keymap_set("c", "w;", "w", { desc = "Write" })
utils.keymap_set("c", "W;", "w", { desc = "Write" })
utils.keymap_set("c", "q;", "q", { desc = "Quit" })
utils.keymap_set("c", "Q;", "q", { desc = "Quit" })

-- Paste over
utils.keymap_set("v", "pp", "p", { desc = "Paste" })
utils.keymap_set("v", "po", '"_dP', { desc = "Paste over and keep clipboard" })

-- Buffer nav
utils.keymap_set("n", "gb", ":bnext<CR>", { desc = "Next buffer" })
utils.keymap_set("n", "gB", ":bprevious<CR>", { desc = "Previous buffer" })

-- Easy redo
utils.keymap_set("n", "U", ":redo<CR>", { desc = "Redo" })

-- Make escape easier
utils.keymap_set("i", "jk", "<esc>", { desc = "Escape insert" })
utils.keymap_set("i", "``", "<esc>", { desc = "Escape insert" })
utils.keymap_set("v", "``", "<esc>", { desc = "Escape visual" })

-- C-Space completion
utils.keymap_set("i", "<C-Space>", function()
    if vim.fn.pumvisible() == 1 then
        return utils.t("<C-n>")
    elseif utils.is_plugin_loaded("blink.cmp") then
        -- Pass through because we have this bound in blink
        return utils.t("<C-Space>")
    else
        return utils.t("<C-x><C-o>")
    end
end, { expr = true })

vim.api.nvim_create_user_command("TagsUpdate", "!ctags -R .", { desc = "Update ctags" })
vim.api.nvim_create_user_command("Todo", "grep TODO", { desc = "Search for TODO tags" })
vim.api.nvim_create_user_command("Spell", "setlocal spell! spelllang=en_us", { desc = "Toggle spelling" })

-- Pop spelling completion for word under cursor
utils.keymap_set("n", "<leader>s", "viw<esc>a<c-x>s", { desc = "Show spelling suggestions" })

-- Build on F5
utils.keymap_set("n", "<F5>", ":make<CR>", { desc = "Run make" })
