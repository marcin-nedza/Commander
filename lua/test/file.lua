local M = {}

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/test/commands.json"

local function file_exist(path)
    local stat = vim.fn.filereadable(path)
    return stat ~= 0
end

function M.load_user_commands()
    local file = io.open(commandFile, "r")
    if not file then
        print("Failed to open fil: " .. commandFile)
        return
    end
    local content = file:read("*a")
    file:close()

    if not content and #content == 0 then
        return nil
    end

    local ok, data = pcall(vim.fn.json_decode, content)
    if not ok then
        print("Failed to parse JSON from file: " .. commandFile)
    end

    local current_dir = vim.fn.getcwd()
    local commands_for_cur_dir = data.paths[current_dir]
    if not commands_for_cur_dir then
        print("No commands found for current dir.")
        return nil
    end
    return commands_for_cur_dir
end

function M.add_command(project_path, command_entry)
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
    table.insert(data.paths[project_path], { command = command_entry, keybind = "" })

    -- Write the updated data back to the file
    file = io.open(commandFilePath, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    end
end

function M.open_input_window()
    local opts = {
        relative = "editor",
        width = 40,
        height = 5,
        col = math.floor((vim.o.columns - 40) / 2),
        row = math.floor((vim.o.lines - 5) / 2),
        anchor = "NW",
        style = "minimal",
        border = "rounded",
    }

    -- Create a new empty buffer
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set the buffer to be modifiable and set initial text
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Enter your command: ", "" })

    vim.api.nvim_win_set_cursor(win, { 2, 0 }) -- Move to the second line

    -- Set up input handling
    vim.api.nvim_buf_set_keymap(
        buf,
        "i",
        "<Esc>",
        "<Cmd>lua require('test.file').abort_input(" .. win .. ")<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        buf,
        "i",
        "<CR>",
        "<Cmd>lua require('test.file').handle_input(" .. buf .. "," .. win .. ")<CR>",
        { noremap = true, silent = true }
    )
end

function M.abort_input(win)
    print("Aborted saving command.")
    vim.api.nvim_win_close(win, true)
end

function M.handle_input(buf, win)
    local lines = vim.api.nvim_buf_get_lines(buf, 1, -1, false) -- Get lines after the prompt
    local command_string = table.concat(lines, "\n")

    local dirpath = vim.fn.getcwd()

    M.add_command(commandFile, dirpath, command_string)
    -- Close the window
    print("Saved command.")
    vim.api.nvim_win_close(win, true)
end

return M
