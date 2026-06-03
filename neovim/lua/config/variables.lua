-- Use only minimal plugins
vim.g.minimal = false
vim.g.install_sourcegraph = false

-- See neovim/lua/lazy_specs/llm_assist.lua for explanations
vim.g.llm_provider = nil
vim.g.llm_completion_provider = nil
vim.g.llm_chat_model = nil
vim.g.llm_completion_model = nil
vim.g.llm_anthropic_url = nil
vim.g.llm_open_webui_url = nil
vim.g.llm_open_webui_api_key = nil

-- Force using lazy.nvim for nvim >=0.12
vim.g.force_lazy = false
