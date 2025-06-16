local files = require("commander.file")
local M = {}

function M.initDirectories(dir)
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
end
function M.initCommandFile(dir, fileName)
    local path = dir .. "/" .. fileName

    -- Check if file already exists
    local existing = io.open(path, "r")
    if existing then
        existing:close()
        return -- Do nothing if file exists
    end

    -- File does not exist, create it
    local file = io.open(path, "w")
    if file then
        file:close()
    else
        print("[Commander]: Failed to initialize file: " .. path)
    end
end


---Get keybind from a file
---@param tbl table
---@param searchCommand string
---@return string|nil
---@return integer
function M.getKeybindByCommand(tbl, searchCommand)
    if not tbl or #tbl == 0 then
        return nil,0
    end
    for _, entry in ipairs(tbl) do
        if entry.command == searchCommand then
            return entry.keybind,entry.pane -- Return the keybind if command matches
        end
    end
    return nil,0 -- Return nil if the command is not found
end

function M.initKeybindings()
    local content = files.load_user_commands()
    if not content or #content == 0 then
        return
    end

    for _, entry in ipairs(content) do
        local command = entry.command
        local keybind = entry.keybind
        local pane
        local window
        if not entry.pane then
            pane = 0
        else
            pane = entry.pane
        end
        if not entry.win then
            window = 0
        else
            window = entry.win
        end

        local leader_key=files.table.options.leader_key
        local keybind_leader = leader_key .. keybind

        vim.keymap.set("n", keybind_leader, function()
            files.send_tmux_command(pane, command,window)
        end, {
            noremap = true,
            silent = true,
        })
    end
end

return M
