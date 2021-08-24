-- Utils taken from https://github.com/zzzeyez/dots/blob/master/nvim/lua/utils.lua
local M = {}

-- Key mapping
function M.map(mode, key, result, opts)
  vim.fn.nvim_set_keymap(
    mode,
    key,
    result,
    {
      noremap = true,
      silent = opts.silent or false,
      expr = opts.expr or false,
      script = opts.script or false
    }
  )
end

function M.augroup(group, fn)
  vim.api.nvim_command("augroup " .. group)
  vim.api.nvim_command("autocmd!")
  fn()
  vim.api.nvim_command("augroup END")
end

function M.get_color(synID, what, mode)
  return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(synID)), what, mode)
end

-- Create an autocmd
function M.autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then cmds = {cmds} end
    vim.cmd("augroup " .. group)
    if clear then vim.cmd [[au!]] end
    for _, cmd in ipairs(cmds) do vim.cmd("autocmd " .. cmd) end
    vim.cmd [[augroup END]]
end

-- Terminal escape a given string
function M.t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Get env value or use default, if not present
function M.env_default(name, def)
    val = vim.env[name]
    return val == nil and def or val
end

return M
