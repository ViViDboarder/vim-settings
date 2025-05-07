local M = {}

-- Function to check if the binary is already installed
local function is_installed()
    return vim.fn.executable("ollama-copilot") == 1
end

-- Function to install the Go application
M.install = function()
    local job_id = vim.fn.jobstart({ "go", "install", "github.com/bernardo-bruning/ollama-copilot@latest" }, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                if is_installed() then
                    vim.notify("Successfully installed ollama-copilot", vim.log.levels.INFO)
                else
                    vim.notify("Installed ollama-copilot, but not found in path.", vim.log.levels.ERROR)
                end
            else
                vim.notify("Failed to install ollama-copilot. Exit code: " .. exit_code, vim.log.levels.ERROR)
            end
        end,
    })

    if job_id == 0 then
        vim.notify("Failed to start the installation process", vim.log.levels.ERROR)
    end
end

-- Function to start the server in the background with optional configuration
M.start_server = function(config)
    if M.handle ~= nil then
        vim.notify(
            "Cannot start ollama-copilot because it is already running with pid: " .. M.handle,
            vim.log.levels.WARN
        )
        return M.handle
    end

    config = config or {}

    -- Default configuration values
    local default_config = {
        port = ":11437",
        proxyPort = ":11438",
        portSSL = ":11436",
        proxyPortSSL = ":11435",
        cert = "",
        key = "",
        model = "codellama:code",
        numPredict = 50,
        templateStr = "",
    }

    -- Merge user configuration with default configuration
    for k, v in pairs(default_config) do
        if config[k] == nil then
            config[k] = v
        end
    end

    if not is_installed() then
        vim.notify("ollama-copilot is not installed. Starting installation...", vim.log.levels.INFO)
        M.install()
        return
    end

    -- Prepare the command with configuration options
    local cmd = {
        "ollama-copilot",
        "--port",
        config.port,
        "--proxy-port",
        config.proxyPort,
        "--port-ssl",
        config.portSSL,
        "--proxy-port-ssl",
        config.proxyPortSSL,
        "--cert",
        config.cert,
        "--key",
        config.key,
        "--model",
        config.model,
        "--num-predict",
        tostring(config.numPredict),
        "--template",
        config.templateStr,
    }

    local handle = vim.fn.jobstart(cmd, {
        detach = true,
        on_exit = function(_, exit_code)
            if exit_code > 0 then
                vim.notify("ollama-copilot server exited with code: " .. exit_code, vim.log.levels.ERROR)
            end
        end,
    })

    if handle == -1 then
        vim.notify("Failed to start ollama-copilot server", vim.log.levels.ERROR)
    else
        -- TODO: this should probably be silent once things are working well
        vim.notify("Started ollama-copilot server with handle: " .. handle, vim.log.levels.INFO)
    end

    -- Store current pid
    M.handle = handle

    -- Autocmd to stop the server when Neovim exits
    vim.api.nvim_create_autocmd({ "VimLeave" }, {
        group = vim.api.nvim_create_augroup("OllamaCopilot", { clear = true }),
        callback = function()
            if M.handle then
                M.stop_server(M.handle)
            end
        end,
    })

    return handle
end

-- Function to stop the server by killing its process
M.stop_server = function(handle)
    if handle == nil then
        handle = M.handle
    end

    if handle == nil then
        vim.notify("No valid handle provided to stop the server", vim.log.levels.WARN)
        return
    end

    print("stopping " .. vim.inspect(handle))
    local job_id = vim.fn.jobstop(handle)

    if job_id == -1 then
        vim.notify("Failed to stop ollama-copilot server with handle: " .. handle, vim.log.levels.ERROR)
    else
        vim.notify("Stopped ollama-copilot server with handle: " .. handle, vim.log.levels.INFO)
        M.handle = nil
        vim.api.nvim_create_augroup("OllamaCopilot", { clear = true })
    end
end

function M.setup()
    vim.api.nvim_create_user_command("OllamaCopilotInstall", function()
        M.install()
    end, { desc = "Install ollama-copilot" })
    vim.api.nvim_create_user_command("OllamaCopilotStart", function()
        M.start_server()
    end, { desc = "Start ollama-copilot server" })
    vim.api.nvim_create_user_command("OllamaCopilotStop", function()
        M.stop_server()
    end, { desc = "Stop ollama-copilot server" })
end

return M
