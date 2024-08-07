-- Grepper settings and shortcuts
vim.g.grepper = {
    quickfix = 1,
    open = 1,
    switch = 0,
    jump = 0,
    tools = { "git", "rg", "ag", "ack", "pt", "grep" },
    dir = "repo,cwd",
}

require("utils").keymap_set({ "n", "x" }, "gs", "<plug>(GrepperOperator)", {
    silent = true,
    noremap = false,
    desc = "Grepper",
})

-- Override Todo command to use Grepper
vim.api.nvim_create_user_command("Todo", ":Grepper -noprompt -query TODO", { desc = "Search for TODO tags" })

-- Make some shortands for various grep programs
if vim.fn.executable("rg") == 1 then
    vim.api.nvim_create_user_command("Rg", ":GrepperRg <args>", { nargs = "+", desc = "Ripgrep" })
end
if vim.fn.executable("ag") == 1 then
    vim.api.nvim_create_user_command("Ag", ":GrepperAg <args>", { nargs = "+", desc = "Silversearcher" })
end
if vim.fn.executable("ack") == 1 then
    vim.api.nvim_create_user_command("Ack", ":GrepperAck <args>", { nargs = "+", desc = "Ack search" })
end
