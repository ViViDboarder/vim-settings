local M = {}

function M.init()
    if vim.env["TERM_NERD_FONT"] == "1" then
        M.nerd_font = true
    else
        M.nerd_font = false
    end

    -- Diagnostics signs
    if vim.env["TERM"] == "xterm-kitty" then
        -- Don't use double width emoji for Kitty
        M.diagnostic_signs = {
            Error = "🔥",
            Warn = "⚠",
            Hint = "🤔",
            Info = "i",
            Pencil = "✎",
        }
    else
        M.diagnostic_signs = {
            Error = "🔥",
            Warn = "⚠️",
            Hint = "🤔",
            Info = "➞",
            Pencil = "✏️",
        }
    end

    -- Debug icons
    M.debug_icons = {
        breakpoint = "🛑",
        conditional_breakpoint = "🔍",
        log_point = "📝",
        current = "👉",
        breakpoint_rejected = "🚫",
    }

    -- Debug control icons
    if vim.env["TERM"] == "xterm-kitty" then
        -- Don't use double width emoji for Kitty
        M.debug_control_icons = {
            disconnect = "⏏",
            pause = "⏸",
            play = "▶",
            run_last = "⏮",
            step_back = "◀",
            step_into = "⤵",
            step_out = "⤴",
            step_over = "⏭",
            terminate = "⏹",
        }
    else
        M.debug_control_icons = {
            disconnect = "⏏️",
            pause = "⏸️",
            play = "▶️",
            run_last = "⏮️",
            step_back = "◀️",
            step_into = "⤵️",
            step_out = "⤴️",
            step_over = "⏭️",
            terminate = "⏹️",
        }
    end
end

M.init()

return M
