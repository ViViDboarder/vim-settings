-- #selene: allow(mixed_table)
return {
    "https://github.com/saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = { "https://github.com/rafamadriz/friendly-snippets" },

    -- use a release tag to download pre-built binaries
    version = "^1",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = "default",
            ["<C-Space>"] = { "show", "select_next" },
            ["<CR>"] = { "select_and_accept", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        },

        cmdline = {
            keymap = {
                preset = "cmdline",
                ["<C-Space>"] = { "show", "select_next" },
            },
            completion = { menu = { auto_show = false } },
        },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
        },

        signature = {
            enabled = true,
            trigger = {
                enabled = true,
                show_on_insert = true,
            },
            window = {
                show_documentation = false,
            },
        },

        -- (Default) Only show the documentation popup when manually triggered
        completion = {
            list = {
                selection = {
                    preselect = false,
                },
            },
            documentation = {
                auto_show = true,
            },
            trigger = {
                show_on_keyword = false,
                show_on_trigger_character = false,
            },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
    event = "InsertEnter *",
}
