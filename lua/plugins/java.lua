local c = require("config")

return {
  {
    "mfussenegger/nvim-jdtls",
    enabled = c.lsp,
    ft = "java",
  },
}
