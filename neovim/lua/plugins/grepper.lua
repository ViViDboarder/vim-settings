-- Grepper settings and shortcuts
vim.g.grepper = {
    quickfix = 1,
    open = 1,
    switch = 0,
    jump = 0,
    tools = {'git', 'rg', 'ag', 'ack', 'pt', 'grep'},
    dir = 'repo,cwd',
}

local map = vim.api.nvim_set_keymap
local opt_silent = {silent = true}
map("n", "gs", "<plug>(GrepperOperator)", opt_silent)
map("x", "gs", "<plug>(GrepperOperator)", opt_silent)
map("n", "<leader>*", ":Grepper -cword -noprompt<cr>", opt_silent)

-- Override Todo command to use Grepper
vim.cmd "command! Todo :Grepper -noprompt -query TODO"

-- Make some shortands for various grep programs
if vim.fn.executable('rg') == 1 then
    vim.cmd "command -nargs=+ Rg :GrepperRg <args>"
end
if vim.fn.executable('ag') == 1 then
    vim.cmd "command -nargs=+ Ag :GrepperAg <args>"
end
if vim.fn.executable('ack') == 1 then
    vim.cmd "command -nargs=+ Ack :GrepperAck <args>"
end
