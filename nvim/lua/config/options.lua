local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.mouse = "a"
opt.showmode = false

opt.breakindent = true
opt.undofile = true

opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = "yes"

opt.updatetime = 250
opt.timeoutlen = 300

opt.splitright = true
opt.splitbelow = true

opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

opt.cursorline = true
opt.scrolloff = 10

opt.termguicolors = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
