local files = require("commander.file")
local M = {}

function M.initDirectories(path)
    local dir = vim.fn.fnamemodify(path, ":h")

    if vim.fn.isdirectory(dir) and vim.fn.filereadable(path) == 1 then
        return
    end

    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
        print("Initialized directories.")
    else
        print("Failed to initialize directories.")
    end

    local file = io.open(path, "w")

    if file then
        file:close()
        print("Initialized file")
    else
        print("Failed to initialize file.")
    end
end

function M.getKeybindByCommand(tbl, searchCommand)
    for _, entry in ipairs(tbl) do
        if entry.command == searchCommand then
            return entry.keybind -- Return the keybind if command matches
        end
    end
    return nil -- Return nil if the command is not found
end

function M.initKeybindings(leader_key)
    local content = files.load_user_commands()
    if not content or #content == 0 then
        print("No commands found. No keybindings were set.")
        return
    end

    for _, entry in ipairs(content) do
        local command = entry.command
        local keybind = entry.keybind

        local keybind_leader = leader_key .. keybind
        -- Print for debugging purposes
        print("command: ", command)
        print("keybind: ", keybind)
        print("with leader: ", keybind_leader)

        -- Assign the keybinding
        vim.api.nvim_set_keymap("n", leader_key .. keybind, ":" .. command .. "<CR>", { noremap = true, silent = true })
    end
end

return M
