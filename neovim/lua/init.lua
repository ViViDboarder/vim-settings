if vim.fn.has("nvim-0.12.0") ~= 1 then
    print("ERROR: Requires nvim >= 0.12.0")
end

require("config")
