local buffer = require("commander.buffer")
local files = require("commander.file")
local utils = require("commander.utils")

local commandFilePath = os.getenv("HOME") .. "/.local/share/nvim/test/commands.json"
-- Default options
local default_opts = {
    leader_key = "<C-s>", -- Default leader key
}

local M = {}
--- Setup function for the commander plugin.
-- @param opts table: A table of options.
-- @param opts.leader_key string: The leader key to use (default is "<Leader>").
function M.setup(opts)
    opts = opts or {}
    opts = vim.tbl_deep_extend("force", default_opts, opts)

    utils.initDirectories(commandFilePath)
    utils.initKeybindings(opts.leader_key)
    vim.keymap.set("n", opts.leader_key .. "o", buffer.open_floating_window, { noremap = true, silent = true })
    vim.keymap.set("n", opts.leader_key .. "i", buffer.open_input_command_window, { noremap = true, silent = true })
    -- vim.keymap.set("n", opts.leader_key .. "r", files.delete_command, { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", opts.leader_key .. "r", "", {
        noremap = true,
        silent = true,
        callback = function()
            files.delete_command(vim.fn.getcwd(),'jjj')
        end,
    })
end

return M
