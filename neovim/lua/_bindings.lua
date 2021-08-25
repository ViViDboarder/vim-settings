local map = vim.api.nvim_set_keymap

local opt_silent = {silent=true}
local opt_default = {silent=true, noremap=true}
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
_G.complete_space = function()
    if vim.fn.pumvisible() == 1 then
        return utils.t"<C-n>"
    elseif packer_plugins["completion-nvim"] and packer_plugins["completion-nvim"].loaded then
        return utils.t"<Plug>(completion_trigger)"
    elseif packer_plugins["nvim-compe"] and packer_plugins["nvim-compe"].loaded then
        return vim.fn["compe#complete"]()
    else
        return utils.t"<C-x><C-o>"
    end
end
map("i", "<C-Space>", "v:lua.complete_space()", {expr = true})
