local utils = require("utils")

local map = vim.api.nvim_set_keymap

local opt_silent = { silent = true }
local opt_default = { silent = true, noremap = true }
map("n", "<C-L><C-L>", ":set wrap!<CR>", opt_silent)
map("n", "<leader>lw", ":set wrap!<CR>", opt_silent)
map("n", "<C-N><C-N>", ":set invnumber<CR>", opt_silent)
map("n", "<leader>ln", ":set invnumber<CR>", opt_silent)
map("n", "<leader>/", ":set hlsearch! hlsearch?<CR>", opt_silent)
map("n", "<leader>cs", ":nohlsearch<CR>", opt_silent)
map("n", "<leader>ws", ":set list!<CR>", opt_silent)

-- Save and quit typos
map("c", "WQ<CR>", "wq<CR>", opt_silent)
map("c", "Wq<CR>", "wq<CR>", opt_silent)
map("c", "W<CR>", "w<CR>", opt_silent)
map("c", "Q<CR>", "q<CR>", opt_silent)
map("c", "Q!<CR>", "q!<CR>", opt_silent)
map("c", "Qa<CR>", "qa<CR>", opt_silent)
map("c", "Qa!<CR>", "qa!<CR>", opt_silent)
map("c", "QA<CR>", "qa<CR>", opt_silent)
map("c", "QA!<CR>", "qa!<CR>", opt_silent)
map("c", "w;", "w", opt_default)
map("c", "W;", "w", opt_default)
map("c", "q;", "q", opt_default)
map("c", "Q;", "q", opt_default)

-- Paste over
map("v", "pp", "p", opt_default)
map("v", "po", '"_dP', opt_default)

-- Buffer nav
map("n", "gb", ":bnext<CR>", {})
map("n", "gB", ":bprevious<CR>", {})

-- Easy redo
map("n", "U", ":redo<CR>", opt_default)

-- Make escape easier
map("i", "jk", "<esc>", opt_default)
map("i", "``", "<esc>", opt_default)
map("v", "``", "<esc>", opt_default)

-- C-Space completion
function _G.complete_space()
    if vim.fn.pumvisible() == 1 then
        return utils.t("<C-n>")
    elseif utils.is_plugin_loaded("completion-nvim") then
        return utils.t("<Plug>(completion_trigger)")
    elseif utils.is_plugin_loaded("nvim-compe") then
        return vim.fn["compe#complete"]()
    elseif utils.is_plugin_loaded("nvim-cmp") then
        return utils.t("<Plug>(cmp_complete)")
    else
        return utils.t("<C-x><C-o>")
    end
end
map("i", "<C-Space>", "v:lua.complete_space()", { expr = true })

-- Easily toggle spelling
vim.cmd("command Spell setlocal spell! spelllang=en_us")
-- Pop spelling completion for word under cursor
map("n", "<leader>s", "viw<esc>a<c-x>s", {})

-- Build on F5
map("n", "<F5>", ":make<CR>", {})
