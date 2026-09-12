return {
  {
    "nvim-treesitter/nvim-treesitter",

    branch = "main",
    dependencies = {
      "neovim-treesitter/treesitter-parser-registry",
    },

    lazy = false,
    build = ":TSUpdate",

    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.install({
        -- Neovim runtime
        "vim",
        "vimdoc",
        "query",

        -- Configuration
        "lua",

        -- Development
        "python",
        "javascript",
        "html",
        "css",
        "bash",

        -- Documents / data
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "toml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "vim",
          "help",
          "lua",
          "python",
          "javascript",
          "html",
          "css",
          "bash",
          "markdown",
          "json",
          "yaml",
          "toml",
        },

        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
