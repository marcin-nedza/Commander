local M = {}

local path = nil

---Set options
---@param opt CommanderOptions
function M.set_options(opt)
    M.table = {
        options = opt
    }
end

-- Utility to read and parse the JSON data
local function read_data()
    local file_path = get_path()
    if not file_path then return nil end

    local file = io.open(file_path, "r")
    if not file then return { paths = {} } end

    local content = file:read("*a")
    file:close()

    if not content or #content == 0 then return { paths = {} } end

    local ok, data = pcall(vim.fn.json_decode, content)
    if not ok or type(data) ~= "table" then
        print("[Commander]: Failed to parse JSON.")
        return { paths = {} }
    end

    if type(data.paths) ~= "table" then
        data.paths = {}
    end

    return data
end

-- ---Load user commands from file.
-- ---@return table|nil
-- ---@return string|nil
-- function M.load_user_commands()
--     local path = get_path()
--     if not path then return end
--
--     local file = io.open(path, "r")
--     if not file then
--         print("[Commander]:Failed to open file: " .. path)
--         return
--     end
--     local content = file:read("*a")
--     file:close()
--
--     if not content or #content == 0 then
--         return nil
--     end
--
--     local ok, data = pcall(vim.fn.json_decode, content)
--     if not ok then
--         print("[Commander]: Failed to parse JSON from file: " .. path)
--     end
--
--     local current_dir = vim.fn.getcwd()
--     local commands_for_cur_dir = data.paths[current_dir]
--     if not commands_for_cur_dir then
--         print("[Commander]: No commands found for current dir.")
--         return nil
--     end
--     return commands_for_cur_dir, current_dir
-- end
-- Load user commands for current directory
---@return table|nil, string|nil
function M.load_user_commands()
    local data = read_data()
    local current_dir = vim.fn.getcwd()
    local commands = data.paths[current_dir]

    if not commands then
        print("[Commander]: No commands found for current dir.")
        return nil
    end

    return commands, current_dir
end

--- Add command to a file
---@param project_path string
---@param command_entry string
---@param keybind_entry string
---@param pane number|nil
---@param win string|nil
function M.add_command(project_path, command_entry, keybind_entry, pane, win)
    local path = get_path()
    if not path then return end

    local file = io.open(path, "r")
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
    table.insert(data.paths[project_path], { command = command_entry, keybind = keybind_entry, pane = pane, win = win })
    -- Write the updated data back to the file
    file = io.open(path, "w")
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
    local path = get_path()
    if not path then return end

    local file = io.open(path, "r")
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
        print("[Commander]: No paths found.")
        return
    end

    if not data.paths[project_path] then
        print("[Commander]: Project path not found.")
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
        print("[Commander]: Command with specified keybind not found.")
        return
    end

    -- Write the updated data back to the file
    file = io.open(path, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
        print("[Commander]: Command updated successfully.")
    else
        print("[Commander]: Failed to open file for writing.")
    end
end

---Delete command from list
---@param project_path string
---@param keybind string
function M.delete_command(project_path, keybind)
    local path = get_path()
    if not path then return end

    local file = io.open(path, "r")
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
        print("[Commander]: No paths found.")
        return
    end
    if not data.paths[project_path] then
        print("[Commander]: Project path not found.")
        return
    end
    local project_command = data.paths[project_path]

    for i, entry in ipairs(project_command) do
        if entry.keybind == keybind then
            table.remove(project_command, i)
            print("[Commander]: Command removed")
            break
        end
    end

    if #project_command then
        data.paths[project_path] = nil
    end

    data.paths[project_path] = project_command
    file = io.open(path, "w")
    if file then
        file:write(vim.json.encode(data))
        file:close()
        print("[Commander]: Update succesfull")
    else
        print("[Commander]: Failed to open file")
    end
end

---Send command to specified terminal or use neovim cmd
---@param pane integer
---@param command string
---@param win integer
function M.send_tmux_command(pane, command, win)
    print("send pane:" .. pane .. " command: " .. command .. "  win:" .. win)
    -- Construct the tmux send-keys command
    local target = tostring(pane)
    if win ~= nil then
        target = tostring(win) .. "." .. tostring(pane)
    end

    -- Escape the command
    local escaped_command = command:gsub("'", "'\\''")

    local send_command
    if pane == 0 and not win then
        send_command = command
        vim.cmd(send_command)
    else
        send_command = "tmux send-keys -t " .. target .. " '" .. escaped_command .. "' C-m"
        vim.fn.system(send_command)
    end
end

function get_path()
    if path then return path end
    if not M.table or not M.table.options then
        return nil
    end
    path = M.table.options.command_file_path .. "/" .. M.table.options.file_name
    return path
end

return M
