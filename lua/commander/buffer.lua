local files = require("commander.file")
local M = {}

local win_id = nil
local command = ""
local keybind = ""

function M.open_floating_window()
    local opts = {
        relative = "editor",
        width = 50,
        height = 15,
        col = math.floor(vim.o.columns / 4),
        row = math.floor(vim.o.lines / 4),
        anchor = "NW",
        style = "minimal",
        border = "rounded",
    }

    local content = files.load_user_commands()
    local lines = {}

    if not content or #content==0 then
        lines = { "No commands found." }
    else
        for _, entry in ipairs(content) do
            table.insert(lines, "Keybind: " .. (entry.keybind ~= "" and entry.keybind or "<none>"))
            table.insert(lines, "Command: " .. entry.command)
            table.insert(lines, "")
        end
    end

    -- Create a new empty buffer
    local buf = vim.api.nvim_create_buf(false, true)
    -- Create the floating window
    win_id = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Function to close the floating window if it is open
function M.close_floating_window()
    if win_id ~= nil then
        vim.api.nvim_win_close(win_id, true)
        win_id = nil -- Reset the window ID
    end
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "/,?",
    callback = function()
        local cmd = vim.fn.getcmdline()
        if cmd == "nohl" then
            M.close_floating_window()
        end
    end,
})

function M.open_input_window(prompt, on_submit)
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
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prompt, "" })
    vim.api.nvim_win_set_cursor(win, { 2, 0 }) -- Move to the second line

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

function M.open_input_command_window()
    M.open_input_window("Enter your command: ", function(input)
        command = input
        M.open_input_window("Enter your keybind: ", function(input)
            keybind = input
            M.handle_input()
        end)
    end)
end

function M.abort_input(win)
    print("Aborted saving command.")
    vim.api.nvim_win_close(win, true)
end

function M.get_input(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 1, -1, false) -- Get lines after the prompt
    return table.concat(lines, "\n")
end

function M.handle_input(win)
    local dirpath = vim.fn.getcwd()
    files.add_command(dirpath, command, keybind)
    print("Saved command.")
end

return M
