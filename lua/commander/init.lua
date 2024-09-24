local buffer = require("commander.buffer")
local files = require("commander.file")
local utils = require("commander.utils")

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/test/commands.json"
-- Default options
local default_opts = {
    leader_key = "<Leader>", -- Default leader key
}

local M = {}
--- Setup function for the commander plugin.
-- @param opts table: A table of options.
-- @param opts.leader_key string: The leader key to use (default is "<Leader>").
function M.setup(opts)
    opts = vim.tbl_deep_extend("force", default_opts, opts)

    utils.initDirectories(commandFilePath)
    vim.keymap.set("n", opts.leader_key .. "h", buffer.open_floating_window, { noremap = true, silent = true })
    vim.keymap.set("n", "<Leader><Leader>h", buffer.open_input_command_window, { noremap = true, silent = true })
    vim.keymap.set("n", "<Leader><Leader>j", files.get_first_action, { noremap = true, silent = true })
end

return M
