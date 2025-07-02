-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        "https://github.com/ViViDboarder/wombat.nvim",
        branch = "plugin-highlights",
        opts = function(_, opts)
            -- Set ansi base colors for wombat theme based on terminal program
            local term_program = vim.env.TERM_PROGRAM
            local term_profile = vim.env.TERM_PROFILE

            if term_program == "iTerm.app" or term_profile == "Wombat-iTerm" then
                opts.ansi_colors_name = "iterm2"
            elseif term_program == "ghostty" then
                opts.ansi_colors_name = "ghostty"
            end

            return opts
        end,
        dependencies = {
            {
                "https://github.com/rktjmp/lush.nvim",
                tag = utils.map_version_rule({
                    [">=0.7.0"] = utils.nil_val,
                    [">=0.5.0"] = "v1.0.1",
                }),
            },
        },
        lazy = false,
    },
    { "https://github.com/vim-scripts/wombat256.vim" },
    { "https://github.com/ishan9299/nvim-solarized-lua" },
    {
        "https://github.com/folke/tokyonight.nvim",
        -- Install fish theme
        build = (
            'fish -c \'echo "set --path --prepend fish_themes_path (pwd)"/extras"'
            .. "> ~/.config/fish/conf.d/tokyonight.fish' || true"
        ),
    },
    priority = 1000,
}
