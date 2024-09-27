local files = require("commander.file")
local M = {}

function M.initDirectories(path)
    local dir = vim.fn.fnamemodify(path, ":h")

    if vim.fn.isdirectory(dir) and vim.fn.filereadable(path) == 1 then
        return
    end

    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    else
        print("Failed to initialize directories.")
    end

    local file = io.open(path, "w")

    if file then
        file:close()
    else
        print("Failed to initialize file.")
    end
end

---Get keybind from a file
---@param tbl table
---@param searchCommand string
---@return string|nil
function M.getKeybindByCommand(tbl, searchCommand)
    if not tbl or #tbl == 0 then
        return nil
    end
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
        return
    end

    for _, entry in ipairs(content) do
        local command = entry.command
        local keybind = entry.keybind
        local pane
        if not entry.pane then
            pane = 0
        else
            pane = entry.pane
        end

        local keybind_leader = leader_key .. keybind

        vim.keymap.set("n", keybind_leader, function()
            files.send_tmux_command(pane, command)
        end, {
            noremap = true,
            silent = true,
        })
    end
end

return M
