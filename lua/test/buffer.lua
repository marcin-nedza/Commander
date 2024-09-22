local files = require("test.file")
local M = {}

local win_id = nil -- Store the window ID to track if it's open or closed

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

    if not content then
        lines={"No commands found."}
    else
        for _, entry in ipairs(content) do
           table.insert(lines,"Keybind: "..(entry.keybind ~="" and entry.keybind or "<none>"))
           table.insert(lines,"Command: "..entry.command)
           table.insert(lines,"")
        end
    end

    -- Create a new empty buffer
    local buf = vim.api.nvim_create_buf(false, true)
    -- Create the floating window
    win_id = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false,lines)
end

-- Function to close the floating window if it is open
function M.close_floating_window()
    if win_id ~= nil then
        vim.api.nvim_win_close(win_id, true)
        win_id = nil -- Reset the window ID
    end
end

-- Toggle the floating window: open if not open, close if already open
vim.api.nvim_create_autocmd("CmdlineLeave", {
    pattern = "/,?",
    callback = function()
        local cmd = vim.fn.getcmdline()
        if cmd == "nohl" then
            M.close_floating_window()
        end
    end,
})
return M
