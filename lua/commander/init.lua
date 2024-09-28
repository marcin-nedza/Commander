local buffer = require("commander.buffer")
local utils = require("commander.utils")

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/test/commands.json"
-- Default options
local default_opts = {
    leader_key = "<C-s>", -- Default leader key
}

local M = {}
--- Setup function for the commander plugin.
--- @param opts table: A table of options.
function M.setup(opts)
    opts = opts or {}
    opts = vim.tbl_deep_extend("force", default_opts, opts)

    utils.set_options(opts)
    utils.initDirectories(commandFilePath)
    utils.initKeybindings()
    vim.keymap.set("n", opts.leader_key .. "o", buffer.open_floating_window, { noremap = true, silent = true })
    vim.keymap.set("n", opts.leader_key .. "i", buffer.open_input_command_window, { noremap = true, silent = true })
    vim.keymap.set("n", opts.leader_key .. "k", buffer.show_panes, { noremap = true, silent = true })
end

return M
