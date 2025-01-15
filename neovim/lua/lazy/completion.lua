-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        "https://github.com/L3MON4D3/LuaSnip",
        version = "^2",
        event = "InsertEnter *",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
        dependencies = {
            { "https://github.com/rafamadriz/friendly-snippets" },
        },
    },
    {
        "https://github.com/hrsh7th/cmp-nvim-lsp",
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            ["<0.7.0"] = "3cf38d9c957e95c397b66f91967758b31be4abe6",
        }),
        dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
        event = "InsertEnter *",
    },
    {
        "https://github.com/hrsh7th/cmp-buffer",
        dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
        event = "InsertEnter *",
    },
    {
        "https://github.com/f3fora/cmp-spell",
        dependencies = { { "https://github.com/hrsh7th/nvim-cmp" } },
        event = "InsertEnter *",
    },
    {
        "https://github.com/saadparwaiz1/cmp_luasnip",
        commit = utils.map_version_rule({
            [">0.7.0"] = utils.nil_val,
            [">=0.5.0"] = "b10829736542e7cc9291e60bab134df1273165c9",
        }),
        dependencies = {
            { "https://github.com/hrsh7th/nvim-cmp" },
            { "https://github.com/L3MON4D3/LuaSnip" },
        },
        event = "InsertEnter *",
    },

    {
        "https://github.com/hrsh7th/nvim-cmp",
        config = function()
            require("plugins.completion").config_cmp()
        end,
        version = utils.map_version_rule({
            [">=0.7.0"] = "^0.0.2",
            ["<0.7.0"] = utils.nil_val,
        }),
        commit = utils.map_version_rule({
            [">=0.7.0"] = utils.nil_val,
            [">=0.5.0"] = "bba6fb67fdafc0af7c5454058dfbabc2182741f4",
        }),
        event = "InsertEnter *",
    },

    event = "InsertEnter *",
}
