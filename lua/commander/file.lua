local M = {}

local path = nil

-- Get config file path
local function get_path()
    if path then return path end
    if not M.table or not M.table.options then return nil end
    path = M.table.options.command_file_path .. "/" .. M.table.options.file_name
    return path
end

---Set options
---@param opt CommanderOptions
function M.set_options(opt)
    M.table = {
        options = opt
    }
end

-- Utility to write data back to file
local function write_data(data)
    local file_path = get_path()
    if not file_path then return end

    local file = io.open(file_path, "w")
    if not file then
        print("[Commander]: Failed to open file for writing.")
        return
    end
    file:write(vim.fn.json_encode(data))
    file:close()
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

-- Load user commands for current directory
---@return table|nil, string|nil
function M.load_user_commands()
    local data = read_data()
    if not data then return end

    local current_dir = vim.fn.getcwd()
    local commands = data.paths[current_dir]

    if not commands then
        print("[Commander]: No commands found for current dir.")
        return nil
    end

    return commands, current_dir
end

-- Add command to a project path
---@param project_path string
---@param command_entry string
---@param keybind_entry string
---@param pane number|nil
---@param win string|nil
function M.add_command(project_path, command_entry, keybind_entry, pane, win)
    local data = read_data()
    data.paths[project_path] = data.paths[project_path] or {}
    table.insert(data.paths[project_path], {
        command = command_entry,
        keybind = keybind_entry,
        pane = pane or 0,
        win = win
    })
    write_data(data)
end

---Update command in the file
---@param project_path string
---@param command_entry string
---@param keybind_entry string
---@param new_command string|nil
---@param new_keybind string|nil
---@param new_pane number|nil
function M.update_command(project_path, command_entry, keybind_entry, new_command, new_keybind, new_pane)
    local data = read_data()
    local project_cmds = data.paths[project_path]

    if not project_cmds then
        print("[Commander]: Project path not found.")
        return
    end

    for _, entry in ipairs(project_cmds) do
        if entry.command == command_entry and entry.keybind == keybind_entry then
            if new_command then entry.command = new_command end
            if new_keybind then entry.keybind = new_keybind end
            if new_pane then entry.pane = new_pane end
            write_data(data)
            print("[Commander]: Command updated successfully.")
            return
        end
    end

    print("[Commander]: Command with specified keybind not found.")
end

---Delete command from list
---@param project_path string
---@param keybind string
function M.delete_command(project_path, keybind)
    local data = read_data()
    local project_cmds = data.paths[project_path]

    if not project_cmds then
        print("[Commander]: Project path not found.")
        return
    end

    for i, entry in ipairs(project_cmds) do
        if entry.keybind == keybind then
            table.remove(project_cmds, i)
            print("[Commander]: Command removed.")
            break
        end
    end

    if #project_cmds == 0 then
        data.paths[project_path] = nil
    end

    write_data(data)
end

---Send command to specified terminal or use neovim cmd
---@param pane integer
---@param command string
---@param win integer
function M.send_tmux_command(pane, command, win)
    local target = tostring(pane)
    if win then target = tostring(win) .. "." .. tostring(pane) end

    local escaped_command = command:gsub("'", "'\\''")
    local send_command

    if pane == 0 and not win then
        vim.cmd(command)
    else
        send_command = "tmux send-keys -t " .. target .. " '" .. escaped_command .. "' C-m"
        vim.fn.system(send_command)
    end
end

return M
