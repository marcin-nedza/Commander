local buffer=require('test.buffer')
local file=require('test.file')

local M = {}
function M.setup()
    vim.keymap.set("n", "<Leader>h", buffer.open_floating_window, { noremap = true, silent = true })
    vim.keymap.set("n", "<Leader><Leader>h", file.open_input_window, { noremap = true, silent = true })
end
return M
