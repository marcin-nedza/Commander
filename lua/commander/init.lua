local buffer = require("commander.buffer")
local utils = require("commander.utils")
local file = require("commander.file")

---@class CommanderOptions
---@field command_file_path string
---@field file_name string
---@field leader_key string
---@field open_list string
---@field insert_new string
---@field show_panes string

local default_opts = {
    command_file_path = os.getenv("HOME") .. "/.local/share/nvim", -- Default location
    file_name = "commander.json",                                  --Default file name
    leader_key = "<C-s>",                                          -- Default leader key
    open_list = "o",                                               -- Default key to open list of commands
    insert_new = "i",                                              -- Default key to insert new command
    show_panes = "k",                                              -- Default key to show pane numbers
}

local M = {}
--- Setup function for the commander plugin.
---@param opts CommanderOptions
function M.setup(opts)
    opts = opts or {}
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    file.set_options(opts)
    -- utils.set_options(opts)
    utils.initDirectories(opts.command_file_path)
    utils.initCommandFile(opts.command_file_path, opts.file_name)
    utils.initKeybindings()
    vim.keymap.set("n", opts.leader_key .. opts.open_list, buffer.open_floating_window, { noremap = true, silent = true })
    vim.keymap.set("n", opts.leader_key .. opts.insert_new, buffer.open_input_command_window,
        { noremap = true, silent = true })
    vim.keymap.set("n", opts.leader_key .. opts.show_panes, buffer.show_panes, { noremap = true, silent = true })
end

return M
