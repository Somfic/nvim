-- Velocity templates are HTML underneath: take html's ftplugin (tag matching,
-- omnifunc) and add the Velocity bits on top.
vim.cmd("runtime! ftplugin/html.vim")

vim.bo.commentstring = "## %s"

-- % jumps between #if / #elseif / #else / #end (and #foreach, #macro, #define)
local velocity_words = [[#{\=\%(if\|foreach\|macro\|define\)\>:#{\=\%(elseif\|else\)\>:#{\=end\>]]
local html_words = vim.b.match_words
vim.b.match_words = html_words and (html_words .. "," .. velocity_words) or velocity_words
