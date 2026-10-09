-- jdtls reports an entity's generated QueryDSL/jpamodelgen classes and every
-- `import` of it as usages. Both are genuine references, but neither is ever
-- what you're looking for, so strip them out of <leader>gu.
local function strip_reference_noise(items)
  -- Read each file's lines once: a widely-used entity has hundreds of refs.
  local by_file = {}
  for _, item in ipairs(items) do
    local t = by_file[item.filename]
    if not t then
      t = { buf = item.buf, rows = {} }
      by_file[item.filename] = t
    end
    t.rows[#t.rows + 1] = item.pos[1]
  end

  local util = require("trouble.util")
  local lines = {}
  for path, t in pairs(by_file) do
    lines[path] = util.get_lines({ rows = t.rows, buf = t.buf, path = path }) or {}
  end

  local kept = {}
  for _, item in ipairs(items) do
    local line = lines[item.filename][item.pos[1]] or ""
    local generated = item.filename:match("/bin/generated%-[^/]*sources/")
    local import = line:match("^%s*import%s")
    if not generated and not import then
      kept[#kept + 1] = item
    end
  end
  return kept
end

return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
      auto_close = true,
      focus = true,
      modes = {
        diagnostics = {
          format = "{severity_icon} {message:md} {code:code}{pos}",
        },
        lsp_references = {
          filter = strip_reference_noise,
        },
      },
    },
    config = function(_, opts)
      require("trouble").setup(opts)
      local function fix_hl()
        local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
        vim.api.nvim_set_hl(0, "TroubleCount", { fg = comment.fg, italic = true })
      end
      fix_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_hl })
    end,
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer diagnostics",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location list",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix list",
      },
    },
  },
}
