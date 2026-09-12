return {
  {
    "mikavilpas/yazi.nvim",

    version = "*",
    event = "VeryLazy",

    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },

    keys = {
      {
        "<leader>e",
        "<cmd>Yazi<cr>",
        desc = "Open Yazi at current file",
      },

      {
        "<leader>E",
        "<cmd>Yazi cwd<cr>",
        desc = "Open Yazi in current working directory",
      },

      {
        "<C-Up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume Yazi",
      },
    },

    opts = {
      open_for_directories = true,

      keymaps = {
        show_help = "<F1>",
      },
    },

    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
