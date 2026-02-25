local M = {}

function M.init()
    if vim.env["TERM_NERD_FONT"] == "1" then
        M.nerd_font = true
    else
        M.nerd_font = false
    end

    M.fold = {
        open = "▼",
        closed = "▶",
    }

    -- Terms that bug out on double-width unicode characters
    local known_bad_terms = {
        ["xterm-kitty"] = true,
        ["screen"] = true,
        ["screen-256color"] = true,
        ["xterm-256color"] = true,
    }
    local current_term = vim.env["TERM"] or "unknown"

    -- Diagnostics signs
    if known_bad_terms[current_term] ~= nil then
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
    if known_bad_terms[current_term] ~= nil then
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
