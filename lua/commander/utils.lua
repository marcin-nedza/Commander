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
        -- Assign the keybinding
        vim.api.nvim_set_keymap("n", keybind_leader, ":" .. command .. "<CR>", { noremap = true, silent = true })
        -- vim.api.nvim_buf_set_keymap(0, "n", keybind_leader, "", {
        --     noremap = true,
        --     silent = true,
        --     callback = function ()
        --         print("---",command)
        --     files.send_tmux_command(1, command)
        -- end

        -- })
    end
end

return M
