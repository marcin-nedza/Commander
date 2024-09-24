local M={}

function M.initDirectories(path)
    local dir = vim.fn.fnamemodify(path, ":h")

    if vim.fn.isdirectory(dir) and vim.fn.filereadable(path) == 1 then
        print("PRESENT")
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
return M
