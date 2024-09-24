local M = {}

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/test/commands.json"

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
    return commands_for_cur_dir
end

function M.add_command(project_path, command_entry, keybind_entry)
    local file = io.open(commandFilePath, "r")
    local data = { paths = {} } -- Initialize with paths as an empty table

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
    table.insert(data.paths[project_path], { command = command_entry, keybind = keybind_entry })

    -- Write the updated data back to the file
    file = io.open(commandFilePath, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end


function M.get_first_action()
    local com = M.load_user_commands()
    print(com[1].command)
    vim.cmd(com[1].command)
end

return M
