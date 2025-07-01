-- #selene: allow(mixed_table)
local utils = require("utils")
return {
    {
        "https://github.com/mfussenegger/nvim-dap",
        version = "^0.9",
        config = function()
            local dap = require("dap")
            local dap_mapping = utils.curry_keymap("n", "<leader>d", {
                group_desc = "Debugging",
                silent = true,
                noremap = true,
            })
            dap_mapping("d", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            dap_mapping("b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
            dap_mapping("p", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

            dap_mapping("c", dap.continue, { desc = "Continue" })
            dap_mapping("C", dap.run_to_cursor, { desc = "Run to cursor" })
            dap_mapping("s", dap.stop, { desc = "Stop" })
            dap_mapping("n", dap.step_over, { desc = "Step over" })
            dap_mapping("i", dap.step_into, { desc = "Step into" })
            dap_mapping("O", dap.step_out, { desc = "Step out" })

            -- dap_mapping("h", dap.toggle_hover, { desc = "Toggle hover" })
            dap_mapping("D", dap.disconnect, { desc = "Disconnect" })
            -- dap_mapping("r", dap.repl.open, { desc = "Open REPL" })
            -- dap_mapping("R", dap.repl.run_last, { desc = "Run last" })

            local icons = require("icons")

            -- Set dap signs
            vim.fn.sign_define(
                "DapBreakpoint",
                { text = icons.debug_icons.breakpoint, texthl = "", linehl = "", numhl = "" }
            )

            vim.fn.sign_define(
                "DapLogPoint",
                { text = icons.debug_icons.log_point, texthl = "", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = icons.debug_icons.conditional_breakpoint, texthl = "", linehl = "", numhl = "" }
            )
            vim.fn.sign_define("DapStopped", { text = icons.debug_icons.current, texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointRejected",
                { text = icons.debug_icons.breakpoint_rejected, texthl = "", linehl = "", numhl = "" }
            )
        end,
        lazy = true,
    },
    {
        "https://github.com/rcarriga/nvim-dap-ui",
        dependencies = {
            { "https://github.com/mfussenegger/nvim-dap" },
            { "https://github.com/nvim-neotest/nvim-nio" },
        },
        lazy = true,
        opts = {
            icons = {
                expanded = require("icons").fold.open,
                collapsed = require("icons").fold.closed,
                current_frame = ">",
            },
            controls = {
                icons = require("icons").debug_control_icons,
            },
        },
        config = function(_, opts)
            require("dapui").setup(opts)

            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                -- Auto open on initialization
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                -- Auto close on termination
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                -- Auto close on exit
                dapui.close()
            end
        end,
    },

    {
        "https://github.com/mfussenegger/nvim-dap-python",
        dependencies = {
            { "https://github.com/rcarriga/nvim-dap-ui" },
            { "https://github.com/mfussenegger/nvim-dap" },
        },
        config = function()
            -- This is where pipx is installing debugpy via ./install-helpers.py
            -- Could maybe detect by doing a which debugpy and then reading the interpreter
            -- from the shebang line.
            require("dap-python").setup("~/.local/pipx/venvs/debugpy/bin/python3")
        end,
        ft = { "python" },
    },
}
