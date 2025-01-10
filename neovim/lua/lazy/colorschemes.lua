-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        "https://github.com/ViViDboarder/wombat.nvim",
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
        build = 'fish -c \'echo "set --path --prepend fish_themes_path "(pwd)"/extras" > ~/.config/fish/conf.d/tokyonight.fish\' || true', -- luacheck: no max line length
    },
    priority = 1000,
}
