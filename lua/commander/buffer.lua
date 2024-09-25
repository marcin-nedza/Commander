local files = require("commander.file")
local utils = require("commander.utils")
local M = {}

local win_id
local command = ""
local keybind = ""

local base_opts = {
    relative = "editor",
    width = 40,
    height = 5,
    col = math.floor((vim.o.columns - 40) / 2),
    row = math.floor((vim.o.lines - 5) / 2),
    anchor = "NW",
    style = "minimal",
    border = "double",
    title_pos = "center",
}
-- Highlight and move cursor
local function highlight_line(buf, line)
    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
    vim.api.nvim_win_set_cursor(win_id, { line, 0 })
    vim.api.nvim_buf_add_highlight(buf, -1, "Visual", line - 1, 0, -1)
end

--- Move the cursor and update highlight
-- @param buf number: The buffer ID
-- @param lines table: The lines displayed in the buffer
-- @param step number: The step to move (positive for down, negative for up)
function M.move_cursor(buf, lines, step, current_line)
    current_line = current_line + step
    if current_line < 1 then
        current_line = 1
    end
    if current_line > #lines then
        current_line = #lines
    end
    highlight_line(buf, current_line)
    return current_line -- Return updated current_line
end

function M.open_floating_window(title)
    title = title or ""
    local opts = vim.tbl_extend("force", base_opts, {
        title = " Commands ",
    })

    local content, curr_dir = files.load_user_commands()
    local lines = {}
    if not content or #content == 0 then
        lines = { "no commands found." }
    else
        for _, entry in ipairs(content) do
            local command_display = entry.command or "<none>"
            table.insert(lines, string.format("Command: %s", command_display))
        end
    end

    --creating buffer,window and setting up lines
    local buf = vim.api.nvim_create_buf(false, true)
    win_id = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local current_line = 1
    highlight_line(buf, current_line)
    -- Set up input handling
    vim.keymap.set({ "i", "n" }, "<Esc>", function()
        M.abort_input(win_id)
    end, { buffer = buf, noremap = true, silent = true })

    vim.api.nvim_buf_set_keymap(buf, "n", "j", "", {
        noremap = true,
        silent = true,
        callback = function()
            current_line = M.move_cursor(buf, lines, 1, current_line)
        end,
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "k", "", {
        noremap = true,
        silent = true,
        callback = function()
            current_line = M.move_cursor(buf, lines, -1, current_line)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            M.select_command(lines, current_line, content)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "dd", "", {
        noremap = true,
        silent = true,
        callback = function()
            local keybind_str = utils.getKeybindByCommand(content, lines[current_line]:match("Command: (.+)"))
            files.delete_command(curr_dir, keybind_str)
            content = files.load_user_commands()
            M.reload_lines(buf, content)
            current_line = 1
            highlight_line(buf, current_line)
        end,
    })
end

function M.open_info_window(command_text, keybind_text)
    local opts = vim.tbl_extend("force", base_opts, {
        title = "Command Info",
        height = 5,
    })

    local prev_win_id
    -- Store the current window ID before opening the new one
    prev_win_id = win_id

    local buf = vim.api.nvim_create_buf(false, true)
    win_id = vim.api.nvim_open_win(buf, true, opts)
    local lines = {
        "Selected Command: " .. command_text,
        "Keybind: " .. keybind_text,
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Close the window and go back to the previous one when pressing <Esc>
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win_id, true) -- Close the current window
            win_id = prev_win_id         -- Set win_id back to the previous window
            if win_id then
                vim.api.nvim_set_current_win(win_id) -- Return focus to the previous window
            end
        end,
    })
end

-- Function to close the floating window if it is open
function M.close_floating_window()
    if win_id ~= nil then
        vim.api.nvim_win_close(win_id, true)
        win_id = nil -- Reset the window ID
    end
end

function M.open_input_window(title, on_submit)
    local opts = vim.tbl_extend("force", base_opts, {
        title = title,
    })

    -- Create a new empty buffer
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    -- Set the buffer to be modifiable and set initial text
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(win, { 1, 0 }) -- Move to the second line

    -- Set up input handling
    vim.keymap.set({ "i", "n" }, "<Esc>", function()
        M.abort_input(win)
    end, { buffer = buf, noremap = true, silent = true })

    vim.keymap.set("i", "<cr>", function()
        local input = M.get_input(buf)
        on_submit(input) -- Call the provided callback with the input
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf, noremap = true, silent = true })
end

function M.show_panes()
    vim.fn.system("tmux display-panes -d 2000")
end
function M.open_input_command_window()
    M.open_input_window("Enter command", function(input)
        command = input
        M.open_input_window("Enter keybind", function(input)
            keybind = input
            M.handle_input()
        end)
    end)
end

function M.abort_input(win)
    print("Aborted saving command.")
    vim.api.nvim_win_close(win, true)
end

function M.reload_lines(buf, content)
    -- Reload the user commands from the file
    content, _ = files.load_user_commands()

    -- Check if there are commands, if so format them, otherwise display no commands
    local lines = {}
    if content and #content > 0 then
        for _, entry in ipairs(content) do
            local command_display = entry.command or "<none>"
            table.insert(lines, string.format("Command: %s", command_display))
        end
    else
        lines = { "no commands found." }
    end

    -- Update the buffer with the new lines
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.get_input(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false) -- Get lines after the prompt
    return table.concat(lines, "\n")
end

function M.handle_input()
    local dirpath = vim.fn.getcwd()
    files.add_command(dirpath, command, keybind)
    print("Saved command.")
end

function M.select_command(lines, current_line, content)
    local selected = lines[current_line]
    local command_str = selected:match("Command: (.+)") -- Capture the word after "Command: "
    local keybind_str = utils.getKeybindByCommand(content, command_str)
    M.open_info_window(command_str, keybind_str)     -- Call the function to open a new window with the command text
end

return M
