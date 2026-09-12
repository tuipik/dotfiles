vim.g.mapleader = " "
vim.g.maplocalleader = " "

for _, lang in ipairs({
  "vim",
  "vimdoc",
  "lua",
  "query",
  "markdown",
  "markdown_inline",
}) do
  pcall(vim.treesitter.language.add, lang)
end

require("config.options")
require("config.keymaps")
require("config.lazy")
