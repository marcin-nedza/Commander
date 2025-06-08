local M = {}

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/commander.json"

---Load user commands from file.
---@return table|nil
---@return string|nil
function M.load_user_commands()
    local file = io.open(commandFilePath, "r")
    if not file then
        print("Failed to open fil: " .. commandFilePath)
        return
    end
    local content = file:read("*a")
    file:close()

    if not content or #content == 0 then
        return nil
    end

    local ok, data = pcall(vim.fn.json_decode, content)
    if not ok then
        print("Failed to parse JSON from file: " .. commandFilePath)
    end

    local current_dir = vim.fn.getcwd()
    local commands_for_cur_dir = data.paths[current_dir]
    if not commands_for_cur_dir then
        print("No commands found for current dir.")
        return nil
    end
    return commands_for_cur_dir, current_dir
end

--- Add command to a file
---@param project_path string
---@param command_entry string
---@param keybind_entry string
---@param pane number|nil
function M.add_command(project_path, command_entry, keybind_entry, pane)
    local file = io.open(commandFilePath, "r")
    local data = { paths = {} } -- Initialize with paths as an empty table
    if not pane then
        pane = 0
    end
    if file then
        local content = file:read("*a")
        file:close()

        if content and #content > 0 then
            -- Attempt to decode the content
            local decoded_data = vim.fn.json_decode(content)
            if type(decoded_data) == "table" then
                data = decoded_data
            end
        end
    end

    -- Ensure the 'paths' field is initialized as a table
    if type(data.paths) ~= "table" then
        data.paths = {}
    end

    -- Ensure the specific project path is initialized
    if not data.paths[project_path] then
        data.paths[project_path] = {} -- Initialize as an array if it doesn't exist
    end

    -- Add the new command entry
    table.insert(data.paths[project_path], { command = command_entry, keybind = keybind_entry, pane = pane })
    -- Write the updated data back to the file
    file = io.open(commandFilePath, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end

---Update command in the file
---@param project_path string
---@param command_entry string
---@param keybind_entry string
---@param new_command string|nil
---@param new_keybind string|nil
---@param new_pane number|nil
function M.update_command(project_path, command_entry, keybind_entry, new_command, new_keybind, new_pane)
    local file = io.open(commandFilePath, "r")
    local data = { paths = {} }

    if file then
        local content = file:read("*a")
        file:close()

        if content and #content > 0 then
            local decoded_data = vim.fn.json_decode(content)
            if type(decoded_data) == "table" then
                data = decoded_data
            end
        end
    end

    if type(data.paths) ~= "table" then
        print("No paths found.")
        return
    end

    if not data.paths[project_path] then
        print("Project path not found.")
        return
    end

    local project_command = data.paths[project_path]
    local command_found = false

    -- Find the command and keybind
    for i, entry in ipairs(project_command) do
        if entry.command == command_entry and entry.keybind == keybind_entry then
            -- Update the fields if new values are provided
            if new_command then
                entry.command = new_command
            end
            if new_keybind then
                entry.keybind = new_keybind
            end
            if new_pane then
                entry.pane = new_pane
            end
            command_found = true
            break
        end
    end

    if not command_found then
        print("Command with specified keybind not found.")
        return
    end

    -- Write the updated data back to the file
    file = io.open(commandFilePath, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
        print("Command updated successfully.")
    else
        print("Failed to open file for writing.")
    end
end
---Delete command from list
---@param project_path string
---@param keybind string
function M.delete_command(project_path, keybind)
    local file = io.open(commandFilePath, "r")
    local data = { paths = {} }

    if file then
        local content = file:read("*a")
        file:close()

        if content and #content > 0 then
            local decoded_data = vim.fn.json_decode(content)
            if type(decoded_data) == "table" then
                data = decoded_data
            end
        end
    end
    if type(data.paths) ~= "table" then
        print("No paths found.")
        return
    end
    if not data.paths[project_path] then
        print("Project path not found.")
        return
    end
    local project_command = data.paths[project_path]

    for i, entry in ipairs(project_command) do
        if entry.keybind == keybind then
            table.remove(project_command, i)
            print("Command removed")
            break
        end
    end

    if #project_command then
        data.paths[project_path] = nil
    end

    data.paths[project_path] = project_command
    file = io.open(commandFilePath, "w")
    if file then
        file:write(vim.json.encode(data))
        file:close()
        print("Update succesfull")
    else
        print("Failed to open file")
    end
end

---Send command to specified terminal or use neovim cmd
---@param pane integer
---@param command string
function M.send_tmux_command(pane, command)
    -- Construct the tmux send-keys command
    local escaped_command = command:gsub("'", "'\\''")
    local send_command
    if pane == 0 then
        send_command =command
        vim.cmd(send_command)
    else
        send_command = "tmux send-keys -t " .. pane .. " '" .. escaped_command .. "' C-m"
        vim.fn.system(send_command)
    end
end

return M
