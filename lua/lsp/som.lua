-- som: binary lookup and the client-side commands the server's code lenses refer to
local M = {}

-- the newest of <root>/target/{debug,release}/som, so working on som itself uses what was
-- just built; otherwise `som` from PATH
function M.binary(root)
    local bin, newest = "som", -1
    if root then
        for _, profile in ipairs({ "debug", "release" }) do
            local candidate = root .. "/target/" .. profile .. "/som"
            local stat = vim.uv.fs_stat(candidate)
            if stat and stat.mtime.sec > newest then
                bin, newest = candidate, stat.mtime.sec
            end
        end
    end
    return bin
end

-- what to run for a file: its directory when that's a multi-file program (it has a
-- `main.som`), otherwise just the file
local function program_for(file)
    local dir = vim.fs.dirname(file)
    return vim.uv.fs_stat(dir .. "/main.som") and dir or file
end

-- `som.run` (the Run lens on `main`): runs the program in a terminal split
vim.lsp.commands["som.run"] = function(command, ctx)
    local uri = command.arguments and command.arguments[1] or vim.uri_from_bufnr(ctx.bufnr)
    local file = vim.uri_to_fname(uri)
    local program = program_for(file)
    local root = vim.fs.root(file, { ".git" })
    vim.cmd("silent! wall")
    vim.cmd("botright split")
    vim.fn.jobstart({ M.binary(root), "run", program }, { term = true, cwd = vim.fs.dirname(program) })
    vim.cmd("startinsert")
end

-- lens titles use VS Code icon syntax (`$(play) Run`)
local on_codelens = vim.lsp.codelens.on_codelens
vim.lsp.codelens.on_codelens = function(err, result, ctx, ...)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client and client.name == "som" then
        for _, lens in ipairs(result or {}) do
            if lens.command then
                lens.command.title = lens.command.title:gsub("%$%(play%)", "▶"):gsub("%$%([%w-]+%)%s*", "")
            end
        end
    end
    return on_codelens(err, result, ctx, ...)
end

return M
